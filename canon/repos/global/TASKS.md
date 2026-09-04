# Repo `global` — Tasks

## CORRIGÉ 2026-09-04 - Routage Hub Remote canonique générationnel
- [x] Ajouter idempotemment `games_hubs.remote_routing_generation` et `remote_routing_intent_id`; publier atomiquement une génération par nouvelle intention Master/Global.
- [x] Incrémenter aussi lors d'une reprise qui conserve le même `execution_id`, avec retry du même `launch_intent_id` sans double incrément.
- [x] Faire de `client_routing` l'unique contrat causal avec `target`, `session_id`, `execution_id`, `routing_generation`, `remote_url`, `runtime_kind` et `joinable`.
- [x] Rendre `runtime_kind=existing` immédiatement joinable après décision centrale; réserver readiness aux runtimes `new` et `recreated`, présence runtime conservée comme diagnostic.
- [x] Transporter la génération dans l'URL historique et conserver `remote_transition_payload_json` comme relais UX sans identifiant causal autonome.
- [x] Exploiter les logs de la commande Remote `382`: `relaunch_suspended` réutilisait à tort l'exécution historique quittée.
- [x] Revalider sur les commandes `384`/`386` que le clear focus ne fermait ni l'exécution ni la présence runtime exacte, puis retirer le focus des préconditions de reprise.
- [x] Centraliser `resume_existing_runtime` sur la dernière exécution Hub/session ouverte, officielle + runtime `running`; ne plus recréer sur la seule expiration du heartbeat 12 s.
- [x] Aligner sas/injection papier et projection Games sur ce resolver sans règle métier dupliquée.
- [x] Préserver la réutilisation des démos isolées, le claim Master, le producteur `client_routing` et l'absence de mutation Hub Play.
- [x] Forcer `readiness_required=false` lors de la réutilisation explicite; conserver nouvel identifiant + readiness pour runtime non-running, exécution clôturée/absente, terminal et démo distincte.
- [x] Conserver la présence exacte dans le diagnostic de `client_routing`, sans en faire une garde de navigation après décision Master/Global.

## FUTUR 2026-09-03 - Changement d'offre des clients en propre
- [ ] Formaliser et persister la preuve d'intention Cotton avant toute mutation Stripe.
- [ ] Réutiliser le moteur de souscription initiale pour calculer/valider offre 12, jauge, périodicité, Price et remise.
- [ ] Autoriser seulement `jauge_cible > jauge_actuelle` et `duree_periode_cible >= duree_periode_actuelle` en V1.
- [ ] Corréler update Stripe, preview/prorata et webhooks sans inférer l'intention depuis un Price ou un événement isolé.
- [ ] Définir idempotence, replay, erreurs, rollback et tests de la matrice ascendante.
- [ ] Maintenir les offres déléguées hors cadre hors de ce chantier.

## CORRIGÉ/À RECETTER 2026-09-03 - Période courante Stripe
- [x] Ajouter les deux colonnes DATETIME nullable au DDL canonique et fournir le SQL autonome phpMyAdmin.
- [x] Résoudre les payloads Basil multi-items et legacy root, avec refus explicite des périodes divergentes ou invalides.
- [x] Persister uniquement les deux bornes Stripe, de façon idempotente, sans toucher aux champs commerciaux ni aux dates legacy.
- [x] Faire des bornes persistées l'autorité d'affichage d'une offre Stripe, avec fallback legacy temporaire et journalisé.
- [x] Couvrir mensuel, trimestriel, annuel, multi-items identiques/divergents, absence, création, renouvellement et no-op.
- [x] Utiliser temporairement la resynchronisation manuelle et le traitement batch pour initialiser les périodes existantes, puis retirer leurs trois helpers après convergence.
- [x] Conserver et couvrir directement `app_ecommerce_stripe_subscription_period_sync_from_id()` comme primitive runtime canonique utilisée notamment par `invoice.paid`.
- [x] Séparer la période historique d'une facture de la période courante de l'offre et la résoudre depuis ses Invoice Lines récurrentes.
- [x] Refuser les périodes de lignes divergentes, récupérer les lignes complètes si le payload est tronqué et tracer le fallback legacy sans lire les bornes Subscription.
- [x] Couvrir renewal simple, prorata ambigu, replay tardif, multi-lignes identiques/divergentes et immuabilité des anciens snapshots PDF/BO.
- [x] Retirer l'outil BO transitoire après migration/backfill, sans modifier les colonnes, le resolver, les webhooks, les affichages ou les fallbacks.

## CORRIGÉ/À RECETTER 2026-09-03 - Cycle de vie des offres déléguées hors cadre
- [x] Faire de `prix_reference_ht` l’assiette contractuelle prioritaire des lectures réseau, avec fallback catalogue réservé aux lignes legacy et compté explicitement.
- [x] Supprimer tout repricing Stripe depuis les lectures et le refresh de facturation; conserver le write `SubscriptionItem` au seul moteur contractuel appelé par `invoice.upcoming`.
- [x] Classer 429, transport/timeout et 5xx Stripe comme transitoires afin que le handler demande une redelivery sans compromettre l’idempotence.
- [x] Ajouter un guard fail-closed empêchant la désaffiliation tant qu’une offre hors cadre ou sa subscription Stripe n’est pas effectivement terminée.
- [x] Couvrir le snapshot `699,90 HT -> -5 % -> 79789 TTC`, l’idempotence, le chemin Stripe unique et les statuts de fin.
- [ ] Recette DEV avec données de test: remise inchangée, hausse/baisse, retry upcoming, résiliation en fin de période et désaffiliation après échéance.

## TERMINÉ 2026-09-02 - SchedulePlan canonique
- [x] Ajouter validation, résolution du Hub cible, commit, postconditions, compensation et reprise idempotente communs.
- [x] Rendre une interruption `writing_plan` reprenable après 30 secondes via Hub mémorisé et identités de sessions generated déterministes.
- [x] Interdire `reconcile` dans le chemin normal quick-add et compenser les créations en échec.
- [x] Libérer un contexte Hub inactif vide lorsque seule sa projection de publication subsiste.
- [x] Ajouter les contrats `schedule_plan_commit_contract_test.php` et `schedule_plan_commit_behavior_test.php`.
- [ ] Sur dev authentifié, vérifier `programming_quick_operations` et les ensembles exacts `games_hubs_sessions` après recette navigateur.

## CORRIGÉ/À RECETTER 2026-09-02 - Renouvellement réseau contractuel Stripe
- [x] Auditer `main` et l’historique Git du modèle de prix, du repricing réseau, des snapshots de commande et de la synchronisation `SubscriptionItem` Stripe.
- [x] Exploiter les exports de production fournis: offres `2054..2056` actives avec jauge `100`, `prix_reference_ht=664,91` et `prix_ht=949,05`; factures Stripe 2026 réellement payées `797,89 € TTC` avec libellé `50 joueurs`; commandes Cotton 2026 snapshotées à `949,05 € HT` / `1 081,92 € TTC`.
- [x] Corriger la chronologie: `invoice.created` apparaît vers 16:12:55 sans requête de repricing observée; `invoice.paid` vers 17:13:12 est suivi du POST backend Cotton sur le `subscription_item` à 17:13:15, puis des trois logs de recalcul/synchronisation réseau. L’instant du passage de jauge `50 -> 100` reste inconnu et ne doit pas être déduit de `date_maj`.
- [x] Inventorier les écritures de jauge: BO générique `module_modifier` sur toute offre, synchro de l’offre support réseau, propagation contractuelle `cadre`, gestion/création d’offres nouvelles ou pending; le bloc webhook Stripe qui traduisait un `lookup_key` en jauge est commenté dans `main`.
- [x] Reclasser la piste BO après réception des logs exhaustifs `2022-01-28` à `2026-09-02`: aucune modification générique de jauge n’existe pour `2054..2056`; les validations ne modifient pas la jauge. L’origine exacte du `100` reste non trouvée.
- [x] Tracer la création actuelle: le choix du widget poste `id_erp_jauge`, la création pending/standard stocke cette valeur, puis Checkout construit son prix inline ou son `lookup_key` depuis la même offre. Le fallback vers `clients.id_erp_jauges` de l’affilié n’intervient que si aucune jauge explicite valide n’est fournie; aucun double producteur local/Stripe n’est prouvé dans un même checkout.
- [x] Borner l’historique: le premier snapshot Pro disponible (janvier 2026) dérive lui aussi le `lookup_key` Stripe de la jauge déjà stockée; le code exact du `2025-08-28` est non trouvé et le comportement 2026 n’est pas extrapolé à 2025.
- [x] Qualifier la preuve `2512`: le même réseau a bien subi un passage BO `50 -> 100` sans changement de prix ou de souscription, ce qui prouve la possibilité métier d’une capacité opérationnelle différente de la formule payée, mais pas son application à `2054..2056`. Conclusion retenue: origine exacte non trouvée et confusion opérationnel/contractuel prouvée; mutation ultérieure non tarifaire comme hypothèse la plus plausible.
- [x] Prouver que le fallback sans contrat classe toutes les offres déléguées actives du siège comme candidats `hors_cadre`; il résout le brut depuis le catalogue courant (`999,00 € HT` pour offre `12`/jauge `100`/annuel), ignore `prix_reference_ht`, applique `5 %`, persiste `949,05 € HT` et envoie `1 138,86 € TTC` à Stripe avec `proration_behavior=none`, sans retirer le coupon historique.
- [x] Confirmer l’intention documentée de ce moteur: recalculer à la fois la base catalogue courante et la remise réseau, et non la seule remise. Cette intention est incompatible avec le besoin métier désormais formulé de figer le prix contractuel historique.
- [x] Remplacer le moteur de renewal par la lecture stricte du snapshot Stripe `cotton_contract_*`, avec remise réseau seule dynamique et zéro fallback catalogue/jauge courante.
- [x] Ajouter le guard métier exact et sa réévaluation pré-write, l'idempotence montant/intervalle, le contrôle futur de forme d'Invoice et la projection des montants réellement payés.
- [x] Couvrir guards, assiette autoritaire stable entre intentions commerciales, absence fail-closed, transitions 0/5/10/5/0, formes d'Invoice et contrat des événements dans les tests autonomes.
- [x] Séparer le Product support du montant: lookup construit par mapping figé depuis le snapshot, Price actif unique et compatible, Product associé actif, montant catalogue ignoré et fail-closed explicite.
- [x] Couvrir snapshot jauge/fréquence autoritaire face à Cotton courant, montant contractuel indépendant du Price support, Product inactif, lookup absent, propres/cadre et idempotence dans `app_ecommerce_network_delegated_contract_support_test.php`.
- [x] Prouver par fixtures V1 puis V2 que le renewal consomme les metadata contractuelles présentes au webhook, sans mémoire historique locale ni contrainte sur le suffixe `checkout_v1`; ne pas implémenter la mutation commerciale future.
- [x] Confirmer l’alignement des chemins audités entre `main` et `develop`; l’historique Git importé débute en 2026 et ne permet pas d’attribuer une mutation intervenue potentiellement en 2025.
- [ ] Administrateur: extraire le `descriptif_long` des logs `Offre client #2054..2056 > ajout` (SQL d’INSERT), ou les binlogs/backups aux secondes de création, puis comparer en lecture seule la première ligne Stripe/commande à la jauge locale actuelle pour toute la cohorte active.
- [ ] Après recette DEV: préparer le report identique sur `main`; traiter séparément les trois subscriptions legacy et toute décision de période, sans migration automatique ni régénération/remboursement.

## AUDITÉ 2026-09-01 - Baseline globale des tests
- [x] Exécuter les 28 scripts contractuels autonomes: 26 passent, 2 échouent, 0 skip; syntaxe PHP 28/28.
- [x] Confirmer sur trois passages que les deux échecs sont déterministes et non flaky.
- [x] Réaligner `hub_publication_prizes_contract_test.php` sur la tagline Dashboard `raw` de Pro (`565aa0bb`) et `hub_remote_control_contract_test.php` sur le coût borné exact `5 + business_revisions` (`10edc694`).
- [x] Classer ces deux rouges comme tests obsolètes; aucune régression fonctionnelle Global identifiée pendant l'audit.
- [x] Baseline après réalignement: 28/28 contrats exécutables et 28/28 vérifications de syntaxe PHP.
- [ ] Rejouer `hub_session_membership_dev_diagnostic.php` dans un environnement disposant des droits MySQL dev; l'échec local est un problème d'environnement, pas un test rouge.

## CORRIGÉ/VALIDÉ 2026-09-01 - Isolation du focus des démos Hub prospect
- [x] Ne jamais appeler `app_games_hub_focus_set_active(...)` pour une décision canonique `runtime_mode=demo`; conserver les identifiants de focus et de présentation préexistants.
- [x] Ne pas clear le focus officiel si la préparation du runtime démo échoue; journaliser `hub_demo_focus_mutation_skipped` avec l'état conservé.
- [x] Réserver le commit de focus au runtime officiel et couvrir cette séparation dans `hub_demo_mode_contract_test.php`.
- [ ] Recette DB: comparer avant/après une démo prospect puis un vrai lancement client actif, notamment avec un autre focus officiel déjà sélectionné.

## CORRIGÉ/VALIDÉ 2026-09-01 - Guard Quiz papier pour les démos Hub
- [x] Réutiliser `app_session_quiz_digital_guard_get(...)` avant toute création de runtime démo Hub pour une source Cotton Quiz papier.
- [x] Refuser une conversion numérique incompatible avant mutation de focus ou d'exécution, avec le message borné `Démo non disponible pour cette partie.`.
- [x] Conserver le duplicateur numérique, les démos compatibles, les sessions officielles et les limites Hub existantes.

## CORRIGÉ/VALIDÉ 2026-09-01 - Service de préparation Hub sans offre
- [x] Adapter le contrôle de contexte créateur du service Quick Hub: propriétaire et contact restent requis, l'offre effective devient optionnelle.
- [x] Préserver la création d'une session officielle, le membership explicite, l'idempotence et les politiques temporelles.
- [x] Couvrir statiquement l'absence de refus `id_offre_client <= 0` dans le contrat Global.
- [ ] Recette DB/intégration: compte sans offre, session officielle `id_offre_client=0`, membership Hub actif; lancement officiel toujours refusé.

## IMPLÉMENTÉ/VALIDÉ 2026-08-31 - Démo de contrôle Hub autonome
- [x] Conserver la matrice commerciale existante et réserver la démo de contrôle au client à offre active, avant ou pendant fenêtre.
- [x] Déduire le seul type de jeu depuis la première session officielle active du Programme, dans son ordre canonique; ne jamais reprendre son contenu, son format ni son support.
- [x] Réutiliser le producteur historique de `session_duplicate` (`app_session_demo_create_from_source`) pour créer la session démo isolée, puis la suggestion quick-add numérique pour remplacer uniquement son contenu/thématique.
- [x] Ne jamais réconcilier cette démo avec le Hub : aucun membership, focus, présentation, résultat, classement ou session active officielle n'est modifié; Remote résout seulement le runtime isolé par source/exécution via le resolver canonique.
- [x] Ne créer l'exécution démo qu'après reset vérifié; cette couche, et non la duplication, produit l’arrivée Master `hub_launch=1` directement jouable. Réutiliser sans reset une exécution ouverte et compléter une fin démo sans stats/résultats Hub.
- [x] Ne jamais injecter le roster/probables Hub dans le runtime démo; laisser Hub Play suivre son contrat historique, distinct du QR et des joueurs propres à la démo.
- [x] Résoudre le branding Canvas d'une démo par son exécution Hub validée, sans membership, et appliquer la cascade par défaut Hub sans scope session dupliqué.
- [x] Exclure les événements d’exécution `runtime_mode=demo` de l’historique de lancement officiel qui pilote la visibilité du CTA démo.
- [x] Faire résoudre le contexte d’exécution de branding par une lecture minimale de la session source, afin que l’endpoint Global ne dépende jamais des helpers du jeu concerné.
- [x] Inclure `id_type_produit` dans cette lecture minimale afin que la fin naturelle d'un runtime démo puisse écrire `hub_execution_completed` avec le jeu canonique.
- [x] Conserver le resolver fermé sans événement d'exécution ouvert: la provenance Dashboard Pro mobile et la membership de la source ne peuvent pas créer ou compléter une exécution Hub.
- [x] Couvrir matrice, atomicité contractuelle, réutilisation, timeout, payload, reset et non-contamination par `hub_demo_mode_contract_test.php` et les contrats Hub existants.
- [ ] Recette DB de concurrence post-déploiement: 2 puis 10 appels Master/Remote simultanés, crash partiel Bingo, timeout du lock et stabilité du token après modification de la source.

## CORRIGÉ/VALIDÉ 2026-08-31 - Bootstrap runtime avant injection Hub papier
- [x] Appeler l'ensure historique minimal une seule fois pour tout launch papier qui atteindra la boucle d'injection.
- [x] Placer cet appel après les gardes de lancement mais avant `app_games_hub_focus_set_active(...)` et la création du contexte d'exécution.
- [x] Arrêter explicitement le launch avec `PAPER_HISTORICAL_SESSION_ENSURE_FAILED` si l'ensure requis échoue.
- [x] Conserver la sélection `games_hubs_players.status='active'`, les mappings actifs et le comportement existant de `failed_count > 0`.
- [x] Laisser le type archive `2` sur son chemin antérieur, sans extension de support.
- [x] Couvrir types `1|4|5|6`, ordre ensure/focus/injection, mapping actif et absence de preload complet par `hub_paper_cold_runtime_bootstrap_contract_test.php`.
- [ ] Recette DB/navigateurs post-déploiement: vérifier participants historiques, mappings actifs, visibilité immédiate Master/Remote et absence de duplication au second passage.

## CORRIGÉ/VALIDÉ 2026-08-31 - Lien Master individuel terminal
- [x] Ajouter le seul producteur d'URL `app_session_get_individual_terminal_master_link(...)` pour les jeux modernes `4|5|6` déjà terminés.
- [x] Réutiliser le launcher Games direct existant puis porter l'intention de présentation `master_view=individual`; retourner vide hors terminal/type moderne.
- [x] Ne modifier ni chronologie, ni droits, ni lancement, ni Hub, ni endpoint: Games revalide l'état terminal au GET.

## CORRIGÉ/VALIDÉ 2026-08-27 - Quick-add Hub: séparation préparation/live
- [x] Inventorier les consommateurs réels: Dashboard Pro, Hub Master Games et Hub Remote Games.
- [x] Introduire les politiques explicites `live` (`open`) et `dashboard_preparation` (`before|open`), avec refus fermé pour `expired|invalid` et politique inconnue.
- [x] Conserver `live` comme défaut et exposer un point d'entrée serveur dédié au Dashboard, sans option contrôlée par le navigateur.
- [x] Signer la politique dans la proposition et refuser une création quand la politique signée ne correspond pas au chemin appelé.
- [x] Préserver idempotence, membership, absence d'écriture de focus/runtime et cutoff canonique.
- [x] Couvrir la matrice temporelle et le refus de rejeu croisé dans le test contractuel du service.

## PATCH 2026-08-26 - Hub players papier: membership et transitions roster
- [x] Prouver le filtre exact de `app_games_hub_session_inject_active_players(...)`: `games_hubs_players.status='active'`, sans condition `last_seen_at`.
- [x] Prouver la sémantique de `games_hubs_players.status`: enum `active|left` pour membership Hub joueur, pas présence live.
- [x] Identifier les opérations de sortie existantes: `app_games_hub_player_leave(...)` écrit `left`; la réinscription/réactivation écrit `active`.
- [x] Confirmer qu'une fermeture/déconnexion smartphone ne passe pas le joueur en exclusion: le touch ne met à jour que `last_seen_at`.
- [x] Conserver `app_games_hub_player_unregister(...)` comme sortie Hub-only `games_hubs_players.status='left'`, sans `games_hubs_players_sessions` ni runtime.
- [x] Faire exposer par `app_games_hub_player_upsert(...)` / `app_games_hub_player_ensure(...)` les transitions roster `created`, `reactivated` et `already_active`, sans assimiler un mapping session `left` à une désinscription Hub.
- [x] Couvrir le couple de comportement: inscrit + smartphone inactif reste injectable; undo Hub valide rend le joueur non injectable car il sort du roster actif.
- [ ] Recette DB: vérifier les lignes `games_hubs_players` avant/après ajout, fermeture téléphone, undo sas immédiat puis lancement papier.

## PATCH 2026-08-26 - Hub Remote presence gate pour Dashboard Pro
- [x] Relire START raw main, SITEMAP.txt develop, DOCS_MANIFEST et cartes Games/Global/Pro; journal AI Studio raw inaccessible via `curl` (`HTTP 403 Forbidden`), fallback documentaire/local appliqué.
- [x] Auditer les helpers de présence existants: `app_games_hub_remote_master_presence_gate_get(...)` couvre la présence Master pour Hub Remote, mais aucun helper symétrique ne couvrait la fraîcheur de la Hub Remote canonique pour Pro.
- [x] Ajouter `app_games_hub_remote_presence_gate_get(...)`, basé sur `hub_remote_instance_id` et `hub_remote_instance_seen_at` relus depuis `games_hubs`, avec TTL court borné et sans écriture.
- [x] Faire consommer ce helper par le Dashboard Pro pour bloquer l'ouverture Master quand un programme contient une session papier et que la Remote est absente/stale.
- [x] Couvrir par `hub_remote_control_contract_test.php`, `hub_instance_exclusivity_contract_test.php` et `ec_start_sessions_day_dashboard_test.php`.
- [ ] Recette DB/navigateur: Remote fraîche puis stale sur programme papier, vérifier le passage/refus du CTA Dashboard sans création de token supplémentaire.

## PATCH 2026-08-26 - Hub Master hidden: presence gate borné
- [x] Conserver le gate nominal visible à 6 s dans `app_games_hub_remote_master_presence_gate_get(...)`.
- [x] Remplacer le comptage limité au TTL court par une lecture de la dernière présence de l'instance Master canonique, puis choisir le TTL effectif selon `visibility`.
- [x] Accorder une lease bornée au Master `hidden` sans nouvelle boucle de polling ni scan global.
- [x] Corriger le verrou résiduel vu dans les logs rechargés: `control_poll.pending_command_id` ne réannonce plus une commande créée avant la dernière présence fraîche du Master courant, et la réutilisation `launch_session` applique la même borne.
- [x] Ajouter `app_games_hub_remote_master_presence_release(...)`, strictement conditionné à `app_games_hub_instance_is_current($hub, 'master', $master_instance_id)`, pour ignorer les pagehide tardifs d'anciens Masters.
- [x] Couvrir par `hub_remote_control_contract_test.php` et conserver `hub_instance_exclusivity_contract_test.php`.
- [ ] Recette DB/navigateur: vérifier visible TTL 6 s, hidden stable 1-2 min, fermeture réelle libérée par release, crash sans release expiré par fallback, takeover A -> B avec A hidden sans déconnexion de B.

## PATCH 2026-08-26 - Exclusivité instances Hub et gate Master frais
- [x] Relire START raw main, SITEMAP.txt/SITEMAP.ndjson develop, DOCS_MANIFEST et cartes Games/Global; journal AI Studio raw consulté via l'URL imposée mais inaccessible en lecture utile (`HTTP 500 Internal Server Error` via outil web).
- [x] Ajouter à `games_hubs` les instances canoniques `hub_master_instance_id` / `hub_remote_instance_id` et leurs timestamps de dernière vue.
- [x] Implémenter `app_games_hub_instance_takeover(...)` comme écriture bornée aux champs d'instance, sans `date_maj`, `active_session_id`, `presentation_session_id`, exécution ni routage.
- [x] Implémenter les gardes `is_current` / `touch_current` et la réponse stale commune `instance_current=false`, `replaced=true`.
- [x] Ajouter `app_games_hub_remote_master_presence_gate_get(...)`: présence du Master canonique avec TTL frais 6 s, utilisé par `control_poll.master_present` à la place du TTL 30 s historique.
- [x] Protéger la création de commandes Remote par l'instance Remote canonique et le gate Master frais, en acceptant un gate déjà calculé par l'endpoint pour éviter une requête DB supplémentaire par mutation.
- [x] Protéger le claim par l'instance Master canonique, la présence fraîche et une sélection bornée aux commandes créées depuis la dernière présence continue; annuler les pending du Hub courant quand la présence est perdue.
- [x] Couvrir par `hub_instance_exclusivity_contract_test.php` et `hub_remote_control_contract_test.php`, en préservant les contrats présentation/routing existants.
- [ ] Recette DB: simuler deux instance ids Master/Remote sur un même Hub, vérifier dernier gagnant, stale refusé, absence de mutation runtime/presentation/revision au takeover, perte Master >6 s puis retour sans claim d'ancienne commande.

## PATCH 2026-08-25 - Suppression session Hub observable par Remote
- [x] Auditer les logs: après suppression Dashboard, Hub Master convergeait mais Hub Remote continuait seulement des `control_poll` ~435-440 octets, sans `business_snapshot`.
- [x] Identifier la faille: la suppression individuelle supprimait physiquement `championnats_sessions` mais laissait le membership `games_hubs_sessions` actif, sans `updated_at=NOW()`.
- [x] Désactiver les memberships Hub actifs de la session dans `app_session_delete_canonical(...)` avant `app_session_supprimer(...)`.
- [x] Conserver la suppression Hub complète inchangée: elle supprime déjà ses memberships dans son propre service.
- [x] Couvrir par `hub_delete_service_contract_test.php` et `hub_remote_control_contract_test.php`.
- [ ] Recette navigateur: Hub terminé avec quick-add ouverte, supprimer une partie depuis Dashboard Pro, vérifier que Remote appelle `business_snapshot` et retire la carte sans reload.

## PATCH 2026-08-25 - Renouvellement theme: date_maj et revision
- [x] Relire START raw main, SITEMAP.txt develop, DOCS_MANIFEST et cartes Games/Global/Pro; journal AI Studio raw non consulte car demande explicitement signale en erreur.
- [x] Auditer le contrat `app_programming_theme_renewal_plan_for_session(...)` / `app_programming_theme_renewal_apply_for_session(...)`: validation session/client, jeu compatible, appartenance Hub, Hub non termine, edit-state non lock, stale selection, validation finale des propositions et exclusions historiques.
- [x] Confirmer les champs mutes: Blind Test `id_produit`; Quiz `id_produit`, `lot_ids`, `flag_configuration_complete`; Bingo materialise une playlist client puis met `id_produit` et `flag_configuration_complete`.
- [x] Ajouter `date_maj` aux updates conditionnels reussis afin que les chemins historiques horodates restent corrects.
- [x] Confirmer que `preparation_revision` couvre deja ces mutations par empreinte stable (`id_produit`, `lot_ids`, format, mode, statut config, position, membership), meme si `date_maj` etait insuffisant.
- [x] Couvrir par `session_theme_renewal_apply_test.php`, `session_theme_renewal_planner_test.php` et `hub_remote_control_contract_test.php`.
- [ ] Recette DB: renouveler un theme depuis Remote et verifier `championnats_sessions.date_maj`, changement de `preparation_revision`, puis convergence Master/Remote sans reload.

## PATCH 2026-08-25 - Hub Remote preparation_revision couvre Dashboard/settings
- [x] Relire START raw main, SITEMAP.txt develop, DOCS_MANIFEST et cartes Games/Global/Pro; journal AI Studio raw consulté mais inaccessible (`HTTP 403 Forbidden`, `Fichier non autorisé ou introuvable`).
- [x] Auditer `app_games_hub_remote_business_revisions_get(...)`: la révision Remote couvrait Hub, memberships, sessions, lots, runtime et résultats, mais pas les événements canoniques de réglages `hub_session_settings_save`.
- [x] Auditer Dashboard Pro: `ec_start_dashboard_program_helpers.php` pouvait modifier `id_format`, `flag_controle_numerique`, `id_produit` et `lot_ids` sans écrire `date_maj`; Pro horodate maintenant ces mutations.
- [x] Ajouter une empreinte des champs de préparation Programme dans `preparation_revision`, afin que format, mode, contenu, statut de configuration et ordre changent même sans timestamp applicatif.
- [x] Ajouter `settings_revision` depuis `game_events` joint aux sessions actives du Hub par `championnats_sessions.id_securite`.
- [x] Inclure `settings_revision` dans `preparation_revision`, afin que `control_poll -> business_snapshot` détecte les mutations de réglages sans nouveau polling.
- [x] Conserver `control_poll` léger: pas de `app_games_hub_render_context_get(...)`, pas de listes Programme/joueurs dans la révision.
- [x] Couvrir par `global/web/tests/hub_remote_control_contract_test.php`.
- [ ] Recette DB: sauvegarder des settings Hub depuis Remote/Master et vérifier que `preparation_revision` change puis que Master/Remote se réalignent sans reload.

## PATCH 2026-08-25 - Hub présentation: policy next-ready
- [x] Ajouter `app_games_hub_next_ready_session_resolve(...)` avec tri Programme (`position`, fallback index, `id`) et exclusion des sessions terminées/running/focus actif.
- [x] Ajouter `app_games_hub_presentation_apply_next_ready(...)`, qui persiste uniquement via `app_games_hub_presentation_session_set(...)`.
- [x] Étendre `app_games_hub_focus_clear(...)` avec options de politique présentation rétrocompatibles.
- [x] Déclencher next-ready seulement après clear atomique réussi; ne rien appliquer en cas de race/different focus.
- [x] Garder la désactivation explicite `presentation_next_ready=false` pour la fin naturelle côté Games.
- [x] Couvrir par `hub_presentation_mode_contract_test.php` et conserver `hub_remote_control_contract_test.php`.
- [ ] Recette DB: clear focus d'une session suspendue avec une pending suivante, vérifier `presentation_session_id` next-ready et `active_session_id=0`; fin naturelle, vérifier absence de promotion next-ready immédiate.

## PATCH 2026-08-25 - Hub focus runtime vs présentation séparés
- [x] Ajouter `games_hubs.presentation_session_id` nullable dans `app_games_hub_schema_ensure()` et dans le schéma canonique, avec index dédié et sans backfill.
- [x] Ajouter `app_games_hub_presentation_session_set(...)`: validation Hub/session, écriture `presentation_session_id`, `presentation_mode=session`, `presentation_updated_at`, journalisation bornée, aucune écriture runtime.
- [x] Faire migrer `app_games_hub_presentation_resolve(...)`: priorité `hub_podium`, puis `presentation_session_id`, puis fallback runtime, puis fallback programme non destructif.
- [x] Garder `active_session_id` pour lancement/reprise, validation d'exécution ouverte, auto-join Hub Play, routing Remote historique et clears atomiques.
- [x] Faire écrire `presentation_session_id` lors d'un vrai `app_games_hub_focus_set_active(...)` pour aligner l'affichage sur l'action runtime.
- [x] Adapter le routing Remote et l'auto-join pour qu'ils ne dépendent plus d'une présentation sélectionnée.
- [x] Couvrir par `hub_presentation_mode_contract_test.php` et conserver `hub_remote_control_contract_test.php`.
- [ ] Recette DB: importer la migration, sélectionner une session hors runtime, vérifier `presentation_session_id` seul; lancer/reprendre ensuite, vérifier `active_session_id` et `presentation_session_id` alignés.

## PATCH 2026-08-25 - Hub Remote: commande de sélection présentation
- [x] Relire START, SITEMAP, SITEMAP.ndjson, DOCS_MANIFEST et HANDOFF; journal AI Studio raw consulté mais inaccessible (`HTTP 403`, `Fichier non autorisé ou introuvable`), fallback documentaire local relu.
- [x] Étendre l'allowlist Remote à `select_session` en plus de `master_ping` et `launch_session`.
- [x] Valider côté serveur que la session sélectionnée appartient bien au Hub de l'accès Remote.
- [x] Porter un payload borné `hub_remote_select_session:v1` avec `session_id` et `session_token`, sans URL runtime libre.
- [x] Garder la création Global sans URL runtime libre; la consommation Games Master écrit ensuite la présentation dédiée sans modifier `active_session_id`.
- [x] Ne pas modifier la readiness, le contrat `client_routing` ni le contrat `launch_session`.
- [x] Couvrir par `global/web/tests/hub_remote_control_contract_test.php`.
- [ ] Recette dev: depuis Hub Remote et Hub Master, sélectionner successivement deux sessions terminées puis une suspendue; vérifier que `presentation_session_id` suit la sélection/podium sans session joignable tant que le CTA `Lancer` / `Reprendre` n'est pas cliqué.

## PATCH 2026-08-24 - Hub Remote: readiness requise sur exécution réutilisée non prête
- [x] Relire START, SITEMAP, DOCS_MANIFEST et HANDOFF; journal AI Studio raw consulté mais inaccessible (`HTTP 403`, `Fichier non autorisé ou introuvable`), fallback documentaire local relu.
- [x] Exploiter la recette réelle Hub `212`, session `27261`, command `72`: première navigation Remote à `14:47:42`, readiness seulement à `14:47:46`, puis seconde navigation stable.
- [x] Identifier le raccourci fautif: `hub_execution_context_detected reused=1` forçait `readiness_required=false`, et `client_routing` rendait la Remote joinable sans preuve runtime live.
- [x] Remplacer le raccourci par le signal existant `hub_remote_runtime_ready`: une exécution réutilisée est joignable sans attente seulement si la readiness de ce même `execution_id` existe déjà.
- [x] Faire porter le même contrat par le résultat de commande `launch_session` et par `app_games_hub_remote_client_routing_state_get(...)`.
- [x] Couvrir par `global/web/tests/hub_remote_control_contract_test.php`.
- [ ] Recette dev: vérifier que `hub_remote_game_readiness_confirmed` précède `hub_remote_launch_remote_navigation` sur reprise Quiz/Blind Test et qu'un seul GET `/remote/{game}/...` est produit.

## PATCH 2026-08-24 - Hub Remote: révisions métier bornées
- [x] Relire START, SITEMAP, DOCS_MANIFEST et HANDOFF; journal AI Studio raw consulté mais inaccessible (`HTTP 403`, `Fichier non autorisé ou introuvable`), fallback documentaire local relu.
- [x] Auditer les révisions existantes: `preparation_revision`/`results_revision` dérivaient surtout de `games_hubs`, `runtime_revision` de `active_session_activated_at`.
- [x] Ajouter `app_games_hub_remote_business_revisions_get(...)` pour couvrir programme, lots, focus/runtime, joueurs/mappings et projection `stats_*` par agrégats SQL bornés.
- [x] Garder `control_poll` hors contexte de rendu complet, sans `app_games_hub_render_context_get(...)`, sans listes sessions/joueurs/résultats et sans HTML.
- [x] Documenter le coût SQL via `perf.sql_queries`: avant 4, après 4 + agrégats de révision.
- [x] Couvrir le contrat par `global/web/tests/hub_remote_control_contract_test.php`.
- [ ] Recette DB dev: vérifier qu'ajout programme, modification lots, focus/quit/fin et rebuild stats changent au moins une révision pertinente.

## PATCH 2026-08-24 - Hub Remote: revert borne vers baseline launch
- [x] Identifier la baseline Global: `f5b23dbc02001c6fd21a18232aae891767fef72e` (`2026-07-31 19:42:09 +0200`), aucun commit local du matin sur `app_games_hubs_functions.php`.
- [x] Classer comme suspect le patch non commit autour de `primary_presence`, `runtime_ready_at`, `client_joinable` renforce et `resume_waiting_primary`.
- [x] Revenir au contrat `client_joinable` baseline: readiness exigee seulement quand `readiness_required=true`; reprise ouverte joignable sans presence primary.
- [x] Verifier que les fichiers cibles Global n'ont plus de diff apres revert.
- [x] Couvrir par `php -l web/app/modules/jeux/hubs/app_games_hubs_functions.php` et `php web/tests/hub_remote_control_contract_test.php`.
- [ ] Recette navigateur dev: lancement neuf BT/Quiz/Bingo, reprise suspendue BT, reload Hub Remote session active, quit Remote, quit Master -> Hub Remote.

## PATCH 2026-07-31 - Hub Remote: resolver d'exécution ouverte en reprise
- [x] Identifier l'invariant fautif: une reprise peut refocaliser une session sur une exécution déjà ouverte dont `hub_execution_started` est antérieur à `active_session_activated_at`.
- [x] Corriger `app_games_hub_execution_context_get_open(...)` pour valider le focus par `active_session_id` au lieu de rejeter l'exécution par comparaison de timestamps.
- [x] Préserver l'exclusion des exécutions complétées via `hub_execution_completed`.
- [x] Préserver le refus d'une exécution quand une autre session est le focus actif et que le respect du focus est demandé.
- [x] Couvrir le contrat par `global/web/tests/hub_remote_control_contract_test.php`.
- [ ] Recette DB/dev: reprendre une session suspendue dont l'exécution est antérieure au dernier focus, vérifier absence de `hub_execution_unresolved`, puis fin naturelle et quit Master/Player.

## PATCH 2026-07-31 - Hub Remote: URL de retour Remote historique
- [x] Étendre `app_games_hub_session_remote_url(...)` pour accepter Hub et `execution_id` sans casser les appels historiques session seule.
- [x] Lire l'accès Remote actif du Hub et utiliser uniquement le token Remote dédié dans l'URL de retour.
- [x] Ajouter `hub_remote=1`, `hub_remote_token`, `hub_remote_return=/hub/{remote_token}/remote` et `hub_remote_execution` à l'URL historique quand le contexte Hub Remote est prouvé.
- [x] Préserver l'URL historique sans query Hub Remote hors contexte Hub ou sans accès Remote actif.
- [x] Faire consommer cette URL enrichie par le routage canonique `client_routing` et le résultat `launch_session`.
- [x] Couvrir le contrat par `global/web/tests/hub_remote_control_contract_test.php`.
- [ ] Recette DB/dev: vérifier URL enrichie sur lancement Hub Remote, absence de token Master, URL inchangée hors Hub, changement d'`execution_id` transmis.

## PATCH 2026-07-31 - Hub Remote: readiness runtime conditionnelle
- [x] Prouver que `completed` signifie seulement lancement serveur accepté: focus Hub, contexte d'exécution, URLs et résultat de commande, sans preuve de chargement navigateur Organizer.
- [x] Ajouter la lecture de commande par Hub pour valider les callbacks Master/Organizer sans exposer les secrets Remote.
- [x] Ajouter le marqueur idempotent `hub_remote_runtime_ready` dans `game_events`, corrélé durablement par Hub, session et `execution_id`.
- [x] Ajouter `app_games_hub_remote_launch_readiness_mark(...)` avec validation de session Hub, type `launch_session`, payload `session_id` et résultat `execution_id`.
- [x] Ajouter `app_games_hub_remote_launch_readiness_get(...)` pour exposer `ready=false` tant que `completed` n'a pas de marqueur runtime correspondant.
- [x] Ajouter `app_games_hub_remote_launch_readiness_get_for_execution(...)` et `app_games_hub_remote_client_routing_state_get(...)` pour que la disponibilité Remote survive aux reloads et ouvertures tardives.
- [x] Ajouter `transition_type`, `readiness_required` et `routing_reason` pour distinguer lancement neuf, reprise d'exécution ouverte et reprise avec runtime recréé.
- [x] Couvrir le contrat par `global/web/tests/hub_remote_control_contract_test.php`, dont mismatch d'exécution, raisons de routage et attente readiness uniquement pour l'exécution courante.
- [ ] Recette DB dev: vérifier le marqueur `game_events`, l'idempotence, un mauvais `execution_id`, une session hors Hub et la lecture `command_status` côté Games.

## PATCH 2026-07-31 - Hub Remote: commande `launch_session`
- [x] Étendre l'allowlist Remote à `master_ping` + `launch_session`, sans changer le schéma de table existant.
- [x] Valider `launch_session` côté serveur avant création: accès Remote actif, Hub actif, session rattachée, non terminée, fenêtre de lancement ou reprise, présence Master récente, URLs internes résolues.
- [x] Réutiliser une commande active identique pour le même Hub/session afin de couvrir double tap, deux Remotes et réponse HTTP perdue.
- [x] Garder le claim atomique `pending -> claimed`, ajouter `processing`, et permettre `completed|failed` uniquement pour le Master qui a claim.
- [x] Porter l'expiration `launch_session` à 60 secondes, compatible avec le heartbeat Master masqué; `master_ping` reste à 20 secondes.
- [x] Construire `remote_url` côté serveur via `app_games_hub_session_remote_url(...)`; aucune redirection libre client.
- [x] Couvrir le contrat par `global/web/tests/hub_remote_control_contract_test.php`.
- [ ] Recette DB dev: deux Remotes, deux Masters, commande expirée, commande failed, commande completed et absence de double claim sur `launch_session`.

## PATCH 2026-07-31 - Hub Remote: accès, présence et commandes
- [x] Ajouter `games_hubs_remote_access`, `games_hubs_remote_master_presence` et `games_hubs_remote_commands` dans `app_games_hub_schema_ensure()`.
- [x] Ajouter génération/validation de token Remote dédié, hash versionné, session Remote hashée, touch de dernière vue et logs sans secret.
- [x] Ajouter `app_games_hub_remote_control_state_get(...)` O(1), sans contexte complet, sessions, joueurs ou agrégat lourd.
- [x] Ajouter présence Master par instance avec rythme visible/masqué côté Games.
- [x] Ajouter file persistée et idempotente de commandes, bornée à `master_ping` pour Lot 1, avec claim/complete/expire.
- [x] Couvrir le contrat par `global/web/tests/hub_remote_control_contract_test.php`.
- [ ] Recette DB dev: vérifier création de tables, token actif/révoqué, présence Master récente, commande `master_ping` complétée et expiration sans Master.

## PATCH 2026-07-31 - Participations probables Hub et présence runtime
- [x] Relire START, SITEMAP, DOCS_MANIFEST, README/TASKS/HANDOFF, schéma DB et journal AI Studio raw avant patch; aucune entrée AI Studio ciblée Hub probable/runtime n'a signalé un fichier hors workspace à recharger.
- [x] Auditer `championnats_sessions_participations_probables`: table historique session-centric, MyISAM, clé unique session/joueur/équipe et `id_championnat_session` obligatoire.
- [x] Ajouter la table dédiée `games_hubs_participations_probables` avec déduplication `(id_hub, auth_identity_key)`.
- [x] Ajouter les helpers `app_games_hub_probable_declare_ep`, `...cancel_ep`, `...confirm_ep`, `...count` et `...list`.
- [x] Router les helpers historiques `app_session_participation_probable_*` vers la source Hub quand la session est rattachée à un Hub et qu'une identité EP est disponible; conserver la table historique pour les sessions autonomes.
- [x] Ajouter au retour EP Hub l'intention explicite `hub_account_action=probable|join`, normalisée côté Global.
- [x] Avant J, faire revenir le parcours EP probable sur la page EP Hub sans créer `games_hubs_players`, probable Hub, mapping session, participation runtime, grille Bingo, leaderboard ou compteur joué.
- [x] Pendant la fenêtre de lancement, créer/réactiver l'identité Hub à la présence EP réelle et confirmer une probable existante; ne pas laisser une ancienne intention probable bloquer le jour J.
- [x] Limiter l'injection de tous les joueurs actifs au mode papier; en numérique, laisser les chemins de présence runtime créer/réactiver les participations.
- [x] Couvrir les contrats par tests source ciblés et mettre à jour les compteurs Hub sur la source probable dédiée.
- [x] Couvrir le retour EP réel par `hub_ep_return_intent_test.php` avec stubs du retour Hub.
- [ ] Recette dev DB/browser: importer la migration, déclarer/annuler avant J via Hub Play et formulaire EP session liée Hub, lancer une session papier puis numérique, vérifier absence de mapping/participation avant présence réelle et absence d'auto-join après `left`.

## PATCH 2026-07-31 - Photo podium active Hub
- [x] Auditer le contrat historique `app_session_results_player_podium_photo_access_get(...)` / `app_session_results_podium_photo_upload(...)` et confirmer le stockage par session/rang/ligne dans `medias_images`.
- [x] Auditer `games_hubs_players` et `games_hubs_players_sessions`: l'identité canonique Hub existe, mais aucun champ photo active ne permet l'unicité par identité.
- [x] Ajouter les colonnes `hub_photo_media_id`, `hub_photo_game_key`, `hub_photo_source`, `hub_photo_updated_at` via migration manuelle idempotente côté Games SQL.
- [x] Ajouter `app_games_hub_player_active_photo_get(...)` et la résolution runtime podium -> mapping Hub -> identité Hub -> photo active.
- [x] Ajouter `app_games_hub_player_podium_photo_upload(...)` avec contrôles Hub/identité/mapping, traitement image historique, consentement historique et remplacement de la photo active précédente.
- [x] Faire évoluer l'éligibilité Hub Play: rang 1–3 de l'identité active dans `aggregate_context.aggregate_ranking`, chargé et vérifié côté serveur Games, sans rang navigateur ni preuve obligatoire de podium de session.
- [x] Conserver la session mappée uniquement comme support historique de consentement/traçabilité; autoriser un Top 3 Hub sans podium de session et refuser un rang 4+ malgré un ancien podium.
- [x] Enrichir `aggregate_ranking` et les contextes de podium de session avec la photo active Hub sans modifier les rangs/scores/résultats canoniques.
- [x] Mettre à jour `games_hubs.date_maj` après upload pour déclencher le refresh partiel Hub Master.
- [x] Préserver le comportement historique hors Hub: les helpers session podium existants restent inchangés et ne sont plus appelés par Hub Play pour écrire.
- [ ] Recette dev après import SQL: upload/remplacement réel aux rangs 1/2/3, refus rang 4+ forgé, photo préservée après descente, reload Hub Play, podiums Hub Master/session, podium agrégé, solo, équipe, session hors Hub et séparation de deux identités Hub.

## PATCH 2026-07-30 - Fallback participants runtime Hubs historiques
- [x] Confirmer via logs que certains Hubs historiques ont `players_count=0`, `mappings_count=0`, mais des résultats de sessions directement exploitables.
- [x] Ajouter une collecte bornée aux sessions explicitement rattachées au Hub via `games_hubs_sessions`.
- [x] Lire les participants runtime Quiz, Blind Test et Bingo uniquement pour les sessions terminées fiables du Hub.
- [x] Matérialiser les joueurs et mappings via `app_games_hub_player_upsert(...)` et `app_games_hub_session_mapping_upsert(...)`, sans fusion par pseudo.
- [x] Relancer ensuite le rebuild canonique `games_hubs_players.stats_*` hors rendu.
- [x] Ajouter un fallback de compteurs Pro/agenda quand aucun joueur Hub actif n'existe.
- [x] Borner l'alimentation `stats_*` aux sessions Hub explicitement terminées, sans fallback `date passée + participants`.
- [x] Exclure des contributions et de la matérialisation les sessions Quiz/Blind Test historiques dont tous les scores runtime sont à zéro.
- [x] Exclure des contributions et de la matérialisation les sessions Bingo sans gagnant de phase.
- [x] Couvrir les contrats par `hub_players_stats_projection_contract_test.php` et `hub_participation_counters_contract_test.php`.
- [ ] Recette dev: rouvrir l'ancienne soirée Pro, vérifier matérialisation, rebuild `stats_*`, puis Hub Master en `hub_persistent_stats`.

## PATCH 2026-07-30 - Contexte Global Hub léger
- [x] Restaurer `app_client_joueurs_dashboard_context_compute(...)` sur son contrat historique client/période/saison, sans logique `hub_persistent`.
- [x] Ajouter `app_games_hub_render_context_get(...)` borné à un Hub explicite ou une ligne Hub validée.
- [x] Produire `aggregate_ranking`, `aggregate_top3`, `aggregate_podium`, `aggregate_ranking_source`, `aggregate_ranking_fallback_reason` et audit depuis Global/Hubs.
- [x] Lire nominalement `games_hubs_players.stats_*` via `app_games_hub_players_stats_ranking_get(...)`.
- [x] Adapter les lignes `stats_*` vers le contrat canonique `aggregate_ranking` sans recalcul local ni rebuild runtime.
- [x] Accepter une projection vide quand aucune session Hub n'est terminée ou quand seules des sessions suspendues existent.
- [x] Garder le fallback historique temporaire dans Global/Hubs pour `schema_missing`, `projection_missing`, `projection_dirty`, `projection_error`, `projection_incomplete`, `read_failure`.
- [x] Couvrir adaptation, fallback, absence de rebuild au rendu et restauration du helper historique par tests.
- [ ] Recette dev Hub Master: confirmer `aggregate_ranking_source=hub_persistent_stats`, `historical_fallback_used=0` et disparition du coût historique Global dans `hub_master_full_reload_profile`.

## PATCH 2026-07-30 - Initialisation auto stats Hub historiques
- [x] Auditer les points de résolution/création/réconciliation Hub et retenir `app_games_hub_get_or_create_for_context(...)` comme point Global commun.
- [x] Ajouter une décision bornée pour initialiser seulement les Hubs actifs avec sessions Hub, sessions terminées fiables, mappings prouvés et projection absente/dirty/error/incomplète ou enrichissement prouvé.
- [x] Déclencher `app_games_hub_players_stats_rebuild(... dry_run=false, write=true ...)` hors rendu et sans changer les règles de score ni le fallback historique.
- [x] Journaliser `hub_historical_stats_init_start|skip|end|error` avec raisons et compteurs non sensibles.
- [x] Retirer l'outil web temporaire de diagnostic et son test associé.
- [x] Couvrir le contrat d'initialisation et l'absence de rebuild au rendu par `hub_players_stats_projection_contract_test.php`.
- [ ] Recette dev authentifiée: créer/retrouver un Hub historique terminé, vérifier init `stats_*`, second passage idempotent `already_current`, puis reload Hub Master sans fallback historique.

## PATCH 2026-07-30 - CLI rebuild stats Hub: garde environnement
- [x] Auditer `hub_players_stats_rebuild.php`, `global_config.php`, `lib_db.php` et les bootstraps CLI existants.
- [x] Identifier la cause: `SERVER_NAME` absent en CLI fait retomber `global_config.php` en `prod` avant connexion immédiate par `lib_db.php`.
- [x] Réutiliser la convention Global host-based en exigeant `--env=dev` et en injectant `global.dev.cotton-quiz.com` avant `global_config.php`.
- [x] Refuser avant connexion les environnements absents, invalides, `prod` et `production`.
- [x] Afficher avant connexion `Env`, base logique ciblée et mode, sans secret.
- [x] Conserver dry-run par défaut et `--write` explicite.
- [x] Couvrir le bootstrap CLI par `hub_players_stats_rebuild_cli_env_test.php` et adapter le contrat projection.
- [ ] Recette opérateur: lancer `php web/tools/hub_players_stats_rebuild.php --env=dev --hub-id=186 --dry-run --compare-legacy` après confirmation de l'accès DB dev.

## PATCH 2026-07-30 - Projection stats Hub persistée
- [x] Relire START, SITEMAP, SITEMAP.ndjson, DOCS_MANIFEST et le journal AI Studio raw avant patch.
- [x] Ajouter helpers de contrat `stats_*` sans auto-migration runtime.
- [x] Ajouter rebuild dry-run/write transactionnel depuis `games_hubs_sessions` puis `games_hubs_players_sessions`, borné aux mappings `active|completed` avec `id_hub_player`, `id_session` et `id_participation` prouvés.
- [x] Résoudre les contributions runtime Quiz/Blind Test/Bingo par `id_participation` puis `participant_key`, sans exiger `id_ep_player > 0` pour les guests.
- [x] Signaler orphelins, mappings sans résultat et équipes Blind Test non représentables sans créer de joueur ni fusionner par pseudo.
- [x] Ajouter `mark_dirty`, ranking dense lu depuis `stats_*`, source revision déterministe et comparaison legacy bornée.
- [x] Ajouter le CLI `global/web/tools/hub_players_stats_rebuild.php`.
- [x] Couvrir migration/helpers/CLI par `hub_players_stats_projection_contract_test.php`.
- [ ] Recette post-import phpMyAdmin: dry-run, compare, write, second write idempotent, inspection Hub Master.

## PATCH 2026-07-30 - Hub get_or_create: libération contexte inactif vide
- [x] Relire START, SITEMAP, SITEMAP.ndjson, DOCS_MANIFEST et le journal AI Studio raw avant patch.
- [x] Reconstituer depuis logs/DB que le retest quick-schedule était bloqué par un Hub exact `flag_active=0` sur la clé unique `(id_client, hub_date, context_type, id_operation_evenement)`.
- [x] Corriger `app_games_hub_get_or_create_for_context(...)` pour ne pas réactiver un Hub exact inactif trouvé après conflit d'insert.
- [x] Libérer seulement un contexte inactif vide de memberships actifs, joueurs actifs, lots et publication, puis retenter l'insert afin de créer un nouveau Hub.
- [x] Exposer un statut explicite `inactive_context_conflict` si le Hub inactif porte encore des données bloquantes.
- [x] Couvrir le contrat par assertion source dans `hub_identity_stability_contract_test.php`.
- [x] Vérifications locales: lint PHP ciblé OK; tests Hub identity et quick Hub service OK.
- [ ] Recette authentifiée: reproduire sur client `10` après nettoyage DB, vérifier création Hub active et membership de la session quick-schedule.

## PATCH 2026-07-30 - Agrégat Bingo: meilleure phase par partie
- [x] Relire START, SITEMAP, SITEMAP.ndjson, DOCS_MANIFEST et le journal AI Studio raw avant patch.
- [x] Confirmer les baselines Git demandées: `global`, `pro`, `games`, `play`, `www`, `documentation` alignés sur les HEAD attendus et sans modification locale.
- [x] Reconstituer le flux Global: `bingo_players` ajoute la participation de base, `bingo_phase_winners` fournissait les gains de phase, puis `award_player_points` ajoutait le score et les compteurs.
- [x] Corriger Bingo pour consolider par `session_id + identité canonique`, retenir uniquement la meilleure phase, ajouter une seule participation et un seul bucket `wins|second_places|third_places`.
- [x] Préserver Quiz, Blind Test, podium détaillé Bingo, session results et absence de persistance dans `games_hubs_players`.
- [x] Couvrir les combinaisons Ligne / Double ligne / Bingo dans `client_joueurs_dashboard_aggregate_ranking_test.php`.
- [x] Vérifications locales: lint PHP module/test OK; test Global du classement agrégé OK.
- [ ] Recette DB/authentifiée: Bingo où un même joueur gagne plusieurs phases, vérifier classement général Hub/Pro/WWW/Play et détail de session inchangé.

## PATCH 2026-07-29 - Classement agrégé compact Hub Play
- [x] Ajouter `app_client_joueurs_dashboard_compact_aggregate_identity_matches(...)`.
- [x] Ajouter `app_client_joueurs_dashboard_compact_aggregate_row_project(...)`.
- [x] Ajouter `app_client_joueurs_dashboard_compact_aggregate_from_rows(...)` avec Top rangs, joueur courant et voisins.
- [x] Ajouter `app_client_joueurs_dashboard_compact_aggregate_from_context(...)`.
- [x] Ajouter `app_client_joueurs_dashboard_get_compact_aggregate_for_period(...)` et `...for_event(...)`.
- [x] Ajouter l'option `skip_visual_podiums` pour éviter les podiums/photos visuels quand le contexte sert une projection compacte.
- [x] Couvrir le contrat via `games/web/tests/hub_compact_aggregate_test.php`.
- [ ] Recette produit: décider où et quand afficher ce classement compact côté Hub Play.

## PATCH 2026-07-28 - Renouvellement automatique: planificateur quick canonique
- [x] Relire START, SITEMAP, DOCS_MANIFEST, cartes Global/Games/Pro et journal AI Studio raw avant audit; aucune entree AI Studio ne signale un fichier de programmation hors workspace a recharger.
- [x] Tracer ajout rapide Hub Master/Dashboard: `quick_session_create` et `dashboard_quick_session_create` deleguent a `app_programming_quick_hub_create_from_game(...)`, puis `app_programming_quick_hub_suggestion_build(...)` et `app_programming_quick_theme_plan_build(...)`.
- [x] Tracer renouvellement Hub Master/Dashboard: `quick_session_theme_renew` et `session_theme_renewal_plan/apply` passent par `app_programming_theme_renewal_plan_for_session(...)` puis `app_programming_theme_renewal_apply_for_session(...)`.
- [x] Identifier la cause: le renouvellement utilisait encore l'historique 365 jours comme exclusion dure via `app_programming_theme_renewal_plan(...)`, alors que l'ajout rapide relachait deja l'historique par paliers `365/180/30/0`.
- [x] Brancher `app_programming_theme_renewal_plan_for_session(...)` sur `app_programming_quick_theme_plan_build(...)`, avec exclusion stricte de la selection courante, des exclusions temporaires et des selections actives du Programme Hub.
- [x] Garder jeu, format, mode, gabarit Quiz et guards Hub/edit-state existants; aucune creation de session ni changement de position Programme.
- [x] Adapter la validation d'apply: une proposition recente reste refusee s'il existe une alternative non recente compatible, mais elle est acceptee quand l'historique epuise toutes les alternatives strictement compatibles, en tenant compte des selections actives du Programme et des exclusions temporaires du clic courant, meme quand l'adaptateur transmet seulement `hub_id`.
- [x] Couvrir planner/apply sur fallback historique relache, refus recent quand une alternative fraiche existe, acceptation quand la seule alternative fraiche est deja dans le Programme actif ou dans les exclusions temporaires, et apply `hub_id` seul cote Pro.
- [x] Verifications locales: lint PHP programmation OK; tests planner, apply et quick Hub OK.
- [ ] Recette authentifiee: sur un compte a gros historique, renouveler depuis Hub Master et Dashboard Pro une session quick-add, verifier absence de doublon Programme et ordre inchange.

## PATCH 2026-07-28 - Service quick-add Hub: cutoff de reactivation
- [x] Auditer le service partage `app_programming_quick_hub_context_validate(...)`.
- [x] Ajouter la garde temporelle canonique `app_games_hub_temporal_state(...)` avant creation rapide Hub.
- [x] Refuser toute nouvelle session rapide apres `J+1 12:00` Europe/Paris avec code `HUB_QUICK_ADD_WINDOW_EXPIRED` et log `hub_quick_add_refused_after_cutoff`.
- [x] Conserver les reprises/lancements deja traites par le contrat Hub existant et ne pas modifier DB, scores, resultats, memberships ou identites Hub.
- [x] Couvrir le contrat depuis les tests Pro/Games qui consomment le service.

## PATCH 2026-07-28 - Classements saisonniers agrégés
- [x] Relire START, SITEMAP, SITEMAP.ndjson, DOCS_MANIFEST et le journal AI Studio raw avant patch.
- [x] Auditer `app_client_joueurs_dashboard_aggregate_ranking_from_leaderboards(...)`: score interne, rangs denses, égalité `score|count`, récence seulement en ordre d'affichage, identités stables et sources Quiz/Blind Test/Bingo.
- [x] Ajouter les alias contractuels `wins_count`, `podiums_count`, `participations_count`, `aggregate_score`, `last_result_at`.
- [x] Ajouter `app_client_joueurs_aggregate_stats_label(...)` pour le wording commun avec singulier/pluriel et valeurs nulles visibles.
- [x] Ajouter `app_client_joueurs_season_aggregate_ranking(...)` comme point d'entrée explicite du classement saisonnier.
- [x] Ajouter `app_client_joueurs_season_identity_key_resolve(...)`: fusion uniquement sur compte Play/Global fiable, repli Hub-local isolé par Hub, aucune fusion par pseudo/avatar/IP/device.
- [x] Exposer `identity_key`, `identity_source`, `identity_id` et `display_name` sur les lignes agrégées, et propager `id_hub`, `id_hub_player`, `id_ep_player`, `auth_identity_key`, `session_ids` depuis les leaderboards construits.
- [x] Dédoublonner les doublons même identité canonique + même partie quand `session_ids` est disponible.
- [x] Confirmer le contrat Blind Test: les équipes restent des participants équipe distincts, sans redistribution aux membres.
- [x] Remplacer le wording visible agrégé `participation(s)` par `partie(s)` sans renommer les champs techniques.
- [x] Corriger le compteur canonique de podiums: `podiums_count`/`podiums` excluent les victoires, `top3_count` garde le diagnostic Top 3, et Bingo est borné à un résultat visible par partie.
- [x] Versionner le cache Place FO pour éviter une projection saisonnière obsolète.
- [x] Couvrir les nouveaux alias et le wording dans `client_joueurs_dashboard_aggregate_ranking_test.php`.
- [x] Vérifications locales: lint PHP ciblés OK; test Global du classement agrégé OK.
- [ ] Recette DB/authentifiée: même client/saison sur Pro, WWW Place et Play, comparer ordre, rangs, victoires, podiums et participations.

## PATCH 2026-07-28 - Hub/session: fenetre J+1 midi
- [x] Centraliser le fallback plateforme explicite `Europe/Paris` dans `app_platform_business_timezone()`.
- [x] Ajouter la primitive pure `app_temporal_window_state(...)` recevant `DateTimeZone` et `now` injectable.
- [x] Faire deleguer `app_session_get_chronology(...)` a la fenetre `J 00:00:00` inclus -> `J+1 12:00:00` exclu.
- [x] Exposer l'etat temporel Hub depuis `games_hubs.hub_date` sans migration DB ni snapshot timezone.
- [x] Refuser les nouveaux lancements Hub apres cutoff tout en autorisant les reprises prouvees par marqueurs persistants.
- [x] Couvrir minuit, `11:59:59`, `12:00:00`, fuseau runtime different et changement d'heure dans `temporal_window_state_test.php`.

## PATCH 2026-07-28 — Hub agrégat: podium de présentation sans victoires
- [x] Conserver le champ technique `podiums` comme Top 3 total, victoire comprise.
- [x] Ajouter `display_podium_count = second_places + third_places` dans chaque ligne `aggregate_ranking`.
- [x] Appliquer le contrat aux joueurs et aux équipes sans modifier score, rangs, tri, participations ni identités.
- [x] Renforcer `client_joueurs_dashboard_aggregate_ranking_test.php` sur joueur, équipe, payload, score et rang inchangés.
- [x] Vérifications locales: lint PHP module OK; test Global du classement agrégé OK.

## PATCH 2026-07-28 — Logs Hub agrégat: anomalie visible
- [x] Relire START, SITEMAP, DOCS_MANIFEST et le journal AI Studio raw avant patch.
- [x] Corriger le contrat logger: `hub_aggregate_ranking_loaded` reste debug-only; `hub_aggregate_ranking_unavailable` n'est plus debug-only afin de rester visible quand Games l'émet pour un agrégat attendu mais absent.
- [x] Renforcer `hub_identity_stability_contract_test.php` pour vérifier que `loaded` est dans la liste debug-only et que `unavailable` n'y est pas.
- [x] Vérifications locales: lint PHP module/test OK; test identité Hub OK.
- [ ] Recette logs authentifiée: sans debug, aucun `loaded` ordinaire; un cas attendu-mais-absent doit rester visible si reproduit.

## PATCH 2026-07-28 — Logs Hub et fallbacks notices
- [x] Relire START, SITEMAP, DOCS_MANIFEST et le journal AI Studio raw avant patch.
- [x] Rendre `client_get_photo_src(...)` et `app_client_get_photo_src(...)` robustes aux résultats DB vides ou requêtes en échec, en conservant les fallbacks existants.
- [x] Rendre `app_saison_get_id(...)` robuste à l'absence de saison en retournant le fallback entier historique `0`.
- [x] Corriger la référence `$id_session` non définie du message administrateur désactivé en utilisant l'id créé `$id_championnat_session`.
- [x] Passer les logs Hub informatifs ordinaires (`aggregate loaded`, membership resolved, branding lookup resolved) en debug-only, tout en gardant les erreurs, ambiguïtés, incohérences et l'anomalie `aggregate unavailable` attendue-mais-absente dans `error_log`.
- [x] Ajouter `client_photo_src_test.php` et renforcer les tests quick Hub / identité Hub.
- [x] Vérifications locales: lint PHP ciblés OK; tests photo client, quick Hub, idempotence, identité Hub et branding cascade OK; `git diff --check` Global OK.
- [ ] Recette DB/authentifiée: quick schedule réel avec saison absente simulée ou date hors saison, hydrateur branding sans `hub_debug`, puis avec `hub_debug=1`.

## PATCH 2026-07-27 — Classement agrégé Hub canonique
- [x] Appliquer le rectificatif d'architecture: Global devient la source canonique du classement agrégé Hub, exposé dans `aggregate_ranking`.
- [x] Ajouter `app_client_joueurs_dashboard_aggregate_ranking_from_leaderboards(...)` dans le contexte joueurs, sans modifier les podiums de session.
- [x] Fusionner les contributions par identité stable, avec normalisation `hub_player:{id}` / `player:{id}` vers `player:{id}` et sans fusion par nom pour les contributions non prouvées.
- [x] Additionner les scores normalisés par jeu et trier `score DESC`, `count DESC`, `latest_date DESC`, `label ASC`.
- [x] Corriger la clé de rang dense à `score|count`; `latest_date` ordonne seulement les ex aequo et ne modifie plus le rang.
- [x] Propager les statistiques attendues par le Hub: victoires, secondes/troisièmes places, podiums, participations, nombre de jeux et champs photo disponibles.
- [x] Couvrir le contrat dense `1,1,1,2,2,3`, la fusion d'identité Hub, les ex aequo score/count avec dates différentes, le count comme critère métier, l'ordre date puis label et les compteurs d'égalité dans `client_joueurs_dashboard_aggregate_ranking_test.php`.
- [x] Vérifications locales: lint PHP du module clients OK; test Global du classement agrégé OK.

## DOC 2026-07-27 — Hubs: identité stable et rattachement canonique
- [x] Documenter que `games_hubs` porte l'identité persistante du Hub: id, token, label, publication, lots, branding, joueurs, sessions et historique.
- [x] Documenter que `games_hubs_sessions` est l'autorité canonique du rattachement session-Hub.
- [x] Documenter qu'une lecture Hub est non destructive: pas de création, réconciliation, désactivation de membership ou déplacement implicite de session.
- [x] Documenter que `id_operation_evenement` et `context_type` sont legacy/compatibilité et ne peuvent pas remplacer un Hub existant, désactiver un membership actif ou déplacer une session.
- [x] Séparer le backfill legacy de la commande métier d'ajout: ajouter `app_games_hub_session_membership_ensure(...)`, idempotent pour le Hub cible et fail-closed si compte/date/contexte divergent ou si un autre Hub possède déjà la session active.
- [x] Faire déléguer le quick-add partagé et la Bibliothèque Pro à cette primitive; couvrir Hub déjà peuplé, même Hub actif, réactivation inactive et conflit inter-Hubs sans modifier la réconciliation legacy.
- [x] Documenter qu'un changement dynamisation/gamification conserve le même Hub, son token, ses joueurs, lots, publication, branding, sessions et historique.
- [x] Documenter que les wordings visibles peuvent suivre l'usage courant du compte sans modifier l'identité persistante du Hub.
- [x] Mettre à jour README Global, README Games, README Pro, TASKS Global/Games/Pro, HANDOFF et CHANGELOG.
- [x] Régénérer SITEMAP.txt, SITEMAP.ndjson et les index via `npm run docs:sitemap`.

## PATCH 2026-07-27 — Hubs: contrat serveur `presentation_mode`
- [x] Ajouter à `games_hubs` les colonnes `presentation_mode` et `presentation_updated_at`, avec défaut rétrocompatible `session`.
- [x] Normaliser les modes autorisés: `session`, `hub_podium`, `hub_idle`.
- [x] Ajouter `app_games_hub_presentation_mode_set(...)` pour écrire la présentation Hub sans modifier `active_session_id`.
- [x] Faire de `app_games_hub_focus_set_active(...)` une priorité runtime qui remet `presentation_mode=session` pendant l'écriture du focus.
- [x] Étendre `app_games_hub_presentation_resolve(...)` avec un champ `mode` et une cible distincte `hub_podium`, afin que Hub Play puisse consommer le même contrat dans une passe ultérieure.
- [x] Ne pas modifier les WebSockets, les scores, les résultats, les podiums de session, le branding ni les mappings joueurs.
- [x] Vérifications locales: lint PHP Hub Global OK; `hub_presentation_mode_contract_test.php` OK.
- [ ] Recette DB/authentifiée: vérifier l'ALTER automatique sur un Hub existant, bouton trophée, launch/reprise et retour endpoint `active_launched_session`.

## PATCH 2026-07-26 — Branding Canvas Hub: fallback Cotton complet hors logo
- [x] Auditer la divergence restante: Hub Master complète couleurs/police en vue (`#240445`, `#bba9ff`, `#FFFFFF`, `Poppins`) alors que le resolver Global ne complétait dynamiquement que le visuel Cotton sans ligne Hub persistée.
- [x] Compléter `app_games_hub_branding_apply_cotton_defaults(...)` avec les couleurs et police Cotton communes, uniquement sur champs vides après cascade session -> Hub -> réseau -> compte.
- [x] Auditer la provenance du visuel historique: les Canvas injectent `branding-qz/bt/bm` comme `DEFAULT_THEME`, et certaines couches session peuvent contenir une copie de ce visuel sans provenance DB explicite.
- [x] Marquer les visuels session qui correspondent aux assets Canvas historiques connus par hash/URL, puis les ignorer uniquement dans la cascade Hub officielle.
- [x] Exploiter les logs Global/Games rechargés: des sessions rattachées au Hub pouvaient finir avec un branding vide (`effective_branding_id=0`) si l'agrégat Hub était abandonné avant les defaults Cotton.
- [x] Garantir que `app_games_hub_branding_get(...)` et `app_session_branding_get_detail(...)` matérialisent les defaults Cotton dès qu'un Hub est résolu, même sans contexte client/branding Hub exploitable.
- [x] Capturer le JSON réel session `27126`: Hub résolu et couleurs/police Cotton présentes, mais `visuel:""`; Canvas retombait donc légitimement sur `DEFAULT_THEME`.
- [x] Découpler l'URL publique du visuel Cotton Hub du contrôle filesystem local pour ne plus renvoyer un fallback visuel vide quand l'asset public est disponible.
- [x] Capturer le JSON réel session `27129` après nouveau reload logs: même signature que `27126`, Hub `178`, `membership_source=quick_hub_create`, couleurs/police Cotton, mais `visuel:""`.
- [x] Ajouter une garde finale dans `app_branding_ajax.php`: tout payload avec `_resolved_hub_id>0` et `visuel` encore vide reçoit le visuel Cotton Hub à la frontière JSON.
- [x] Auditer l'hydrateur Games Organizer/Player/Remote: le merge consomme le payload effectif sans exiger `id_branding>0`; Organizer/Player ne retombent sur `DEFAULT_THEME` que si le visuel distant est vide.
- [x] Corriger séparément le notice Blind Test quand `blindtest_sessions` n'existe pas encore; sans lien prouvé avec le branding.
- [x] Conserver le contrat sans logo Cotton fallback: `logo.img_src` reste vide si aucune couche session/Hub/réseau/compte ne fournit de logo.
- [x] Ne créer aucune ligne `general_branding` session ou Hub; le fallback reste résolu à la lecture.
- [x] Couvrir le contrat dans `hub_operation_branding_cascade_test.php`.
- [x] Vérifications locales: lint PHP Hub/test OK; test cascade Hub OK.
- [ ] Recette HTTP/authentifiée: comparer Organizer, Player, Remote et Hub Master sur une session Hub jamais personnalisée, puis avec réseau/compte et Hub explicite.

## PATCH 2026-07-26 — Classements Hub: identité joueur canonique
- [x] Auditer la chaîne Hub: `games_hubs_players.id` -> `app_games_hub_session_player_key(...)` -> `player_register` runtime -> `games_hubs_players_sessions.participant_key/id_participation`.
- [x] Confirmer que les leaderboards Global exposaient encore des identités runtime par jeu, ce qui pouvait séparer un même joueur Hub entre Quiz et Blind Test.
- [x] Lire `games_hubs_players_sessions` dans le contexte joueurs pour mapper `id_session + id_participation/player_id` vers `hub_player:{id_hub_player}`.
- [x] Normaliser Quiz, Blind Test solo et Bingo sur cette identité Hub quand le mapping est prouvé.
- [x] Conserver les équipes Blind Test comme participants équipe distincts, sans redistribution aux membres.
- [x] Ne pas fusionner par nom les contributions runtime sans mapping Hub fiable.
- [x] Vérifications locales: lint PHP `app_clients_functions.php` OK; test Games Hub settings OK.
- [ ] Recette navigateur authentifiée: Quiz + Blind Test + Bingo avec mêmes joueurs Hub, homonymes, équipe Blind Test et live inscrits inchangé.

## PATCH 2026-07-26 — Hubs: origine membership du Programme
- [x] Auditer `app_games_hub_sessions_get(...)` et confirmer que la jointure `games_hubs_sessions` ne propageait pas explicitement `membership_source`.
- [x] Sélectionner `ghs.membership_source AS hub_membership_source` dans la requête Programme canonique.
- [x] Conserver l'origine persistée comme source unique de vérité pour distinguer quick-add Hub, dashboard et legacy.
- [x] Couvrir via le test Games de modèle Hub qui appelle réellement `app_games_hub_sessions_get(...)`.
- [x] Vérifications locales: lint PHP Hub Global OK; contrat quick Hub Global OK.
- [ ] Recette DB authentifiée: contrôler une session créée après patch via ajout rapide Hub Master et vérifier la propagation `hub_membership_source=quick_hub_create`.

## PATCH 2026-07-26 — Hubs: métadonnées de séries Quiz exposées
- [x] Relire le modèle `app_games_hub_sessions_get(...)` consommé par Games Hub Master.
- [x] Exposer `hub_quiz_series_label` et `hub_quiz_series_names` depuis le détail jeu Quiz déjà calculé.
- [x] Conserver `hub_theme_label` comme libellé principal compact (`4 séries`) et fournir les noms de séries séparément pour l'UI.
- [x] Vérifications locales: lint PHP Hub Global OK; contrat `programming_quick_hub_service_contract_test.php` OK.
- [ ] Recette navigateur: vérifier que les cartes Hub Master affichent les noms des séries Quiz après chargement serveur et après renouvellement de thématique.

## PATCH 2026-07-26 — Ajout rapide Hub: token compatible runtime Quiz/Blind Test
- [x] Comparer le générateur de token quick Hub avec `quick-schedule`: le chemin classique utilise généralement `session_id() . uniqid()` alors que le portage Hub ajoutait 18 caractères de hash.
- [x] Vérifier le contrat DB: `championnats_sessions.id_securite` est `varchar(255)`, mais `cotton_quiz_sessions.session_id` et `blindtest_sessions.session_id` sont `varchar(64)`.
- [x] Identifier pourquoi Bingo sert de témoin fonctionnel: son statut runtime n'est pas stocké dans `cotton_quiz_sessions` / `blindtest_sessions`.
- [x] Borner les tokens créés par `app_programming_quick_hub_create_from_proposal(...)` à 64 caractères via `app_programming_quick_hub_session_security_id_generate(...)`.
- [x] Couvrir la longueur du token dans `programming_quick_hub_service_contract_test.php`.
- [x] Recette utilisateur après déploiement Global seul: le parcours signalé fonctionne à nouveau; aucun patch Games n'est requis pour cette régression.
- [ ] Recette DB authentifiée complémentaire: vérifier que les nouvelles sessions quick Hub Quiz/Blind Test ont un `id_securite` <=64, puis que la ligne runtime est créée et mise à jour.

## PATCH 2026-07-26 — Ajout rapide Hub: format/mode transverses au Programme
- [x] Corriger la déduction de format pour ne plus la limiter aux sessions du même jeu.
- [x] Introduire une clé canonique de format Programme: `short` pour 20 titres / 2 séries et `standard` pour 40 titres / 4 séries.
- [x] Traduire cette clé vers le jeu ajouté: Blind/Bingo `id_format=5/2`, Quiz `id_format=5/2` et `quiz_pick_count=2/4`.
- [x] Conserver la majorité du mode papier/smartphone sur toutes les sessions éligibles du Programme.
- [x] Couvrir les cas Blind Test court -> Quiz/Bingo et Quiz standard -> Bingo/Blind dans `programming_quick_hub_service_contract_test.php`.
- [x] Vérifications locales: lint PHP programmation/test OK; tests quick Hub, recommandation, idempotence, planner et apply OK.
- [ ] Recette DB authentifiée: depuis dashboard Pro et Hub Master, ajouter un jeu différent dans un Programme homogène court/standard et vérifier format + mode de la session créée.

## PATCH 2026-07-26 — Quiz auto history: libellé de secours culture G
- [x] Confirmer que les builders `T history` / `N history` gardent le remplissage générique quand le stock `history_pm5` est insuffisant.
- [x] Ajouter une validation post-génération des 6 questions contre la règle `jour_associe` à ±5 jours de la date de jeu.
- [x] Persister la série sous le nom exact `Mix culture G` quand toutes les questions ne respectent pas la règle history, tout en conservant le token temporaire `T...` ou `N...`.
- [x] Adapter aussi le contexte numérique persistant de `type=history_events` vers `type=culture_g` dans ce cas.
- [x] Couvrir le contrat avec `quiz_auto_history_label_contract_test.php`.
- [x] Vérifications locales: lint PHP Quiz/test OK; tests quick Hub, planner et apply OK.
- [ ] Recette DB authentifiée: provoquer un stock history insuffisant sur un ajout rapide Quiz dashboard/Hub et vérifier que la première série affiche `Mix culture G`.

## PATCH 2026-07-26 — Ajout rapide Hub: parité anti-répétition du plan
- [x] Relire les RAW obligatoires, cartes Global/Pro/Games, dernier handoff et journal AI Studio public.
- [x] Auditer le flux quick-schedule Pro: `start_quick_schedule_theme_payloads_prepare(...)` prépare les payloads, `start_auto_pick_themes_for_dates(...)` exclut historique et choix déjà faits dans le lot pour Blind/Bingo, et Quiz passe par `start_auto_pick_quiz_series_payload(...)`.
- [x] Auditer le flux ajout rapide Hub: Pro et Games délèguent à `app_programming_quick_hub_create_from_game(...)`, qui appelait `app_programming_quick_hub_suggestion_build(...)` sans exclure les sélections déjà présentes dans le Programme.
- [x] Expliquer le doublon Quiz observé: les sessions Hub servaient au mode/format/horaire, mais leurs `lot_ids` n'étaient pas convertis en exclusions; deux clics successifs pouvaient donc reprendre les mêmes quatre `L...`.
- [x] Aligner la source catalogue de l'ajout rapide sur le quick-schedule: catalogue Cotton natif + communauté promue/certifiée Cotton, sans contenus client ni public générique dans le fallback SQL Global.
- [x] Ajouter `app_programming_quick_theme_plan_build(...)` comme primitive Global de planification avec catalogue, historique, exclusions temporaires, sélections existantes du Programme et sélections déjà choisies dans le même plan.
- [x] Ajouter `app_programming_quick_existing_program_selections_from_sessions(...)` pour reconstruire les sélections canoniques depuis les sessions serveur: Blind Test `id_produit`, Bingo playlist catalogue source, Quiz `lot_ids` ordonnés.
- [x] Brancher `app_programming_quick_hub_suggestion_build(...)` sur la primitive avec `requested_count=1` et `existing_program_selections` issues des sessions actives du Hub.
- [x] Refuser par `PROPOSAL_STALE` une proposition signée dont les clés ne correspondent plus au plan recalculé côté serveur avant création.
- [x] Couvrir le cas Quiz avec un Programme existant `L701,L702,L703,L704` et un catalogue `L701..L708`: l'ajout rapide doit proposer `L705,L706,L707,L708`.
- [x] Vérifications locales: lint PHP programmation OK; tests quick Hub, recommandation, idempotence, planner et apply OK.
- [ ] Recette DB authentifiée: ajouter trois Cotton Quiz successifs depuis dashboard Pro puis Hub Master sur le même Hub et vérifier que les compositions ne répètent pas les slots déjà actifs tant que le catalogue offre des alternatives.

## PATCH 2026-07-26 — Ajout rapide Quiz Hub: fallback catalogue robuste
- [x] Relire les RAW obligatoires, cartes Global/Pro/Games, dernier handoff et journal AI Studio public.
- [x] Reconstituer le flux historique Pro: `start_quick_schedule_theme_payloads_prepare(...)` appelle `start_auto_pick_quiz_series_payload(...)`, lui-même alimenté par le catalogue Bibliothèque `clib_list_get(..., 'cotton', ..., 'themes')`.
- [x] Localiser le point où la donnée devient vide dans Global: `app_programming_quick_hub_suggestion_build(...)` reçoit zéro candidat normalisé depuis `app_programming_theme_renewal_catalog_candidates_get(...)`, avant tout filtrage de disponibilité ou builder Quiz.
- [x] Corriger le fallback SQL Quiz pour ne joindre `community_items` que si toutes les colonnes du contrat existent.
- [x] Ajouter un fallback explicite vers `questions_lots` si le SQL enrichi échoue malgré le contrôle de contrat.
- [x] Borner le fallback `questions_lots` aux colonnes disponibles: `position` est optionnelle et les échecs SQL de fallback sont journalisés par `CATALOG_CANDIDATES_SQL_FAILED`.
- [x] Conserver le contrat Pro/Games unique: aucun patch séparé dans les adaptateurs, aucun format/thème fiable depuis le navigateur.
- [x] Corriger la notice `app_cotton_quiz_session_get_detail(...)` quand une session Quiz n'a pas encore de ligne runtime `cotton_quiz_sessions`.
- [x] Couvrir le cas `community_items` incomplet dans `programming_quick_hub_service_contract_test.php`.
- [x] Vérifications locales: lint PHP programmation/Quiz/test OK; tests quick Hub, recommandation, idempotence, planner/apply OK; `git diff --check` Global OK.
- [ ] Recette DB authentifiée: rejouer Pro et Games Master sur Hub 167 / client 2311, vérifier `candidate_count>=4`, création Quiz et absence de notice ligne 24.

## PATCH 2026-07-25 — Service d'ajout rapide Hub partagé
- [x] Relire les RAW obligatoires et le journal AI Studio public avant modification.
- [x] Créer un service métier sans dépendance UI/Pro session pour l'ajout rapide Hub.
- [x] Exposer `app_programming_quick_hub_create_from_game(...)` comme entrée de haut niveau commune Pro/Games pour créer directement depuis un jeu.
- [x] Exposer `app_programming_quick_hub_suggestion_build(...)` pour proposer une thématique compatible sans création.
- [x] Exposer `app_programming_quick_hub_create_from_proposal(...)` pour créer depuis proposition signée/revalidée.
- [x] Résoudre côté serveur jeux autorisés, mode, format, horaire, contact/offre et thématique.
- [x] Reprendre le contrat Quiz quick-schedule Pro: catalogue incluant les séries promues Cotton via `community_items`, proposition catalogue best-effort non vide, builders papier/numérique courts et standards, préparation cible de quatre candidats pour le court numérique et matérialisation des lots `T` / `N` après création de l'id session.
- [x] Signer le payload de proposition, gérer expiration, falsification et scope Hub/compte.
- [x] Réutiliser l'idempotence quick-schedule existante pour protéger le double envoi.
- [x] Réconcilier, assurer explicitement puis vérifier la persistance dans `games_hubs_sessions`.
- [x] Nettoyer `suggestion` et `proposal_token` dans le retour de l'entrée directe pour éviter leur transport par les navigateurs.
- [x] Ne pas modifier `games_hubs.active_session_id` ni dépendre d'une session navigateur Pro.
- [x] Couvrir le contrat dans `programming_quick_hub_service_contract_test.php`.
- [x] Vérifications locales: lint PHP du service/test OK; tests quick Hub, recommandation rapide, idempotence, renouvellement planner/apply OK.
- [ ] Recette DB authentifiée: créer réellement depuis Pro puis Games Master sur un Hub actif, vérifier ligne session, relation Hub, replay idempotent et absence de focus modifié.

## PATCH 2026-07-24 — Fallback Cotton Hub sans logo
- [x] Auditer les résidus des patchs annulés: anciens flags d'affichage, champs de provenance et options de neutralisation absents du code fonctionnel.
- [x] Modifier `app_games_hub_branding_apply_cotton_defaults(...)` pour ne plus compléter `logo.img_src`.
- [x] Conserver le fallback visuel Cotton et la cascade session -> Hub actif -> réseau -> compte.
- [x] Conserver le fallback visuel Cotton dans le chemin Hub direct des sessions officielles Games, même sans ligne branding Hub explicite.
- [x] Matérialiser le visuel Cotton fallback dans les snapshots de démo sans jamais copier de logo Cotton.
- [x] Couvrir le contrat dans `hub_operation_branding_cascade_test.php`.
- [x] Vérifications locales: lint PHP Hub OK; test cascade Hub OK.
- [ ] Recette DB/authentifiée: session Hub sans logo à chaque couche = aucun logo; puis Hub/réseau/compte avec logo = logo affiché.

## PATCH 2026-07-24 — Régression branding Hub runtime
- [x] Auditer la résolution `CanvasBrandingHydrator` / `branding_context=game`, le rollback logo et le flux démo dashboard.
- [x] Confirmer la cause: `app_session_branding_get_detail(...)` ne tentait le Hub que si le branding session était totalement absent, puis ne chargeait que la couche Hub isolée.
- [x] Restaurer le merge effectif session + Hub + réseau + compte pour les sessions officielles rattachées à un Hub.
- [x] Borner la résolution branding Hub runtime aux relations `games_hubs_sessions.status='active'`, sans réconciliation legacy date/opération.
- [x] Couvrir le merge session partiel -> Hub -> réseau/compte et le contrat actif-only dans `hub_operation_branding_cascade_test.php`.
- [x] Vérifications locales: lints PHP ciblés OK; test cascade Hub OK; marqueurs de masquage logo absents.
- [ ] Recette HTTP/authentifiée: comparer les payloads Organizer, Player et Remote pour session autonome, session Hub sans branding session propre et session Hub avec branding session partiel.

## PATCH 2026-07-24 — Snapshot démo Hub: branding et playlist Bingo
- [x] Auditer le flux `session_duplicate` déclenché par le dashboard Pro et les helpers branding/session concernés.
- [x] Ajouter `app_general_branding_snapshot_to_target(...)` pour matérialiser un branding effectif merged vers un branding session autonome, avec copie d'assets depuis les sources de cascade existantes.
- [x] Ajouter `app_bingo_musical_playlist_client_duplicate_for_demo(...)` pour cloner la playlist client préparée, l'ordre `position` et les numéros Bingo, sans relancer la recommandation catalogue.
- [x] Conserver la génération de grilles démo Bingo séparées et la limite démo à 2 joueurs portée par `championnats_sessions.nb_joueurs_max`.
- [x] Vérifications locales: lint PHP des helpers branding/Bingo OK; test dashboard Pro consommateur OK.
- [ ] Recette DB/authentifiée: lancer une démo depuis un Hub avec branding incomplet session, vérifier les médias session et comparer l'ordre Bingo source/démo.

## PATCH 2026-07-24 — Branding Canvas: fallback client chargé dans global_ajax
- [x] Relire `global/logs/error_log` après rechargement et confirmer les 500 `CanvasBrandingHydrator` causés par `Call to undefined function app_client_branding_get_detail()`.
- [x] Charger explicitement `app/modules/entites/clients_branding/app_clients_branding_functions.php` dans `global_ajax.php` avant le fallback session branding réseau/compte.
- [x] Couvrir le contrat dans `hub_operation_branding_cascade_test.php`.
- [x] Vérifications locales: lint PHP `global_ajax.php` et test cascade Hub OK.
- [ ] Recette HTTP authentifiée: rejouer l'hydrateur branding Canvas sur une session Hub puis une session sans Hub pour vérifier absence de 500 et cascade réseau/compte.

## PATCH 2026-07-24 — Fallbacks Cotton partagés pour accroche/description Hub
- [x] Auditer les RAW obligatoires (`START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`) et le journal AI Studio raw avant modification.
- [x] Identifier les champs réels `games_hubs_publication.tagline` et `games_hubs_publication.description`, leur sauvegarde via `app_games_hub_publication_save(...)` et les fallbacks reconstruits dans Global/Pro.
- [x] Ajouter `app_games_hubs_publication_defaults(...)` et `app_games_hubs_publication_resolve(...)` dans le module Hub Global, bornés au français.
- [x] Distinguer pour chaque champ `raw`, `effective` et `source` (`hub` ou `cotton`) sans copier les textes Cotton en base.
- [x] Préserver le titre hors du nouveau fallback éditorial.
- [x] Exposer la résolution dans le contexte public comme donnée future sans modifier les clés legacy consommées par les pages publiques.
- [x] Couvrir le contrat dans `hub_publication_prizes_contract_test.php`.
- [x] Vérifications locales: lint PHP Hub/test OK; test contrat Hub publication/lots OK.
- [ ] Patch suivant: faire consommer les valeurs effectives par `www` pages Hub/événement, anciennes pages événement, Hub Master/Play et payloads JSON publics.

## PATCH 2026-07-23 — Quiz quick-schedule court
- [x] Ajouter le helper papier court `qz_build_paper_quick_short_lot_ids_csv(...)` pour générer uniquement la série historique `T` puis le lot `L`.
- [x] Ajouter le helper numérique court `qz_build_numeric_quick_short_lot_ids_csv(...)` pour tenter `N history_events` uniquement sous garde-fou admin `id_client=10`, conserver les règles prêtes pour déploiement quand la DB certifiée sera suffisante et retomber sur `L + L`.
- [x] Journaliser sobrement les succès/fallbacks techniques sans message visible côté interface.
- [x] Préserver les constructeurs Standard existants `qz_build_paper_auto_lot_ids_csv(...)` et `qz_build_numeric_auto_pack_result(...)`.
- [x] Vérification locale: lint PHP du helper Quiz OK; tests quick-schedule/recommandation/idempotence/récurrence consommateurs OK.
- [ ] Recette DB: vérifier avec contenu numérique insuffisant que le court numérique persiste exactement deux lots `L` valides.

## PATCH 2026-07-23 — Assets Cotton Hub canoniques
- [x] Créer la source logique partagée `app_cotton_hub_default_*` pour chemin filesystem et URL publique du logo/visuel Cotton Hub.
- [x] Placer les assets canoniques sous `global/web/assets/branding/hubs/`.
- [x] Faire renseigner le fallback visuel Hub par `app_games_hub_branding_apply_cotton_defaults(...)`; le logo Cotton n'est plus un fallback de branding.
- [x] Supprimer le fallback SVG inline côté Global pour les Hubs.
- [x] Couvrir le contrat dans `hub_operation_branding_cascade_test.php`.
- [x] Vérifications locales: lint PHP Hub OK, test cascade Hub OK.
- [ ] Remplacer les assets reconstruits depuis les fallbacks produit par les deux fichiers provisoires demandés quand ils seront présents dans `_assets_to_integrate`.

## PATCH 2026-07-23 — Duplication branding Hub: assets sur id_ref
- [x] Auditer la convention `general_branding` type 5: relation canonique `id_ref=games_hubs.id`, fallback historique `id_related`.
- [x] Corriger `app_general_branding_duplicate_to_target(...)` pour résoudre le dossier source via `app_general_branding_row_related_get(...)`.
- [x] Conserver la préparation d'assets historique avec staging/backup via `app_general_branding_prepare_target_assets(...)`.
- [x] Couvrir le contrat dans `hub_operation_branding_cascade_test.php`.
- [x] Vérifications locales: lint PHP helper/test OK, test cascade Hub OK.
- [ ] Recette DB/filesystem: upload réel logo/visuel Hub puis copie vers branding compte et contrôle des fichiers générés.

## PATCH 2026-07-22 — Hub dashboard terminé: verrouillage mutations
- [x] Ajouter `app_games_hub_dashboard_is_completed(...)` pour qualifier un Hub dashboard terminé depuis ses sessions actives.
- [x] Ajouter `app_games_hub_session_belongs_to_completed_hub(...)` borné à `games_hubs_sessions.status='active'`, sans heuristique date/client/opération.
- [x] Refuser `app_games_hub_prizes_save(...)` par `HUB_NOT_EDITABLE` avant toute écriture sur Hub terminé.
- [x] Refuser `app_programming_theme_renewal_plan_for_session(...)` et `app_programming_theme_renewal_apply_for_session(...)` par `SESSION_NOT_EDITABLE` / `hub_completed`, même sans `hub_id` explicite.
- [x] Couvrir les contrats dans `hub_publication_prizes_contract_test.php`, `session_theme_renewal_planner_test.php` et `session_theme_renewal_apply_test.php`.
- [x] Vérifications locales: lint PHP Global OK, tests ciblés Global OK.
- [ ] Recette DB/authentifiée: appel direct lots/personnalisation/renouvellement sur Hub terminé et renouvellement autonome hors Hub.

## PATCH 2026-07-22 — Résultats Bingo: composition runtime exclusive
- [x] Séparer dans `app_session_results_bingo_player_labels_get(...)` les maps de relabeling exact, les fallbacks exacts de session et les fallbacks grille legacy.
- [x] Faire de `bingo_players.session_id = id_securite` la source exclusive de composition et de `players_count` dès qu'elle contient au moins un joueur.
- [x] Conserver la réparation historique uniquement pour les labels runtime vides/génériques, par `game_player_id` ou `game_player_key`, sans écraser un nom runtime valide.
- [x] Supprimer la fusion additive des labels legacy absents de la liste runtime.
- [x] Conserver le fallback runtime absent: participations exactes `id_championnat_session`, puis grilles playlist seulement avec les bornes historiques non-démo / type Bingo / playlist non partagée.
- [x] Ajouter `web/tests/session_results_bingo_membership_contract_test.php`.
- [x] Vérifications locales: lint PHP helper/test OK, test contrat Bingo OK, test dashboard Pro consommateur OK, `git diff --check` Global OK.
- [ ] Recette DB/authentifiée: vérifier le cas observé 4 joueurs runtime + 4 labels historiques étrangers, puis une archive Bingo sans runtime et une playlist partagée.

## PATCH 2026-07-22 — Compteurs Hub de participations globales
- [x] Ajouter `app_games_hub_participation_counters_get(...)` comme agrégat partagé Hub, sans migration ni write path.
- [x] Borner les sessions sources aux memberships actifs `games_hubs_sessions`, sans déduction par date, client ou opération.
- [x] Dédoublonner les participations probables par identité stable `player:{id_joueur}` / `team:{id_equipe}` sur tout le Hub.
- [x] Exposer `present_count` depuis les joueurs Hub actifs pour le jour J.
- [x] Exposer `effective_count` depuis les mappings de session avec participation runtime prouvée (`id_participation > 0`, statut `active|completed`) pour les soirées terminées.
- [x] Documenter les sources actuelles pour permettre de remplacer plus tard l'attendu par une inscription directe Hub canonique.
- [x] Ajouter le test contractuel `hub_participation_counters_contract_test.php`.
- [x] Vérifications locales: lint PHP Hub/test OK, test compteur OK, test suppression Hub existant OK, `git diff --check` Global OK.
- [ ] Recette DB/authentifiée: comparer les totaux sur un Hub avec même joueur/équipe annoncé sur plusieurs sessions et un joueur Hub sans mapping runtime après événement.

## PATCH 2026-07-22 — Suppression complète canonique Hub
- [x] Créer `app_session_delete_canonical(...)` comme service métier réutilisable de suppression unitaire de session.
- [x] Corriger le nettoyage Quiz V1 pour utiliser l'ID session résolu lors de la suppression des participations équipes.
- [x] Créer `app_games_hub_delete_complete(...)`, ciblé par `games_hubs.id` et protégé par verrou SQL applicatif.
- [x] Ajouter l'état persistant de reprise sur `games_hubs`: `delete_operation_token`, `delete_step`, `delete_started_at`, `delete_error_at`.
- [x] Bloquer la réutilisation quick-schedule/résolution contexte d'un Hub `hub_status='deleting'`.
- [x] Valider propriétaire, membership actif, absence d'autre Hub actif et état éditable de chaque session avant mutation destructive.
- [x] Supprimer les sessions membres via le service session canonique, puis joueurs/mappings Hub, publication, lots, branding Hub type 5, relations et racine Hub.
- [x] Conserver les sessions autonomes, autres Hubs de même date et événements legacy non prouvés exclusifs.
- [x] Ajouter `web/tests/hub_delete_service_contract_test.php`.
- [x] Vérifications locales initiales: lint Hub/sessions/test OK, test contrat OK.
- [ ] Recette DB/authentifiée: suppression réelle, reprise après échec simulé, reprogrammation même date avec nouvel id/token et zéro résidu.

## PATCH 2026-07-22 — Fallbacks Hub Cotton
- [x] Remplacer le fallback partagé `Événement {nom_compte}` / `Soirée {nom_compte}` par `Événement Cotton` / `Soirée Cotton`.
- [x] Conserver les titres explicitement personnalisés: la normalisation ne remplace que les valeurs absentes ou legacy.
- [x] Vérifications locales: lint PHP Hub OK, tests Pro consommateurs OK, `git diff --check` Global OK.
- [ ] Recette publique: vérifier Hub Master/Play et page publique Hub sans titre personnalisé.

## PATCH 2026-07-22 — Renouvellement Quiz: gabarit fonctionnel ordonné
- [x] Enrichir le gabarit Quiz au-delà du simple préfixe `L/T/N` avec `slot_template` (`type`, `recipe_key`, `role_key`, `slot`).
- [x] Normaliser l'identité des recettes auto quick-schedule: `history_events`, `arts_literature`, `science_sports_riddles` et rôle catalogue `random`.
- [x] Enrichir la sélection courante depuis le référentiel candidat afin que `current_selection` et `proposal` portent la même identité métier canonique.
- [x] Modifier le picker Quiz pour sélectionner un candidat compatible par index, même préfixe, même famille et même rôle, sans considérer deux lots `T` ou `N` comme interchangeables.
- [x] Revalider à l'apply le format, le nombre, l'ordre, le préfixe et le `slot_template`; refuser les permutations par `INVALID_PROPOSAL` / `wrong_slot_template`.
- [x] Couvrir par tests les auto-packs papier `T(history)/T(arts)/T(sciences)/L(random)`, numériques `N(history)/N(arts)/N(sciences)/L(random)`, proposition permutée refusée, `NO_ALTERNATIVE` et absence de warnings PHP.
- [x] Vérifications locales: planner/apply OK, quick-schedule recommandation/récurrence/idempotence OK, lint PHP OK, `git diff --check` OK.
- [ ] Recette navigateur/DB: vérifier avec de vraies sessions auto que les IDs temporaires changent, que l'ordre visuel reste Histoire -> Arts -> Sciences -> Aléatoire et que `NO_ALTERNATIVE` ne modifie pas la session.

## PATCH 2026-07-21 — Service interne d'application de renouvellement thématique
- [x] Ajouter `app_programming_theme_renewal_apply_for_session(...)` comme chemin canonique interne d'écriture, sans endpoint, UI, migration ni persistance de refus.
- [x] Revalider la session: compte propriétaire, jeu/version, Hub optionnel, état éditable canonique et sélection attendue.
- [x] Ajouter le contrôle optimiste: comparaison `expected_current_selection`, puis `UPDATE championnats_sessions` conditionnel sur l'ancienne valeur persistée.
- [x] Réutiliser les primitives du planner pour valider proposition, catalogue éligible, quantité attendue, historique récent et absence de changement.
- [x] Appliquer Blind Test par bascule conditionnelle de `id_produit` uniquement.
- [x] Appliquer Quiz V2 par remplacement ordonné complet de `lot_ids` et maintien cohérent de `id_produit`.
- [x] Séparer pour Bingo la matérialisation d'une playlist cliente de son affectation à la session; aucun PDF, runtime, suppression d'ancienne playlist ou nettoyage général.
- [x] Retourner explicitement un artefact Bingo non affecté si la concurrence survient après matérialisation, sans annoncer de succès partiel.
- [x] Ajouter `web/tests/session_theme_renewal_apply_test.php` pour validation, concurrence, Blind Test, Quiz V2, Bingo et absence de mutations avant validation.
- [x] Vérifications locales: `php -l`, tests planner/apply, tests quick-schedule recommandation/récurrence/idempotence et `git diff --check` OK.
- [ ] Brancher ultérieurement un endpoint adaptateur Pro/Hub avec CSRF et contrat `STALE_SELECTION`.

## PATCH 2026-07-21 — Planner sans état de renouvellement thématique
- [x] Ajouter `app_programming_theme_renewal_plan(...)` comme coeur pur sans HTTP, HTML, écriture ni persistance de refus.
- [x] Ajouter `app_programming_theme_renewal_plan_for_session(...)` pour relire/valider une session existante et vérifier optionnellement son rattachement Hub.
- [x] Normaliser les jeux supportés: Blind Test, Bingo Musical et Quiz V2 uniquement; refuser Quiz V1 comme incompatible.
- [x] Exclure systématiquement la sélection courante et intersecter les exclusions temporaires avec les candidats éligibles.
- [x] Reprendre dans le wrapper session les règles historiques du programmateur automatique: exclusion des thèmes récemment joués et priorité aux thèmes associés à la date.
- [x] Traiter Bingo au niveau playlist catalogue même quand la session porte une playlist client.
- [x] Traiter Quiz V2 en remplacement complet, avec nombre exact de séries et ordre déterministe de proposition.
- [x] Retourner un contrat métier stable: `PROPOSED_SELECTION`, `NO_ALTERNATIVE`, erreurs validation/session/Hub, proposition normalisée, exclusions effectives et support futur `STALE_SELECTION`.
- [x] Ajouter `web/tests/session_theme_renewal_planner_test.php` pour le contrat général, Blind Test, Bingo, Quiz V2, Hub, historique récent, priorité saisonnière et absence de chemins d'écriture.
- [x] Vérifications locales: `php -l` du module et du test, test planner OK, tests quick-schedule recommandation/récurrence/idempotence OK.
- [ ] Brancher ultérieurement les adaptateurs Pro dashboard et Hub Master avec CSRF, `sessionStorage` et contrôle optimiste `STALE_SELECTION`.

## PATCH 2026-07-20 — Occurrences et idempotence série quick-schedule
- [x] Extraire `app_programming_recurrence_occurrences_build(...)` dans le module programmation global.
- [x] Couvrir les fréquences compatibles historiques: hebdomadaire, toutes les deux semaines et mensuelle.
- [x] Conserver la date de fin inclusive et les limites soft/hard du parcours historique.
- [x] Refuser toute fréquence inconnue, dont l'ancien mode `Dates libres`.
- [x] Ajouter le stockage dédié `programming_quick_series_operations` pour gabarit, récurrence, occurrences, thèmes figés et résultat par occurrence.
- [x] Ajouter `programming_quick_series_operations_phpmyadmin.sql` pour installation hors HTTP.
- [x] Ajouter `programming_quick_recurrence_test.php`.
- [x] Vérifications locales: `php -l` du module programmation, tests recommandation/idempotence/récurrence OK.
- [ ] Recette DB: installer la table de série et rejouer double-submit/reprise sur une vraie base dev.

## PATCH 2026-07-20 — Programmation rapide V1
- [x] Ajouter le module `jeux/programmation` pour profiler l'historique significatif et produire une recommandation sans persistance métier.
- [x] Utiliser `app_client_joueurs_dashboard_session_is_history_useful(...)` comme définition canonique des sessions historiques exploitables.
- [x] Implémenter les seuils V1 dans des constantes locales testables: 3 soirées, 60 %, marge 10 points, fenêtres horaires 30 minutes.
- [x] Ajouter le stockage idempotent `programming_quick_operations` avec clé unique compte + clé et conservation 24 h.
- [x] Centraliser l'espacement quick-schedule à 1 minute et le format rapide par défaut dans le module de recommandation.
- [x] Centraliser la recommandation de date libre: jour habituel fiable prioritaire, occurrence suivante du même jour si occupée, sinon aujourd'hui libre ou prochaine date libre chronologique.
- [x] Remplacer la source historique rapide `SELECT cs.*` par une sélection légère des champs nécessaires et d'indicateurs pré-calculés fournis au helper canonique.
- [x] Instrumenter le profil rapide avec temps de récupération, construction, recommandation, rendu route, soirées significatives et sessions examinées.
- [x] Ajouter le runbook `programming_quick_profile_performance.sql` pour exécuter les `EXPLAIN` hors HTTP.
- [x] Ajouter le test `programming_quick_recommendation_test.php`.
- [x] Couvrir par tests: aujourd'hui libre, aujourd'hui occupé, jour habituel libre, jour habituel occupé avec occurrence suivante, valeurs recommandées jeu/horaire/compteur/version inchangées.
- [x] Vérifications locales: lint PHP du module, `php web/tests/programming_quick_recommendation_test.php` et `php web/tests/programming_quick_idempotency_contract_test.php` OK.
- [ ] Recette DB: profil réel sur comptes avec historique homogène, historique insuffisant et sessions non significatives.

## PATCH 2026-07-17 — Contrat Hub unifié
- [x] Considérer `context_hub` comme cible pour soirée et événement, la couche opérations/événements ne restant qu'un miroir legacy borné.
- [x] Faire répondre la page publique Hub dès qu'un dashboard Hub existe avec au moins une session liée, indépendamment de la publication de cette session dans l'agenda global.
- [x] Centraliser les titres de fallback `Événement {nom_compte}` et `Soirée {nom_compte}`.
- [x] Centraliser le résumé `date · à partir de HHhMM · N session(s)` pour dashboard, Hub Master/Play et page publique Hub.
- [x] Réutiliser l'éligibilité historique de déplacement de date: autorisé si aucune session liée n'a commencé.
- [x] Autoriser la date du jour comme cible de déplacement et refuser une date déjà occupée par le même compte.
- [x] Déplacer les sessions liées ensemble en conservant leurs horaires et en synchronisant le Hub et l'éventuel contexte événement.
- [x] Vérifications locales: tests Hub publication/lots et cascade branding OK.
- [ ] Recette DB: vérifier existence page Hub sans session publiée agenda, titre fallback, date déplacée, date occupée et refus après démarrage.

## PATCH 2026-07-17 — Resolver public Hub publiable
- [x] Étendre `app_games_hub_public_resolve(...)` comme contrat public commun soirée/événement: publication, visibilité, temporalité, horaires, URL publique/canonique, client, événement, lieu, branding, lots Hub et sessions publiques filtrées.
- [x] Ajouter une règle de publication explicite: Hub actif, ligne `games_hubs_publication`, statut non désactivé, au moins une session publique complète, titre public non générique; lieu publié pour les soirées, événement non démo/non privé quand disponible.
- [x] Ajouter `app_games_hub_public_url_get(...)` pour produire une URL stable non devinable basée sur `games_hubs.id_securite`, sans exposer l'ID SQL.
- [x] Conserver les lots au niveau Hub via `app_games_hub_prizes_get(...)`, sans réintroduire les lots propres aux sessions d'un Hub.
- [x] Vérification locale: `php -l web/app/modules/jeux/hubs/app_games_hubs_functions.php`, `php web/tests/hub_publication_prizes_contract_test.php` et `php web/tests/hub_operation_branding_cascade_test.php` OK.
- [ ] Recette DB: tester un Hub soirée publié, un Hub événement publié, un Hub sans publication, un Hub sans session publique et un lieu offline.

## PATCH 2026-07-17 — Publication et lots Hub canoniques
- [x] Ajouter `games_hubs_publication` et `games_hubs_prizes` dans `app_games_hub_schema_ensure()`, en MyISAM/utf8 comme `games_hubs`.
- [x] Ajouter `app_games_hub_publication_get/save(...)` et `app_games_hub_public_resolve(...)` pour séparer publication, lieu, branding, sessions et lots.
- [x] Remplacer le writer de lots Hub qui propageait vers `championnats_sessions` par une persistance directe dans `games_hubs_prizes`.
- [x] Ajouter un bootstrap transitionnel borné depuis les lots historiques de sessions, avec log de divergence et sans fusion silencieuse.
- [x] Ajouter `games_hubs.prizes_initialized_at` pour distinguer un Hub jamais initialisé d'un Hub volontairement initialisé avec zéro lot.
- [x] Conserver le fallback générique `1ᵉʳ prix / 2ᵉ prix / 3ᵉ prix` quand un Hub initialisé n'a aucune ligne `games_hubs_prizes`.
- [x] Ajouter `app_games_hub_session_prize_labels_get(...)` pour les canvases rattachés à un Hub, avec fallback session autonome.
- [x] Vérification locale: `php -l global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`, `php web/tests/hub_prizes_test.php` et `php web/tests/hub_publication_prizes_contract_test.php` OK.

## PATCH 2026-07-17 — Résolution stricte Hub/session depuis membership persisté
- [x] Correctif livré:
  - faire lire `app_games_hub_get_for_session(...)` depuis `games_hubs_sessions` avec seulement `id_session` et `status='active'` comme critères de la relation persistée;
  - supprimer les rejets silencieux liés à `games_hubs.id_client`, `games_hubs.hub_date` ou `games_hubs.flag_active` quand une relation explicite existe déjà;
  - conserver ces écarts comme diagnostics `hub_session_membership_context_mismatch`, sans bloquer la résolution Canvas;
  - ajouter `app_games_hub_membership_get_for_session_id(...)` et `app_games_hub_branding_resolve_for_session(...)` pour le chemin branding nominal: `id_session -> games_hubs_sessions -> general_branding type 5 id_ref -> app_general_branding_get_complete(...)`;
  - aligner la cascade session sur l'ordre `branding_session -> branding_hub -> branding_reseau -> branding_client`, sans appel à `app_session_get_detail(...)` ni aux helpers runtime/jeu dans le chemin Hub branding;
  - charger les helpers Hub et sessions branding depuis `global_ajax.php`, afin que l'endpoint réel `general/branding?action=get` ait le même graphe de fonctions que les tests;
  - éviter le fatal `Call to undefined function app_evenement_get_detail()` dans le calcul de dossier média branding quand le helper événement n'est pas chargé;
  - ajouter un script DEV ciblé `web/tests/hub_session_membership_dev_diagnostic.php` pour vérifier les sessions réelles 26624, 26625, 26627, 26628, 26629, 26630 et 26633.
- [x] Garde-fous:
  - aucune réécriture du schéma, de la migration, du backfill ou de l'alimentation `games_hubs_sessions`;
  - le type branding 5 reste un chemin Hub basé sur `games_hubs.id` (`operations/hubs_branding/{id_hub}`), sans dépendance événement.
- [x] Vérification locale:
  - lint PHP des fichiers touchés OK;
  - `php /home/romain/Cotton/global/web/tests/hub_operation_branding_cascade_test.php` OK;
  - le diagnostic DEV direct est prêt mais la connexion MySQL locale `dev_cotton_global_admin` est refusée depuis ce workspace.

## PATCH 2026-07-17 — Cascade branding Hub/session champ par champ
- [x] Correctif livré:
  - ajouter `games_hubs_sessions` comme relation structurelle Hub/session, avec création idempotente dans le module Hub et SQL de backfill contrôlé;
  - faire consommer cette relation par `app_games_hub_sessions_get(...)` et `app_games_hub_get_for_session(...)`, dans les deux sens;
  - réconcilier les anciennes données uniquement lorsqu'un seul Hub actif est candidat; en cas de concurrence, journaliser `hub_session_membership_ambiguous` et refuser toute sélection implicite;
  - ajouter `app_general_branding_get_detail_merged(...)` et `app_general_branding_merge_missing_values(...)` pour fusionner session -> opération/Hub -> réseau -> compte sans copier de branding dans les sessions;
  - faire résoudre `app_games_hub_branding_get(...)` en champ par champ, avec couche `branding_hub` type 5 pour les Hubs;
  - ajouter `app_games_hub_branding_get_for_session(...)` qui passe par `app_games_hub_get_for_session(...)` et valide l'appartenance de la session au Hub avant héritage;
  - corriger `general/branding?action=get` pour repasser par le resolver historique `app_session_branding_get_detail(...)`, avec cascade Hub activée par le contexte Canvas réel;
  - ajouter `date` à `branding_fetch_session_row(...)`, nécessaire à `app_games_hub_get_for_session(...)`;
  - ne plus laisser un branding session vide (`id=0`) bloquer le fallback réseau/compte historique;
  - résoudre la couche opération des jeux depuis le Hub type 5, sans condition sur `id_operation_evenement`;
  - corriger `app_games_hub_get_for_session(...)` pour ne plus filtrer ni trier les Hubs par `id_operation_evenement` et ne plus dépendre d'un `LIMIT 1` implicite;
  - supporter `general_branding.id_ref = games_hubs.id` pour les brandings Hub type 5, avec `id_related` conservé en fallback compatibilité;
  - ajouter `app_games_hub_operation_branding_get_for_event(...)` pour la page publique événement, avec fallback legacy quand aucun Hub n'existe.
- [x] Garde-fous:
  - aucun clonage de branding opérationnel vers `championnats_sessions`;
  - les pages publiques session `play/web/ep/*` ne reçoivent pas le contexte `branding_context=game`;
  - les interfaces déjà ouvertes ne sont pas rafraîchies par WebSocket; le nouveau branding est relu au chargement suivant.
- [x] Vérification locale:
  - `php -l` sur les modules branding/Hub/session OK;
  - `php /home/romain/Cotton/pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php` OK;
  - `php /home/romain/Cotton/global/web/tests/hub_operation_branding_cascade_test.php` OK.

## PATCH 2026-07-17 — Branding opérationnel des Hubs soirée
- [x] Correctif livré:
  - permettre à `app_games_hub_branding_get(...)` de résoudre une couche `branding_soiree` pour les Hubs `context_type=soiree` sans `id_operation_evenement`;
  - utiliser `general_branding.id_type_branding=5` avec `id_related=games_hubs.id`;
  - ajouter le détail d'upload associé dans `app_general_branding_get_upload_detail(...)` sous `operations/hubs_branding/{id_hub}`;
  - conserver la cascade réseau/compte/fallback Cotton quand aucune couche soirée n'existe.
- [x] Garde-fous:
  - aucun changement pour les Hubs événement qui continuent de passer par `branding_evenement` type 2;
  - aucune création d'événement public pour les soirées;
  - aucun changement runtime, joueurs, lots, focus ou WebSocket.
- [x] Vérification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` OK;
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_functions.php` OK;
  - `git -C /home/romain/Cotton/global diff --check` OK.

## PATCH 2026-07-15 — Lots Hub consolides sans migration
- [x] Auditer le stockage session `lot_1/lot_2/lot_3` et confirmer l'absence de modele soiree/evenement.
- [x] Normaliser les defaults differents Bingo / Quiz / Blind Test vers les trois fallbacks publics du Hub.
- [x] Prendre la premiere session personnalisee dans l'ordre du programme et signaler les personnalisations suivantes divergentes.
- [x] Ajouter un writer commun qui propage les trois rangs a toutes les sessions, avec inversion de stockage Bingo.
- [x] Partager resolver et writer entre Hub Games et prototype Pro; test `web/tests/hub_prizes_test.php` vert sur defaults multi-jeux, source personnalisee et divergence (6 assertions).
- [x] Exposer le fallback visuel Cotton 600x240 dans le module Hub commun et le partager entre Games et le dashboard Pro, sans modifier la cascade du resolver general.
- [ ] Migrer ulterieurement vers un modele lots porte par le Hub ou l'evenement, avec interface de gestion dediee.

## PATCH 2026-07-15 — Bridge Remote papier et sélection injectable
- [x] Confirmer que le bridge écrit `games_hubs_players` et `games_hubs_players_sessions` après succès runtime, et que `completed` ne désactive pas le joueur global.
- [x] Journaliser création/réutilisation du joueur, création/réparation du mapping, sélection des actifs et résultat de chaque injection papier.
- [x] Borner la réparation d'identité runtime à un contexte serveur éphémère et restaurer tout contexte global précédent dans le `finally`.
- [ ] Confirmer en recette DB que le même `id_hub_player` et la même clé `p:*` traversent A puis B, sans doublon ni statut `left` implicite.

## PATCH 2026-07-13 - Games hubs participation papier persistante
- [x] Séparer ensure commun, numérique et papier; réserver le preload au numérique.
- [x] Persister Quiz/Blind Test/Bingo papier via leur UPSERT `player_register` avec pseudo Hub et clé stable.
- [x] Conditionner mapping actif, ID participation et confirmation papier au succès moteur prouvé.
- [x] Conserver le refus auto d'un mapping `left`; seule une reprise manuelle explicite le réactive selon le contrat existant.
- [ ] Valider en base les trois tables participants et les courses polling/reload/focus sur un environnement intégré.

## PATCH 2026-07-13 - Focus Hub monotone après relance
- [x] Recharger la ligne `games_hubs` avant écriture, clear, construction des sessions et résolution de présentation.
- [x] Écrire puis confirmer `active_session_id` avant exécution Hub, injection ou redirect, y compris pour une session suspendue encore `running`.
- [x] Refuser la suite sur `FOCUS_COMMIT_MISMATCH`; conserver tous les clears conditionnels sur l'ID attendu.
- [x] Journaliser demande, avant/après commit, clear tardif ignoré et présentation résolue sans token ni identité joueur.
- [x] Exposer par session le dernier `hub_execution_started` du Hub afin que le fallback Master sélectionne la suspendue la plus récemment lancée après épuisement des sessions à venir.
- [ ] Recette DB/navigateur A → B → C → relance A → relance B, avec contrôle direct de `games_hubs.active_session_id` à chaque étape.

## PATCH 2026-07-13 - Reset score borné au rejoin manuel Hub
- [x] Utiliser le mapping `left` relu sous verrou comme preuve du départ joueur, uniquement avec `join_source=manual` et `allow_left_reactivation`.
- [x] Transporter l'autorisation dans un contexte PHP interne éphémère borné au jeu/session/joueur pendant `game_api_dispatch`, puis restaurer le contexte en `finally`.
- [x] Journaliser l'autorisation et le résultat sans exposer de token.
- [ ] Recette: manuel Hub après quit joueur remet Quiz/Blind Test à zéro; relance organisateur, auto/refresh/direct et hors Hub conservent le score.

## PATCH 2026-07-13 - Games hubs natural completion
- [x] Créer/fermer une incarnation durable `hub_execution_started` / `hub_execution_completed` dans `game_events`, sans migration.
- [x] Refuser le contexte Hub si le focus courant ou l'incarnation ouverte ne correspondent pas à la session.
- [x] Autoriser le reload uniquement si la dernière fin terminale appartient à la dernière exécution Hub complétée.
- [x] Distinguer fin naturelle de quit, grâce expirée et abandon technique.
- [x] Exposer une garde réutilisable par Hub Master et les anciennes URLs Canvas.

## PATCH 2026-07-11 - Games hubs runtime participation ensure
- [x] Centraliser preload, `player_register`, validation clé/ID et mise à jour mapping.
- [x] Supprimer le court-circuit fondé uniquement sur `status=active` et `id_participation>0`.
- [x] Sérialiser les appels concurrents par verrou MySQL nommé sans migration.
- [x] Préserver `left`, `completed`, sessions hors Hub, EP et séparation A/B.
- [x] Réutiliser les upserts idempotents Blind Test, Quiz et Bingo sans modifier leurs contrats métier.

## PATCH 2026-07-11 - Games hubs presentation resolver
- [x] Ajouter `app_games_hub_presentation_resolve(...)` comme lecture canonique de `active_session_id`.
- [x] Exposer la présentation dans tous les retours de `app_games_hub_get_active_launched_session_for_player(...)`.
- [x] Garder séparés destination, auto-joinabilité et identité/mapping.
- [x] Rectification 2026-07-13: traiter le focus numérique actif et non terminé comme commit de présentation auto-joinable, sans attendre `runtime_status=running`; Bingo reste `pending` avant sa première phase.
- [x] Préserver l'ordre `player_register` avant navigation et laisser `grid_assign` / `grid_hydrate` au Player Bingo.
- [x] Repli Hub si le focus persistant ne correspond plus à une session rattachée.
- [x] Aucune migration, présence/grâce persistante ou réparation de participation runtime.

## PATCH 2026-07-09 - Games hubs active session focus
- [x] Correctif livre:
  - ajouter `active_session_id` et `active_session_activated_at` sur `games_hubs`;
  - ajouter `app_games_hub_focus_set_active(...)`;
  - enrichir `app_games_hub_sessions_get(...)` avec `hub_focus_status` / `hub_is_focus_active`;
  - marquer la session lancee depuis le hub master comme focus actif sans modifier le runtime jeu;
  - limiter `app_games_hub_get_active_launched_session_for_player(...)` aux sessions focus actives;
  - interdire l'auto-join `join_source=auto` sur les sessions non-focus, sans bloquer les reprises manuelles/directes;
  - aligner le programme Hub Play: badge `Suspendue` et pas de CTA de reprise sur une session `previous` encore runtime `running`;
  - journaliser `hub_focus_*` et `hub_auto_join_*`.
- [x] Garde-fous:
  - aucune mutation des etats runtime reels pour simuler la fin d'une session;
  - un `left` sur une session precedente ne bloque pas la prochaine session focus;
  - session papier/terminee/non-focus restent hors auto-join.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` OK.

## PATCH 2026-07-09 - Games hubs session register bridge
- [x] Correctif livre:
  - ajouter `app_games_hub_session_register_bridge(...)` comme point de passage session classique -> hub;
  - detecter le hub actif depuis la session app rattachee au token public;
  - ne rien creer et logguer `hub_session_register_bridge_skipped_no_hub` hors hub;
  - creer/retrouver un hub player invite avec le `player_id` session `p:*` comme `player_token`;
  - creer/retrouver un hub player EP avec `auth_type='ep'` et `id_ep_player` depuis `sourceTable='equipes_joueurs'`;
  - creer/retrouver le mapping `games_hubs_players_sessions` avec participation runtime et `participant_key`;
  - poser les cookies hub depuis la reponse AJAX quand possible;
  - journaliser les jalons `hub_session_register_bridge_*`.
- [x] Garde-fous:
  - pas de hub player cree pour une session hors hub;
  - pas de bridge recursif quand `player_register` est appele par le resolver hub;
  - pas de doublon invite pour un register EP exploitable.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` OK.

## PATCH 2026-07-09 - Games hubs session access resolver
- [x] Correctif livre:
  - ajouter `app_hub_player_resolve_session_access(...)` comme point de passage commun hub player -> session;
  - ajouter `app_games_hub_get_for_session(...)` pour retrouver le hub actif d'une session scannée par QR;
  - ajouter `app_games_hub_player_program_get(...)` pour alimenter le programme compact Hub Play depuis les sessions, le runtime, les mappings et le resolver;
  - valider hub actif, session rattachee, hub player actif, type papier/numerique et mapping;
  - creer/retrouver la participation runtime via `player_register` existant pour Quiz, Blind Test et Bingo;
  - conserver le lien EP via `sourceTable='equipes_joueurs'` / `sourceId=id_ep_player`;
  - enrichir `games_hubs_players_sessions` avec les champs d'etat auto/manual/left/completed;
  - rendre l'echec d'auto-join pendant polling non bloquant (`ok=true`, `play_url=''`, `poll_error`) pour eviter un HTTP 400 recurrent cote Hub Play;
  - journaliser les jalons `hub_session_access_*` et `hub_session_manual_rejoin_*`, dont mapping left trouve, mapping reactive, participation trouvee/creee, redirect play, confirmation papier et echec.
- [x] Garde-fous:
  - le register session classique hors hub reste inchangé;
  - le QR session classique sans identité hub valide ne crée pas de hub player fantôme;
  - une session papier cree une inscription runtime mais ne redirige pas vers `/play`;
  - un mapping `left` bloque l'auto-join et reste rejoignable manuellement seulement via `join_source=manual` / `manual_rejoin=true`;
  - `app_games_hub_player_join_session(...)` reste disponible comme wrapper compat.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` OK;
  - `git -C /home/romain/Cotton/global diff --check` OK.

## PATCH 2026-07-08 - Games hubs sessions mapping Lot 2
- [x] Correctif livre:
  - etendre `app_games_hubs_functions.php` avec la table `games_hubs_players_sessions`;
  - ajouter les helpers de mapping hub player/session, injection active players, join session idempotent et detection session lancee;
  - appeler `build_preload_for_game(...)` avant injection pour initialiser les lignes runtime Quiz/Blind Test si besoin;
  - conserver le rattachement EP via `sourceTable='equipes_joueurs'` / `sourceId=id_ep_player`.
- [x] Garde-fous:
  - unicite `(id_hub_player, id_session)`;
  - exclusion des joueurs hub `left`;
  - pas de relance d'une session `running` ou terminee;
  - fallback explicite: le start effectif reste declenche par le master Canvas JS/WS apres redirection.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` OK.

## PATCH 2026-07-08 - Games hubs players runtime V1
- [x] Correctif livre:
  - etendre `app_games_hubs_functions.php` avec la table `games_hubs_players`;
  - ajouter les helpers hub players: current, register guest, register EP, leave, touch, count active;
  - ajouter le retour compte joueur EP vers `/hub/{hub_token}/play?ep_connect_token=...`;
  - brancher `app_joueur_session_inscription_get_link(...)` sur le contexte `hub_account_join`.
- [x] Garde-fous:
  - aucune participation session creee;
  - aucune injection dans les tables runtime Quiz/Blind Test/Bingo;
  - les joueurs quittes restent en `status='left'`.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` OK;
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php` OK.

## PATCH 2026-07-07 - Games hubs Lot 1
- [x] Correctif livre:
  - ajouter le helper global `app_games_hubs_functions.php`;
  - creer/assurer la table `games_hubs` avec token stable, contexte, date, client et rattachement optionnel evenement;
  - exposer les lectures par token/ID, la creation idempotente par contexte, les sessions liees et le branding effectif;
  - charger le helper depuis `global_librairies.php`.
- [x] Garde-fous:
  - aucune ecriture branding;
  - aucune propagation aux sessions;
  - aucune table participants hub dans ce lot;
  - aucun changement scoring/lots/options/runtime.
- [x] Note Lot 2:
  - les pages hub `games` consomment `app_games_hub_get_by_token(...)`, `app_games_hub_sessions_get(...)` et `app_games_hub_branding_get(...)` en lecture seule;
  - aucun changement global supplementaire n'est requis pour les routes read-only.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` OK;
  - `php -l /home/romain/Cotton/global/web/global_librairies.php` OK.

## PATCH 2026-07-07 - Blind Test equipes runtime solo: exclusion classements
- [x] Correctif livre:
  - les podiums normalises ne posent `participant_type=team` / `is_team=1` que si `team_member_count >= 2`;
  - les lignes `blindtest_session_teams` avec `players_count < 2` sont ignorées dans resultats session et moteur `Mes joueurs`;
  - le fallback `podium_json` restaure le pseudo du membre unique quand il est disponible au lieu du nom d'equipe.
- [x] Garde-fous:
  - pas d'agregation par pseudo, score ou heuristique;
  - pas de reconstruction retroactive d'equipe sans ligne fiable;
  - Quiz/Bingo inchanges.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php` OK;
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php` OK.

## PATCH 2026-07-06 - Blind Test leaderboards: participants mixtes
- [x] Correctif livre:
  - le moteur `Mes joueurs` expose pour Blind Test `participants`, `participants_full` et `participants_podium`;
  - ces lignes fusionnent joueurs solos et equipes runtime issues de `blindtest_session_teams`;
  - les lignes conservent `participant_type`, `is_team`, `team_id`, `team_name`, `team_member_count`;
  - les anciens champs `players*` et `teams*` restent disponibles pour les usages historiques.
- [x] Garde-fous:
  - pas de classement dedie equipes runtime Blind Test cote moteur;
  - pas d'agregation heuristique sans ligne `blindtest_session_teams`;
  - scoring et writes runtime inchanges.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php` OK;
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php` OK.

## PATCH 2026-07-06 - Blind Test resultats publics: podium equipe runtime
- [x] Correctif livre:
  - quand `blindtest_session_teams` contient des lignes pour une session Blind Test, le contexte resultats reconstruit le podium depuis le classement mixte equipes runtime + solos;
  - `podium_json` reste uniquement fallback pour les sessions sans equipes runtime persistées;
  - les lignes equipe exposent `participant_type=team`, `is_team`, `team_id`, `team_name` et `team_member_count`;
  - `players_count` represente les entites classees pour ces sessions mixées, afin que les vues resultats affichent equipes + solos.
- [x] Garde-fous:
  - pas de recalcul des scores;
  - pas d'agregation heuristique sans ligne `blindtest_session_teams`;
  - joueurs solo et jeux non Blind Test inchanges.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php` OK.

## PATCH 2026-07-06 - Blind Test agregats: libelle equipe brut
- [x] Correctif livre:
  - les lignes equipe runtime lues depuis `blindtest_session_teams` exposent `label` = nom equipe brut;
  - le nombre de membres est conserve via `team_member_count` et `members`;
  - les podiums normalises detectent les entrees equipe et retirent un eventuel suffixe legacy `(n)` seulement a l'affichage;
  - les agregats saison gardent l'identite stable `team:{team_name_normalized}`.
- [x] Garde-fous:
  - pas de recalcul depuis `blindtest_players`;
  - pas de compat retroactive pour sessions sans ligne `blindtest_session_teams`;
  - scoring, rangs et points inchanges.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php` OK;
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php` OK.

## PATCH 2026-07-06 - Blind Test agrégats: exclusion EP précoce des membres d'équipe
- [x] Correctif livre:
  - précharger les lignes `blindtest_session_teams` et leur carte membres avant les participations connectées;
  - exclure les membres d'équipes Blind Test dès la lecture `championnats_sessions_participations_games_connectees`;
  - conserver l'enregistrement des equipes runtime dans `teams` avec `team:{team_name_normalized}`;
  - conserver les joueurs solo en `players`;
  - calculer les bonus podium Blind Test sur un seul classement par session, compose des equipes runtime et des joueurs solo.
- [x] Garde-fous:
  - pas de changement sur `blindtest_players`, `equipes`, Quiz ou Bingo;
  - fallback `podium_json` conservé quand la table dédiée n'a pas de lignes.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php` OK.
- [ ] Verification recette serveur:
  - saison contenant `LES REMOS (2)`: les points équipe ne remontent plus sur `REMO12`;
  - saison contenant une session solo: les joueurs solo restent dans le leaderboard joueurs.

## PATCH 2026-07-06 - Blind Test equipes runtime persistées dans résultats et agrégats
- [x] Correctif livre:
  - lire `blindtest_session_teams` quand la table existe pour les resultats de session Blind Test;
  - afficher les equipes comme participants de classement et exclure uniquement leurs membres depuis `blindtest_players`;
  - conserver `players_count` base sur les vrais joueurs;
  - adapter les agregats communauté/saison pour utiliser l'identite `team:{team_name_normalized}`;
  - garder `podium_json` comme fallback pour les anciennes sessions ou les tables non migrees.
- [x] Garde-fous:
  - pas d'injection d'equipes dans `blindtest_players`;
  - pas de fusion joueur/equipe;
  - les joueurs solo d'une session mixte restent des joueurs;
  - Quiz/Bingo inchanges.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php` OK;
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php` OK.
- [ ] Verification recette serveur:
  - session Blind Test mixte: classement detail affiche `Equipe (n)` + solos, sans membres;
  - pivot jour et communauté/saison agrègent l'equipe sous `team:{nom_normalise}`;
  - session sans table `blindtest_session_teams`: fallback `podium_json`/joueurs inchangé.

## PATCH 2026-07-03 - Blind Test equipes runtime dans classements agreges Pro
- [x] Correctif livre:
  - lire `blindtest_sessions.podium_json` dans `app_client_joueurs_dashboard_context_compute(...)`;
  - detecter les entrees podium equipe runtime via `isTeam`, `teamId` ou `teamName`;
  - alimenter le leaderboard `teams` Blind Test avec le libelle `Nom equipe (nb joueurs)`;
  - ignorer les lignes individuelles `blindtest_players` des sessions dont le podium runtime contient des equipes, pour ne plus afficher un seul coequipier dans les agregats.
- [x] Garde-fous:
  - les sessions Blind Test sans equipe runtime gardent le classement joueur existant;
  - pas de changement des regles de points, de tri, d'ex aequo, ni du rendu Pro;
  - pas de changement Quiz/Bingo.
- [ ] Verification recette serveur:
  - session Blind Test equipe terminee: le bilan pivot `/start/games/day/...` affiche le nom de l'equipe dans podium/classement;
  - page `/account/establishment/view/general`: le classement Blind Test remonte l'equipe dans `teams`;
  - session Blind Test sans equipe: le classement joueur reste inchange.

## PATCH 2026-07-03 - Play classements: scope filtre + jeux utiles
- [x] Correctif livre:
  - ajouter une option facultative a `app_client_joueurs_dashboard_get_context(...)`;
  - permettre a `app_client_joueurs_dashboard_context_compute(...)` de limiter les jeux calcules via `game_keys`;
  - permettre a `play` de forcer le scope `filter` pour eviter le calcul summary `all` organisateur sur le premier affichage joueur;
  - enrichir l'instrumentation avec `game_keys_requested` et `game_keys_returned`.
- [x] Garde-fous:
  - signature retrocompatible: les appels existants sans option gardent le comportement historique;
  - pas de changement du tri, des points, des ex aequo, des podiums, du Top 10 ou du classement complet;
  - pas de cache persistant ajoute.
- [ ] Verification recette serveur:
  - comparer les clients lents 10 et 1441 sur `/extranet/dashboard/leaderboards?perf_play_leaderboards=1`;
  - verifier que les jeux non demandes ne sont plus retournes dans le contexte play;
  - verifier les ecrans PRO/FO clients qui appellent le helper sans options.

## PATCH 2026-07-03 - Play home: synthese historique legere
- [x] Correctif livre:
  - ajouter `app_joueur_participations_reelles_summary_rows_get(...)` pour les KPI de synthese joueur;
  - conserver les trois sources existantes de l'historique reel et le dedoublonnage par session;
  - conserver le filtre `app_joueur_historique_session_is_eligible(...)`;
  - faire utiliser cette synthese par `app_joueur_participations_reelles_latest_date_get(...)` et `app_joueur_participations_reelles_get_stats(...)`;
  - ajouter un jalon optionnel `leaderboards context - fenetre activite` pour isoler le cout amont du cache session classements.
- [x] Garde-fous:
  - pas de changement des regles d'historique joueur;
  - pas de changement du moteur classement organisateur;
  - pas de modification des sources de participation probable ou runtime.
- [ ] Verification recette serveur:
  - controler `/extranet/dashboard?perf_play=1` avec joueur historique;
  - verifier que `total_sessions`, `top_organisateur` et `top_game` restent coherents;
  - comparer `/extranet/dashboard/leaderboards?perf_play_leaderboards=1` pour confirmer le deplacement du cout hors `cache session hit`.

## PATCH 2026-07-03 - Play classements: instrumentation contexte joueur
- [x] Correctif livre:
  - ajouter des jalons optionnels `perf_play` dans `app_joueur_leaderboards_get_context(...)`;
  - exposer les etapes couteuses: lignes organisateurs liees, identite joueur, regroupement organisateurs, appel moteur global par organisateur/periode, sections finales;
  - ajouter un cache request-scope pour eviter deux appels identiques au moteur organisateur sur le meme triplet client/annee/trimestre pendant une meme requete;
  - conserver le cache session existant du contexte joueur.
- [x] Garde-fous:
  - aucun changement sur les periodes, ex aequo, podiums, Top 10 / classement complet ou visibilite jeux;
  - aucun changement du moteur organisateur `app_client_joueurs_dashboard_get_context(...)`;
  - instrumentation active seulement quand le helper `play` est disponible.
- [ ] Verification recette serveur:
  - charger `/extranet/dashboard/leaderboards?perf_play_leaderboards=1`;
  - comparer le temps `leaderboards ajax - contexte` avec les sous-blocs globaux remontes;
  - verifier qu'un appel sans flag ne change pas le rendu.

## PATCH 2026-07-02 - Contacts multi-comptes: helper appartenance
- [x] Correctif livre:
  - ajouter `client_contact_client_is_attached(...)` pour centraliser le controle d'appartenance contact/client;
  - permettre a `client_contact_direct_access_consume(...)` de recevoir un client cible optionnel;
  - refuser un lien temporaire cible si le contact n'est pas rattache au client demande;
  - conserver le fallback historique vers le premier client lie quand aucun contexte client n'est fourni.
- [x] Verification locale:
  - `php -l web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php` OK.
- [ ] Verification recette serveur:
  - contact mono-compte: connexion/lien temporaire inchanges;
  - contact multi-comptes: lien temporaire avec `id_client` cible respecte;
  - token valide + client non rattache: refus `client_not_attached`.

## PATCH 2026-07-02 - Quiz: libelle serie unique thematique
- [x] Correctif livre:
  - factoriser le calcul du libelle de series Quiz dans `app_cotton_quiz_get_series_label(...)`;
  - retourner le nom de la thematique quand `nb_series=1` et qu'un nom est disponible;
  - conserver `1 serie` comme repli si le nom est vide;
  - conserver `N series` pour les sessions multi-series afin de ne pas surcharger l'UI.
- [x] Verification locale:
  - `php -l web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php` OK.
- [ ] Verification recette serveur:
  - session Quiz 1 serie en PRO/WWW/PLAY: verifier que le nom de thematique remplace `1 serie`;
  - session Quiz 2/3/4 series: verifier que le libelle compact `N series` reste affiche;
  - interfaces GAMES: confirmer le comportement existant avec nom de thematique pour les quiz a une seule serie.

## PATCH 2026-07-02 - Logs client: garde contexte BO/admin
- [x] Correctif livre:
  - ajouter dans `log_ajouter(...)` une garde centralisee sur les ecritures `clients_logs`;
  - ignorer ces ecritures quand la session porte `CQ_admin=1` ou un `CQ_admin_context` explicite pose par le PRO;
  - ne pas modifier le schema `clients_logs` ni utiliser `online` comme critere d'origine.
- [x] Verification locale:
  - `php -l web/lib/core/lib_core_log_functions.php` OK.
- [ ] Verification recette serveur:
  - session EC client normale: logs `clients_logs` conserves;
  - session EC issue du BO/admin: logs `clients_logs` non crees;
  - autres tables de logs appelees via `log_ajouter(...)`: comportement conserve.

## PATCH 2026-06-30 - Lots Quiz numeriques `N`: filtre source active
- [x] Correctif livre:
  - ajouter `id_etat=2` et `id_lot=0` au picker de constitution automatique des lots `N`;
  - conserver la relecture runtime des lots `N` existants par IDs stockes, sans nouveau filtre.
- [x] Verification locale:
  - `php -l web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php` OK.
- [ ] Verification recette serveur:
  - certifier une question inactive ou liee a un lot et verifier qu'elle n'est pas retenue dans un nouveau lot `N`;
  - verifier qu'un lot `N` existant continue a se relire.

## PATCH 2026-06-26 - Formats courts Blind Test/Bingo
- [x] Correctif livre:
  - ajouter les helpers communs `app_session_format_*` pour `id_format=2` standard et `id_format=5` court sur Blind Test/Bingo;
  - corriger la preference Bingo pour grouper sur `championnats_sessions.id_format`;
  - ajouter le format Bingo `5`: 20 morceaux, grille 3x3, duree indicative 10 min;
  - generer les grilles Bingo court depuis les numeros de la playlist client et non depuis l'ancien preset 15 titres;
  - rendre les PDF/HTML de grilles BDD compatibles avec le format court 3x3;
  - placer le QR du PDF Bingo papier format 5 sur la zone lots (`A gagner`, ligne, double ligne, bingo), comportement attendu pour le 3x3;
  - exposer les libelles courts sous forme `20 titres` / `40 titres` pour les affichages PRO;
  - ajouter un helper global de resolution des titres de session musicale: snapshot playlist client pour Bingo, selection deterministe `sha256(id_session|id_morceau)` pour Blind Test court.
- [x] Verification locale:
  - `php -l web/app/modules/jeux/sessions/app_sessions_functions.php` OK;
  - `php -l web/app/modules/jeux/bingo_musical/app_bingo_musical_functions.php` OK;
  - `php -l web/app/modules/jeux/sessions/app_sessions_functions.php` OK;
  - `php -l web/app/modules/jeux/bingo_musical/app_bingo_musical_grids_bdd_pdf.php` OK;
  - `php -l web/app/modules/jeux/bingo_musical/app_bingo_musical_grids_bdd_html.php` OK;
  - `git -C /home/romain/Cotton/global diff --check` OK.
- [ ] Verification recette serveur:
  - Bingo court: confirmer 20 lignes dans `jeux_bingo_musical_morceaux_to_playlists_clients`;
  - Bingo court: confirmer grilles clients 9 cases utiles, cases 10..25 a 0;
  - Bingo court papier: generer un PDF BDD et verifier fond/layout 3x3;
  - Bibliotheque en contexte session: verifier que `Voir le détail` affiche les titres de session apres changement de format.

## PATCH 2026-06-25 - Evenements pivot: assurance sans session explicite
- [x] Correctif livre:
  - ajouter l'option explicite `allow_empty` a `app_evenement_pivot_ensure_for_day(...)`;
  - conserver le comportement historique par defaut: sans session et sans `allow_empty`, le helper retourne `no_sessions`;
  - permettre au tunnel PRO de creer/trouver un pivot evenement gamification pour une date future avant l'ajout de la premiere session.
- [x] Verification locale:
  - `php -l web/app/modules/operations/evenements/app_evenements_functions.php` OK;
  - `git -C /home/romain/Cotton/global diff --check` OK.
- [ ] Verification recette serveur:
  - creation pivot evenement vide depuis PRO gamification;
  - ajout premiere session depuis ce pivot et rattachement au meme evenement;
  - verifier qu'un appel sans `allow_empty` conserve le refus `no_sessions`.

## PATCH 2026-06-25 - Questions numeriques: modele cible sans table separee
- [x] Audit:
  - verifier le schema canon `questions`, `questions_propositions`, `questions_lots_temp`;
  - confirmer que `questions_propositions` porte les mauvaises propositions communes sans variante papier/numerique;
  - confirmer que `T` pointe vers `questions_lots_temp.question_ids -> questions`;
  - confirmer que le precedent socle `N` pointait vers `questions_lots_num_temp -> questions_numeriques`;
  - verifier les dumps/schema locaux: aucune table ni donnees `questions_numeriques` trouvees;
  - noter que le comptage DB serveur reel necessite des identifiants MySQL;
  - relire les usages runtime `L/T/N` dans les helpers global/session.
- [x] Correctif livre:
  - ajouter une migration additive pour `questions.question_numerique`, `questions.reponse_numerique`, `questions.commentaire_numerique`, `questions.statut_numerique`;
  - ne pas ajouter de typage a `questions_propositions`;
  - supprimer du SQL serveur la creation et les ALTER de `questions_numeriques`;
  - ajouter/normaliser `questions_lots_num_temp.question_source` en source cible unique `questions`;
  - bloquer la migration si des lignes `questions_lots_num_temp` portent une source non cible, afin d'imposer un export/nettoyage manuel;
  - faire creer les nouveaux lots `N` avec `question_source='questions'`;
  - faire lire `qz_num_lot_questions_get_liste(...)` depuis `questions`, sans fallback `questions_numeriques`;
  - faire selectionner les builders numeriques depuis `questions` et verifier les propositions communes existantes.
- [x] Verification locale:
  - `php -l web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php` OK;
  - `php -l web/app/modules/jeux/sessions/app_sessions_functions.php` OK;
  - `php -l web/app/modules/jeux/cotton_quiz/tools/qz_questions_numeriques_candidates_audit.php` OK.
- [ ] Verification recette serveur:
  - compter/exporter les eventuelles lignes `questions_numeriques` avant abandon;
  - compter/exporter les eventuelles lignes `questions_lots_num_temp` dont la source n'est pas `questions`;
  - appliquer la migration sur une base de test;
  - creer un lot `N` neuf et verifier que `question_source='questions'`;
  - verifier qu'une question numerique sans propositions communes est rejetee par la validation.

## PATCH 2026-06-24 - Questions numeriques: commentaire et dates source
- [x] Audit:
  - verifier le schema source `questions.commentaire`, `questions.jour_associe`, `questions.jour_associe_v1`;
  - verifier que `jour_associe` est exploite en selection proche date session avec `LENGTH(jour_associe)=5` et `DATEDIFF`;
  - verifier que `jour_associe_v1` n'a pas d'usage applicatif PHP source certain hors portage/compatibilite;
  - verifier les exports/imports lies a `questions_numeriques`.
- [x] Correctif livre:
  - ajouter `questions_numeriques.commentaire` nullable dans la migration candidate;
  - ajouter `questions_numeriques.jour_associe_v1` nullable dans la migration candidate;
  - conserver `jour_associe` nullable et son format brut `MM-DD`;
  - aligner l'audit/export CLI sur `commentaire`, `jour_associe` et `jour_associe_v1`;
  - laisser le runtime N compatible avec anciennes tables via lectures `SELECT *`.
- [ ] Verification recette serveur:
  - appliquer la migration additive sur une base de test deja dotee de `questions_numeriques`;
  - lancer un export CSV/SQL et verifier la presence des trois champs;
  - controler une selection histoire/evenements avec `jour_associe` non vide.

## PATCH 2026-06-24 - Quiz V2: helpers auto lots numeriques `N`
- [x] Audit:
  - verifier que les lots papier `T` ne stockent pas de type de serie en base;
  - relever la logique des trois builders papier: histoire/evenements, arts/litterature, sciences/sports/enigmes;
  - verifier que l'affichage session lit les noms des lots `N` via `qz_num_lot_get_detail(...)`, comme les noms `T`.
- [x] Correctif livre:
  - ne pas ajouter de colonne `type_serie` ni de migration additive;
  - ajouter les types centraux de helpers `history_events`, `arts_literature`, `science_sports_riddles`;
  - ajouter `qz_build_num_temp_history(...)`, `qz_build_num_temp_arts(...)`, `qz_build_num_temp_sciences(...)`;
  - ajouter `qz_build_numeric_auto_series(...)` et `qz_build_numeric_auto_pack_lot_ids_csv(...)`, non branches au quick;
  - ajouter `qz_build_numeric_auto_pack_result(...)` pour exposer les `N` reussis et les series echouees au fallback PRO par serie;
  - ajouter `qz_create_num_temp_lot(...)` pour creer un lot `N` avec les memes noms/descriptifs editoriaux que les `T`;
  - selectionner uniquement `questions_numeriques` certifiees, valides QCM et dans leur fenetre de validite;
  - exclure les questions numeriques recemment utilisees dans des lots `N` du meme client, et les sources deja exclues par le contexte papier quand elles existent.
- [x] Verification locale:
  - `php -l web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php` OK.
- [ ] Verification recette serveur:
  - appeler le helper pack en environnement DB avec `persist=false` pour valider la capacite de selection des trois series;
  - appeler ensuite en environnement de test avec `persist=true` seulement quand le branchement quick sera decide;
  - verifier l'affichage Pro d'une session portant `N{id_history},N{id_arts},N{id_science},L{id}`.

## PATCH 2026-06-24 - Quiz V2: socle lots numeriques `N`
- [x] Audit:
  - consulter `START.md`, `SITEMAP.txt`, `DOCS_MANIFEST.md`, les cartes repos et le journal AI Studio raw avant patch;
  - confirmer que `L` lit `questions`, `T` lit `questions_lots_temp.question_ids` puis `questions`;
  - borner la passe au socle `N`, sans generation rapide, sans generation papier, sans import massif, sans front, sans WS ni scoring.
- [x] Correctif livre:
  - etendre `qz_lot_token_normalize_single(...)`, `qz_lot_tokens_csv_normalize(...)` et `qz_lot_tokens_parse(...)` au prefixe `N`;
  - ajouter les helpers de normalisation/validation digitale pour `questions_numeriques`;
  - ajouter les lectures `qz_num_lot_get_detail(...)` et `qz_num_lot_questions_get_liste(...)`;
  - integrer `N` aux metadonnees de series et a `app_session_quiz_digital_guard_get(...)`;
  - ajouter une migration candidate `questions_numeriques` / `questions_lots_num_temp`;
  - ajouter un script CLI dry-run d'audit des candidats issus des lots `T`, sans ecriture DB.
- [x] Outillage audit/migration securise:
  - migration candidate sans destruction, uniquement `CREATE TABLE IF NOT EXISTS`;
  - commentaires SQL sur la convention `L/T/N` et le stockage inline des propositions `N`;
  - script CLI uniquement, avec `--help` sans connexion DB;
  - mode dry-run implicite, option `--insert` explicitement refusee;
  - sortie texte lisible avec compteurs ready, sans proposition, rejetes et doublons normalises;
  - exports preparatoires `--export-csv` et `--export-sql`, sans import automatique.
- [x] Alignement source candidates:
  - source principale du script CLI remplacee par `questions WHERE id_lot=0`;
  - `questions_lots_temp` conserve uniquement une information secondaire `temp_lot_ids` pour les lignes auditees;
  - audit borne par `--limit` / `--offset`, avec filtres serveur `--status` et `--search`;
  - aucun chargement volontaire de toute la table `questions` sans fenetre SQL.
- [x] Alignement BO:
  - statuts de `questions_numeriques` bornes a `draft`, `reviewed`, `certified`, `rejected`;
  - export SQL preparatoire aligne sur `reviewed` pour compatibilite avec le module BO manuel `www`.
- [x] Verification locale:
  - `php -l web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php` OK;
  - `php -l web/app/modules/jeux/sessions/app_sessions_functions.php` OK;
  - `php -l web/app/modules/jeux/cotton_quiz/tools/qz_questions_numeriques_candidates_audit.php` OK;
  - `php web/app/modules/jeux/cotton_quiz/tools/qz_questions_numeriques_candidates_audit.php --help` OK, sans connexion DB;
  - `git -C /home/romain/Cotton/global diff --check` OK.
- [ ] Verification recette serveur:
  - appliquer la migration candidate sur une base de test;
  - creer un lot `questions_lots_num_temp` de controle;
  - verifier la resolution `N{id}` et une playlist mixte `L/T/N`;
  - verifier que `L` et `T` conservent leur comportement historique.

## PATCH 2026-06-23 - Evenements: wording public nom genere
- [x] Correctif livre:
  - ajouter `app_evenement_public_name_normalize(...)` pour transformer les noms generes `Evenement Cotton du ...` en `Evenement du ...` a l'affichage;
  - faire generer les nouveaux pivots automatiques avec `Événement du ...`;
  - ne pas migrer les noms existants ni toucher aux noms personnalises.
- [x] Verification locale:
  - `php -l web/app/modules/operations/evenements/app_evenements_functions.php` OK.

## PATCH 2026-06-22 - Evenements pivot: isolation par date cible
- [x] Correctif livre:
  - ajouter `app_evenement_pivot_detail_matches_day(...)` pour valider client, slug pivot cible et dates;
  - ajouter `app_evenement_pivot_sessions_detach_for_day(...)` pour nettoyer une session de date cible qui porte encore un ancien pivot automatique;
  - durcir `app_evenement_pivot_ensure_for_day(...)`: un evenement deja rattache n'est reutilise que s'il correspond a la date cible;
  - refuser un evenement trouve par slug cible si ses dates ne correspondent pas;
  - ne pas copier nom, accroche, description, lieu/adresse, lien externe ni visuel d'un ancien evenement vers un nouveau pivot.
- [x] Verification locale:
  - `php -l web/app/modules/operations/evenements/app_evenements_functions.php` OK.
- [ ] Verification recette serveur:
  - creation nouvelle date gamification apres personnalisation d'un ancien evenement;
  - ajout session autre date depuis pivot existant;
  - modification date session rattachee a un pivot automatique;
  - deplacement groupe complet via `sessions_day_move`.

## PATCH 2026-06-22 - Evenements pivot: deplacement date groupe
- [x] Correctif livre:
  - ajouter `app_evenement_pivot_managed_event_move_date(...)`;
  - limiter le helper aux evenements pivots manages `cotton-event-{id_client}-{YYYYMMDD}`;
  - mettre a jour `date_debut`, `date_fin` et `seo_slug` du pivot quand un groupe complet est deplace vers une nouvelle date;
  - deplacer aussi le dossier de branding evenement de l'ancien slug vers le nouveau pour conserver le visuel personnalise;
  - mettre a jour `date_maj` afin que les URLs de visuels versionnees soient rafraichies;
  - refuser le changement si le slug cible appartient deja a un autre evenement;
  - ne pas modifier les vrais evenements/operations historiques.
- [x] Verification locale:
  - `php -l web/app/modules/operations/evenements/app_evenements_functions.php` OK;
  - `git -C /home/romain/Cotton/global diff --check` OK.
- [ ] Verification recette serveur:
  - deplacement d'un evenement pivot gamification personnalise vers une date libre;
  - verification conservation nom, description, visuel, lieu/adresse et URL publique;
  - verification presence du visuel sur le nouveau slug cote PRO et WWW;
  - tentative avec slug cible deja existant.

## PATCH 2026-06-19 - Evenements: naming_nom organisateur public
- [x] Correctif livre:
  - assurer idempotemment la colonne `operations_evenements.naming_nom`;
  - remonter `naming_nom` dans les lectures detail evenement par ID et slug;
  - sauvegarder `naming_nom` depuis `app_evenement_pivot_update_infos(...)`;
  - ne pas modifier le nom du compte client.
- [x] Verification locale:
  - `php -l web/app/modules/operations/evenements/app_evenements_functions.php` OK.
- [ ] Verification recette serveur:
  - première sauvegarde sur base sans colonne;
  - lecture page evenement avec champ rempli et champ vide.

## PATCH 2026-06-19 - Branding événement: normalisation JPG
- [x] Correctif livre:
  - conserver `place-bandeau-1.jpg` et `bingo-musical-grid-html-bandeau-1.jpg` comme artefacts publics du visuel événement;
  - accepter les sources `jpg`, `jpeg`, `png`, `webp` via l'uploader existant;
  - convertir la source recadrée en JPG final pour ne pas casser la lecture publique hardcodée en `.jpg`;
  - supprimer les anciennes variantes nommées `.jpg`, `.jpeg`, `.png`, `.webp` avant remplacement;
  - ajouter le support WebP au recadrage commun.
- [x] Verification locale:
  - `php -l web/app/modules/operations/evenements_branding/app_evenements_branding_functions.php` OK;
  - `php -l web/lib/core/lib_core_upload_functions.php` OK.
- [ ] Verification recette serveur:
  - upload PNG/WebP événement puis vérifier présence des deux JPG finaux et affichage public.

## PATCH 2026-06-18 - Evenements pivot gamification managés
- [x] Correctif livre:
  - ajout de `app_evenement_pivot_detail_is_managed(...)` pour reconnaître strictement les événements automatiques `cotton-event-{id_client}-{YYYYMMDD}`;
  - validation optionnelle du client propriétaire et cohérence `date_debut/date_fin` avec le slug pivot, y compris si les dates remontent au format datetime;
  - ajout de `app_evenement_pivot_session_reassign_after_date_change(...)`;
  - détachement d'une session de son ancien pivot automatique quand sa date change;
  - réutilisation de `app_evenement_pivot_ensure_for_day(...)` pour rattacher la session au pivot de sa nouvelle date quand elle reste future/courante;
  - aucun changement pour les vrais événements/opérations historiques.
- [x] Verification locale:
  - `php -l web/app/modules/operations/evenements/app_evenements_functions.php` OK;
  - `git diff --check` OK.

## ROLLBACK 2026-06-18 - Signal officiel visible: historique borne
- [x] Stabilisation:
  - rollback complet du changement dans `app_client_has_visible_official_session_signal($id_client, $require_useful_archive = 0)`;
  - suppression du cache request-scope ajoute dans ce helper;
  - suppression de la requete archive multi-`EXISTS` ajoutee sans `EXPLAIN`/index confirme;
  - retour a l'implementation precedente pour restaurer la performance globale de l'entree EC;
  - aucun changement durable cote `global` conserve dans cette passe.
- [x] Verification locale:
  - `php -l web/app/modules/entites/clients/app_clients_functions.php` OK.

## PATCH 2026-06-15 - Communaute: contexte classements sur periode explicite
- [x] Correctif livre:
  - ajout d'un override de periode a `app_client_joueurs_dashboard_context_compute(...)`;
  - ajout de `app_client_joueurs_dashboard_get_context_for_period($id_client, $date_start, $date_end, $period_label = '')`;
  - reutilisation des memes filtres client, sessions officielles non-demo completes, sessions terminees fiables, participants et podiums/classements que `Ma communaute`;
  - alignement du critere exploitable: une session passee avec participants reels est prise en compte meme si le flag runtime termine n'est pas remonte;
  - correction Bingo: quand un meme joueur gagne plusieurs phases dans une session, les points de phases sont cumules mais la participation deja comptee n'est neutralisee qu'une seule fois;
  - premier consommateur: bilan agrege de la page PRO `/extranet/start/games/day/YYYY-MM-DD`.
- [x] Verification locale:
  - `php -l web/app/modules/entites/clients/app_clients_functions.php` OK.

## PATCH 2026-06-10 - Sessions: signal officiel visible pour nav PRO
- [x] Helper:
  - ajout de `app_client_has_visible_official_session_signal($id_client, $require_useful_archive = 0)`;
  - le mode standard retourne vrai si le client possede une session officielle complete non archivee, ou une archive utile;
  - le mode `require_useful_archive=1` retourne vrai uniquement si le client possede une archive utile;
  - les archives utiles reutilisent `app_client_joueurs_dashboard_session_is_history_useful(...)`, donc les sessions numeriques sans vrais joueurs/resultats ne qualifient pas.
- [x] Verification locale:
  - `php -l web/app/modules/entites/clients/app_clients_functions.php` OK.

## PATCH 2026-06-09 - Widget affiliation reseau ABN
- [x] Correctif livre:
  - `app_client_network_home_widget_get(...)` applique un seuil commun `has_network_banner_value` aux comptes `ABN`;
  - avec ou sans sessions programmees, un `ABN` affiche le widget si le reseau apporte jeux partages, habillage reseau ou stats significatives;
  - les comptes `ABN` sans ce signal sortent avec `abn_no_banner_value`;
  - la sortie `abn_no_actionable_value` est supprimee;
  - l'ancien mode `abn_network_onboarding` est supprime pour les affilies ABN afin de rendre la banniere reseau meme quand `first_party` est visible.
- [x] Verification locale:
  - `php -l global/web/app/modules/entites/clients/app_clients_functions.php` OK.

## PATCH 2026-06-02 - Abonnement reseau: ensure sans double support
- [x] Correctif livre:
  - `app_ecommerce_reseau_offre_dediee_ensure_for_client(...)` reutilise d'abord l'offre support deja rattachee au contrat reseau existant quand elle est valide;
  - la recherche historique par catalogue reste le fallback si aucun contrat support exploitable n'existe;
  - l'objectif est d'eviter qu'un ensure/backfill reseau cree une seconde ligne `Abonnement réseau` pour un siege qui dispose deja d'une offre support rattachee.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK.
- [ ] Verification recette serveur:
  - sur une TdR ayant deja un support rattache, relancer un flux ensure/backfill reseau et verifier qu'aucune nouvelle ligne `ecommerce_offres_to_clients` support n'est creee;
  - verifier que le contrat conserve `id_offre_client_contrat` sur la ligne attendue.

## PATCH 2026-05-22 - BO module aside: hook de rendu cellule
- [x] Correctif livre:
  - `module_aside_get_html(...)` applique le hook optionnel `bo_{module}_list_cell_html_get($field_name, $row_module, $default_html)` sur les cellules non-ID;
  - le rendu par defaut `module_bdd_donnee_afficher(...)` reste le fallback si aucun hook n'est charge;
  - usage initial: rendre lisibles les actions `clients_logs` dans les blocs `Logs` externalises.
- [x] Verification locale:
  - `php -l /home/romain/Cotton/global/web/lib/core/lib_core_module_functions.php` OK;
  - `git -C /home/romain/Cotton/global diff --check` OK.
- [ ] Verification recette serveur:
  - verifier une fiche client BO avec bloc `Logs`;
  - verifier qu'un autre bloc externalise sans hook garde son rendu habituel.

## PATCH 2026-05-22 - Stripe: journal resiliations sans feedback
- [x] Correctif livre:
  - `app_ecommerce_stripe_subscription_cancellation_feedback_capture(...)` insere maintenant les resiliations Stripe meme sans `feedback` ni `comment`;
  - garde-fou ajoute: les lignes sans feedback/commentaire exigent un signal Stripe de resiliation (`canceled_at`, `ended_at`, `cancel_at` ou `cancel_at_period_end`);
  - `user_feedback_events.created_at` priorise `subscription.canceled_at`, puis la date appelant, puis `NOW()`;
  - fallback lisible ajoute: `rating_value=cancellation_requested`, `rating_label=Résiliation demandée`;
  - le backfill CLI et le preview acceptent les resiliations sans feedback/commentaire, priorisent aussi `canceled_at`, scannent les subscriptions actives/trialing avec resiliation planifiee, et peuvent mettre a jour les lignes existantes via `update_existing`.
- [x] Verification locale:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK;
  - `php -l global/web/assets/stripe/sdk/tools/backfill_cancellation_feedback.php` OK.
- [ ] Verification recette serveur:
  - lancer un dry-run du backfill et verifier que les resiliations sans feedback/commentaire remontent comme candidates;
  - verifier une insertion `user_feedback_events` avec `created_at` aligne sur `subscription.canceled_at`;
  - verifier qu'une ligne deja presente est rafraichie quand l'option de mise a jour est activee.
  - verifier qu'une subscription Stripe encore active avec `cancel_at_period_end` remonte via la source active/trialing.

## PATCH 2026-05-21 - Stripe: capture feedback annulation abonnement
- [x] Correctif livre:
  - ajout d'un helper idempotent `app_ecommerce_stripe_subscription_cancellation_feedback_capture(...)`;
  - lecture de `subscription.cancellation_details.feedback`, `comment` et `reason`;
  - insertion dans `user_feedback_events` avec `context_key=stripe_subscription_cancellation`, `display_surface=stripe_billing_portal`, commentaire Stripe, libelle FR et tags Stripe;
  - stockage de la date effective de resiliation dans `tags_json.cancellation_effective_at`;
  - dedoublonnage par `stripe_subscription_id` via `internal_note`;
  - protection si la table `user_feedback_events` n'est pas disponible.
- [x] Backfill ponctuel:
  - ajout du script CLI `global/web/assets/stripe/sdk/tools/backfill_cancellation_feedback.php`;
  - ajout d'un helper global `app_ecommerce_stripe_subscription_cancellation_feedback_backfill_run(...)`;
  - mode `dry-run` par defaut, insertion uniquement avec `--write`;
  - passe Events API sur `customer.subscription.updated` / `customer.subscription.deleted`;
  - passe Subscriptions API sur les souscriptions annulees pour tenter la recuperation au-dela des 30 jours d'evenements Stripe;
  - rattachement strict par `asset_stripe_productId`, sans fallback `customer_id`.
- [x] Verification locale:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK;
  - `php -l global/web/assets/stripe/sdk/tools/backfill_cancellation_feedback.php` OK;
  - `git -C global diff --check -- web/app/modules/ecommerce/app_ecommerce_functions.php` OK.
- [ ] Verification serveur:
  - lancer `php global/web/assets/stripe/sdk/tools/backfill_cancellation_feedback.php dev --limit=50` depuis un serveur ayant acces a la BDD dev;
  - relancer avec `--write` si le dry-run est coherent;
  - refaire en `prod` apres validation dev.
- [ ] Verification recette serveur:
  - resilier une souscription Stripe via le portail avec raison/commentaire;
  - verifier une seule ligne `stripe_subscription_cancellation` dans `user_feedback_events`;
  - verifier le rattachement au client Cotton attendu.

## PATCH 2026-05-18 - Retour LP apres demo reseau
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `www/web/fo/modules/jeux/*/fr/*_script.php`
  - `games/web/includes/canvas/core/end_game.js`
- [x] Correctif livre cote `global`:
  - ajout de `app_session_demo_context_return_url_get()`;
  - reconstruction serveur de `/lp/reseau/{slug}` ou `/lp/operation/{slug}`;
  - rejet implicite des contextes non LP et des slugs hors format.
- [x] Verification locale:
  - `php -l global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [ ] Recette serveur:
  - lancer une demo depuis `/lp/reseau/{slug}`, quitter l'orga, verifier le retour LP;
  - idem `/lp/operation/{slug}`;
  - verifier qu'une demo catalogue standard conserve son retour existant.

## PATCH 2026-05-18 - Upload hero LP reseau sans recadrage force
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/lib/core/lib_core_upload_functions.php`
  - `www/web/lp/lp.php`
- [x] Correctif livre cote `global`:
  - `app_client_lp_asset_uploader(...)` garde le logo a largeur `700` sans hauteur imposee;
  - le `hero` LP passe a largeur maximale `1600` sans hauteur imposee;
  - aucun changement de `upload_image_recadrer()`.
- [x] Verification locale:
  - `php -l global/web/app/modules/entites/clients/app_clients_functions.php`
- [ ] Recette serveur:
  - re-uploader un visuel principal LP `1600 x 900` et verifier qu'il n'est plus coupe;
  - verifier qu'une image tres verticale reste bornee par le rendu LP.

## PATCH 2026-05-14 - Helper BO terminaison offre hors cadre
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [x] Correctif livre cote `global`:
  - ajout de `app_ecommerce_reseau_activation_activate_from_bo_detail(...)` pour conserver `ok`, `id_activation`, `id_offre_client_deleguee` et `blocked_reason`;
  - conservation du wrapper historique `app_ecommerce_reseau_activation_activate_from_bo(...)` en retour `id_activation` pour compatibilite;
  - ajout de `app_ecommerce_reseau_offre_hors_cadre_terminate_from_bo(...)` pour terminer une delegation hors cadre ciblee depuis le BO.
- [x] Garde-fous:
  - offre active uniquement, `id_client` siege, `id_client_delegation` affilie, affilie encore rattache au siege;
  - catalogue hors cadre autorise;
  - refus si l'offre est liee a un support reseau ou si l'activation courante prouve un mode `cadre`;
  - aucune action sur les offres propres affilies ni sur les autres offres du meme affilie.
- [x] Verification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_script.php`
  - `php -l www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
- [ ] Recette serveur:
  - verifier attribution hors cadre BO sans abonnement actif;
  - verifier terminaison hors cadre et maintien affiliation;
  - verifier non-regression PRO commande hors cadre TdR.

## PATCH 2026-05-13 - Helper Home onboarding premiere animation ABN
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/general/branding/app_branding_functions.php`
  - `pro/web/ec/ec.php`
- [x] Correctif livre cote `global`:
  - mise a jour de `app_client_network_home_widget_get($id_client)`;
  - ajout de `app_client_home_onboarding_widget_get($id_client)` pour normaliser le payload onboarding consomme par la Home EC;
  - exclusion des comptes TdR, pipelines hors `INS`/`ABN`/`CSO` et affiliations sans valeur active hors fallback ABN;
  - detection V1 des offres deleguees actives, jeux reseau partages, design reseau valide et stats LP significatives;
  - retour `onboarding_widget` pour tout `ABN` sans session officielle deja programmee, pas seulement aucune session a venir;
  - sessions demo exclues du calcul par le compteur `flag_session_demo=0 AND flag_configuration_complete=1`;
  - jeux reseau partages suffisants pour la variante contextualisee et le CTA reseau, meme sans offre TdR active;
  - fallback generique Cotton ajoute quand aucun contexte exploitable n'existe, avec CTA vers `extranet/games/library?from=agenda&mode=library`;
  - `onboarding_widget` fournit un titre/CTA neutres premiere animation, sans chips ni CTA secondaire;
  - retour `context_banner` commun pour `ABN` deja actif / `INS` / `CSO` avec jeux reseau, design reseau ou stats significatives;
  - le bandeau commun porte le titre factuel `Ton espace Cotton est affilié à : {Nom_contexte}`;
  - aucun CTA dans les bandeaux, aucun affichage sur simple rattachement, support seul ou stats faibles.
- [x] Invariants:
  - aucune modification des regles pipeline;
  - aucune modification catalogue, design reseau ou creation de session;
  - les stats LP existantes sont reutilisees avec les memes seuils;
  - le CTA CAS 1 avec jeux reseau pointe seulement vers le hub reseau en contexte programmation.
- [x] Verification:
  - `php -l global/web/app/modules/entites/clients/app_clients_functions.php`
- [ ] Recette serveur:
  - verifier les 12 cas produit Home EC demandes avec donnees reelles ou fixtures serveur.
- [ ] Limite V1:
  - operation reseau active non cablee: non trouve dans la documentation et pas de source runtime canonique locale identifiee.

## PATCH 2026-05-13 - Stripe webhooks: suppression emails livemode=false
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Correctif livre cote `global`:
  - extension compatible de `app_ecommerce_commande_ajouter(...)` avec `$email_options`;
  - suppression optionnelle des emails Brevo admin commande et AI Studio `INVOICE_MONTHLY` quand le webhook Stripe transmet `suppress_stripe_webhook_emails=1`;
  - log technique `[Stripe Webhook][Email Suppressed] livemode=false` pour chaque email ignore.
- [x] Invariants:
  - aucun critere Cotton opportuniste (`flag_test`, `mode_test`, etc.);
  - aucun usage du prefixe `[ TEST ]` comme source de verite;
  - aucune modification des commandes, factures, montants, paiements, statuts ou synchronisations.
- [x] Verification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l pro/web/ec/ec_webhook_stripe_handler.php`

## PATCH 2026-05-12 - Stats preuve sociale LP reseau
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `www/web/bo/www/modules/syntheses/facturation_pivot/bo_facturation_pivot_games_aggregates.php`
  - `pro/web/ec/modules/compte/client/ec_client_list.php`
- [x] Correctif livre:
  - ajout de `app_client_network_lp_stats_get($id_client_reseau)`;
  - comptage des affilies via `clients.id_client_reseau`;
  - comptage des sessions via jointure `championnats_sessions` + `clients`, hors demos et avec configuration complete;
  - comptage joueurs uniquement depuis l'agregat `reporting_games_players_monthly`, si la table existe;
  - application serveur des seuils commerciaux V1 et exclusion automatique des indicateurs absents/faibles;
  - seuils affichables: affilies >= 3, sessions >= 5, joueurs >= 100;
  - seuils signal fort: affilies >= 20, sessions >= 50, joueurs >= 1000;
  - bloc affichable si au moins 2 indicateurs passent les seuils, ou si 1 indicateur atteint un seuil signal fort.
- [x] Donnees exclues V1:
  - recalcul direct des joueurs depuis tables runtime, juge trop couteux/ambigu pour une LP publique.
- [ ] Verification recette serveur:
  - TdR sous seuils: aucun bloc;
  - TdR avec deux indicateurs au-dessus des seuils: bloc affiche;
  - TdR avec un seul indicateur tres fort: bloc affiche;
  - agregat joueurs absent/vide: indicateur joueurs masque sans erreur.

## PATCH 2026-05-12 - Couleurs LP reseau dediees TdR
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `www/web/bo/master/bo_master_form.php`
  - `www/web/lp/lp.php`
- [x] Correctif livre:
  - ajout lazy-init des colonnes `clients.lp_reseau_couleur_principale` et `clients.lp_reseau_couleur_secondaire`;
  - ajout des helpers `app_client_lp_color_normalize`, `app_client_lp_colors_get` et `app_client_lp_colors_save`;
  - ajout du helper `app_client_signup_network_theme_get` pour composer l'habillage signup/signin affilie depuis logo/visuel LP puis branding historique, sans appliquer les couleurs LP au formulaire PRO;
  - valeurs vides autorisees, valeurs invalides neutralisees, valeurs valides normalisees en `#RRGGBB`;
  - script SQL d'alignement ajoute: `documentation/lp_reseau_couleurs_clients_phpmyadmin.sql`.
- [ ] Verification recette serveur:
  - appliquer/valider les colonnes sur dev/prod avant edition BO si le lazy-init ne suffit pas;
  - verifier la persistence et la lecture publique sur une TdR reelle.

## PATCH 2026-05-11 - Abonnement reseau: echeance date_fin et incluses
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Cause confirmee:
  - le cron historique termine les PAK, ABN one-shot et ABN sans engagement expires;
  - l'Abonnement reseau n'avait pas de traitement dedie garantissant l'appel au helper canonique de cloture runtime;
  - les incluses creees sous support reseau ne recuperaient pas systematiquement la `date_fin` du support.
- [x] Correctif livre:
  - ajout de `app_ecommerce_reseau_support_offers_expired_process(...)`;
  - ajout de `app_ecommerce_reseau_support_offer_included_date_fin_sync(...)`;
  - propagation de la `date_fin` support a la creation d'une incluse cadre;
  - appel cron depuis `cron_routine_bdd_maj.php`.
- [x] Invariants:
  - aucune offre propre ni hors cadre n'est fermee par ce flux;
  - une incluse deja terminee n'est pas rouverte ni modifiee;
  - le refresh reseau ne recree pas de support actif et la finalisation archive le runtime.
- [x] Verification:
  - `php -l global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l www/web/bo/cron_routine_bdd_maj.php`
  - `php -l www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`

## PATCH 2026-05-11 - Demos LP reseau rattachees au compte TdR
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `www/web/lp/lp.php`
  - `www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_script.php`
  - `www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_script.php`
  - `www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_script.php`
  - `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Cause confirmee:
  - les formulaires demo LP lancaient les scripts standards avec seulement `frm_mode=session_demo` et `id_catalogue_produit`;
  - les scripts demo forcaient le compte porteur standard `1557`;
  - le design reseau peut etre retrouve depuis le compte TdR, car `app_general_branding_get_detail(...)` traite un `id_client` TdR comme source de branding reseau.
- [x] Correctif livre:
  - ajout d'une resolution serveur du compte TdR a partir du slug public LP reseau/operation;
  - seuls les contextes `reseau` et `operation` sont acceptes;
  - le client resolu doit etre un compte `flag_client_reseau_siege=1`, sinon le fallback demo standard reste `1557`;
  - `app_session_demo_ajouter(...)` conserve les flags demo prives/non officiels existants.
- [x] Invariants:
  - aucun `id_client` sensible n'est transmis cote public;
  - aucune session officielle ou facturable n'est creee par ce flux;
  - les demos standards hors LP reseau/operation gardent le compte demo historique;
  - aucun droit BO/pro n'est donne au visiteur.
- [x] Verification:
  - `php -l global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l www/web/fo/modules/jeux/blind_test/fr/fo_blind_test_script.php`
  - `php -l www/web/fo/modules/jeux/bingo_musical/fr/fo_bingo_musical_script.php`
  - `php -l www/web/fo/modules/jeux/cotton_quiz/fr/fo_cotton_quiz_script.php`

## PATCH 2026-05-06 — Stripe ABN: recalcul pipeline client apres cloture terminale
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- [x] Cause confirmee:
  - `customer.subscription.updated/deleted` appelle bien `app_ecommerce_stripe_subscription_terminal_sync(...)` quand Stripe est terminal;
  - ce helper passe l'offre Cotton en `id_etat=4`, mais ne recalculait pas le pipeline du client payeur direct;
  - la logique historique `PAK/ABN -> CSO` existait dans des parcours internes mais pas dans ce webhook Stripe.
- [x] Correctif livre:
  - ajout de `app_ecommerce_client_pipeline_sync_from_effective_offer(...)`;
  - la routine relit l'acces effectif via `app_ecommerce_offre_effective_get_context(...)`;
  - elle conserve `ABN` si une offre active de type abonnement reste effective, bascule `PAK` si l'offre effective restante est un pack, et repasse `CSO` seulement si aucun acces effectif ne reste;
  - `app_ecommerce_stripe_subscription_terminal_sync(...)` appelle cette routine apres la cloture d'offre Stripe pour les offres directes hors support reseau;
  - log sobre ajoute uniquement si le pipeline change: `id_client`, `id_offre_client`, ancien/nouveau pipeline, raison.
- [x] Invariants:
  - aucune migration SQL;
  - aucun changement sur `cancel_at_period_end` tant que l'offre reste active;
  - aucun double traitement Stripe;
  - les offres deleguees et supports reseau gardent les synchronisations existantes.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php`

## PATCH 2026-05-05 — Branding Canvas: sauvegarde merge-safe des designs partiels
- [x] Audit confirme dans:
  - `global/web/app/modules/general/branding/app_branding_ajax.php`
  - `games/web/includes/canvas/core/session_modals.js`
  - `games/web/player_canvas.php`
  - `games/web/remote_canvas.php`
- [x] Cause confirmee:
  - le save branding global reconstruisait les metadonnees depuis les seules cles POST;
  - une cle couleur/police absente pouvait donc retomber a `''`;
  - `logo_mode=original` ou `visuel_mode=original` sans fichier/URL etait interprete comme une suppression media;
  - un save partiel couleur-only pouvait donc vider ou remplacer un logo/visuel existant consomme ensuite par player/remote.
- [x] Correctif livre:
  - avant `app_general_branding_modifier(...)`, l'endpoint relit le branding existant via `app_general_branding_get_complete(...)`;
  - chaque champ meta (`color_background_1`, `color_background_2`, `color_font_1`, `color_font_2`, `font_family_name`, `font_family_url`) utilise la valeur POST si elle existe, sinon la valeur existante;
  - les medias absents passent en operation `preserve`;
  - la suppression media demande maintenant une intention explicite `logo_clear=1` ou `visuel_clear=1`;
  - la reponse `save` expose aussi le branding effectif apres sauvegarde pour que `games` rediffuse un payload live complet.
- [x] Invariants:
  - aucun changement de schema;
  - les uploads fichier/URL existants restent supportes;
  - les resets volontaires restent possibles via marqueur explicite;
  - la resolution player/remote continue de relire le branding effectif via l'API existante.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php`

## PATCH 2026-04-29 — Stripe ABN: helpers relance visible et cloture terminale
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Correctif livre:
  - ajout d'un helper de date terminale Stripe priorisant `ended_at`, puis `canceled_at`, puis `current_period_end`, puis la date courante;
  - ajout d'un append idempotent dans `ecommerce_offres_to_clients.commentaire` pour tracer une cloture Stripe due a `payment_failed`;
  - ajout d'un helper de synchronisation terminale qui passe l'offre en `id_etat=4` sans creer de commande ni facture;
  - ajout d'un helper de lecture live Stripe pour exposer un bandeau PRO quand la subscription est `past_due` ou `unpaid`;
  - le helper remonte aussi le statut de la derniere facture Stripe et `amount_remaining` afin de confirmer un retour portail seulement quand la facture est payee ou soldee.
- [x] Invariants:
  - aucune migration SQL;
  - pas de table dediee aux incidents Stripe;
  - le champ Stripe de rattachement reste `asset_stripe_productId`;
  - `id_etat=1` reste hors V1 car le cron l'annule ensuite en `id_etat=10`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-29 — Quiz V1: etat simplifie sans runtime `running`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Correctif livre:
  - pour `Cotton Quiz V1` (`id_type_produit=1`), `app_session_edit_state_get(...)` ne fabrique plus d'etat `running` a partir de la date;
  - une session V1 non archivee par date reste `pending`;
  - une session V1 archivee par date devient `terminated`;
  - la fiche detail PRO ne doit donc plus afficher `Session en cours` pour une V1 sur la seule base de la date.
- [x] Invariants:
  - aucun changement pour les produits runtime `3/4/5/6`;
  - le fallback historique V1 reste base sur la date, faute de runtime fiable;
  - les regles d'archives existantes restent portees par `app_session_is_archive(...)`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `git -C /home/romain/Cotton/global diff --check`

## PATCH 2026-04-27 — Cotton Quiz V2: anti-rejeu papier et visuels par `lot_ids`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - le controle anti-rejeu des questions papier ne consultait que les tables historiques `quizs`, `quizs_series`, `quizs_series_to_questions`;
  - les sessions `Quiz V2` stockent leur composition dans `championnats_sessions.lot_ids`, avec les questions des lots temporaires dans `questions_lots_temp.question_ids`;
  - la borne future legacy excluait les sessions au-dela de `+350j`, pas les sessions a venir dans la fenetre utile;
  - le visuel des cartes pouvait encore etre resolu via les anciennes series legacy, ce qui faisait remonter un visuel de lot sans rapport ou le fallback malgre un lot `L...` illustre.
- [x] Correctif livre:
  - `qz_temp_ctx_init(...)` accepte maintenant un `session_id` et une fenetre configurable;
  - les exclusions couvrent les sessions passees et futures dans une fenetre symetrique;
  - les lots temporaires `T...` des sessions V2 voisines sont lus via `questions_lots_temp` et ajoutes aux questions exclues;
  - la construction papier tente des fenetres de repli `350`, `300`, `240`, `180`, `120`, `60` jours jusqu'a obtenir les trois lots temporaires complets;
  - ajout de helpers de visuel par lot/session V2 pour selectionner uniquement les visuels custom des lots `L...`, avec fallback propre sur `default_cotton_quiz.jpg`;
  - `app_jeu_get_detail(...)` accepte les `lot_ids` de session pour reconstruire les metadonnees et le visuel V2 depuis la vraie composition programmee.
- [x] Addendum prod:
  - `app_cotton_quiz_get_session_visual_src(...)` ne retombe plus sur `app_cotton_quiz_get_series_visual_src(...)` quand `lot_ids` est vide;
  - sans `lot_ids`, un visuel `Quiz V2` renvoie le defaut plutot qu'un visuel legacy potentiellement faux.
- [x] Ajustement regle metier:
  - en presence de plusieurs lots `L...`, le helper selectionne maintenant le dernier `L...` de `lot_ids`;
  - le visuel de ce lot est utilise s'il est custom, sinon le helper renvoie le defaut.
- [x] Nettoyage post-validation:
  - retrait de l'instrumentation temporaire `QUIZ_V2_SESSION_VISUAL_RESOLVE` apres confirmation dev/prod;
  - retour au contrat simple `app_jeu_get_detail(..., $lot_ids)` et `app_cotton_quiz_get_session_visual_src($lot_ids, $id_quiz_client)`.
- [x] Invariants:
  - les lots `L...` ne sont pas inspectes pour exclure leurs questions lors de la generation `T...`, car le generateur temporaire ne selectionne que des `questions.id_lot = 0`;
  - les lots `T...` ne sont pas candidats au visuel de session;
  - aucune generation incomplete n'est acceptee.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `git diff --check`

## PATCH 2026-04-17 — Leaderboards quiz legacy: rang de session recalcule depuis les scores
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - references relues:
    - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
    - `global/web/app/modules/jeux/sessions/app_sessions_functions_20250521.php`
- [x] Cause confirmee:
  - l'agregat `Mes joueurs` quiz legacy attribuait encore ses points saison via `championnats_resultats.position`;
  - pour des sessions legacy recentes, cette colonne est incoherente voire a `1` partout, alors que `equipe_session_points` reste correcte;
  - les fiches session quiz legacy sont donc justes, mais les leaderboards agreges `pro/play/www` deviennent faux.
- [x] Correctif livre:
  - pour les quiz legacy uniquement, le dashboard recalcule maintenant le rang de chaque session a partir de `equipe_session_points`, puis `equipe_quiz_points` en tie-break;
  - le bareme saison conserve le contrat existant `1er 500 / 2e 300 / 3e 200 / participation 100`, sans dependre de `championnats_resultats.position`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-17 — Photos podium player: consentement par upload trace et transactionnel
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependances relues:
    - `games/web/includes/canvas/php/boot_lib.php`
    - `games/web/includes/canvas/sql/2026-04-17_player_podium_photo_consent.sql`
- [x] Besoin retenu:
  - reutiliser le pipeline upload podium existant cote `global`;
  - ajouter une preuve de consentement obligatoire sans transformer un consentement photo en simple flag global de compte.
- [x] Correctif livre:
  - `app_session_results_podium_photo_upload(...)` accepte maintenant un bloc optionnel `consent`;
  - sur succes upload, le helper persiste une preuve dans `championnats_sessions_podium_photos_consents`;
  - addendum 2026-04-17:
    - la persistance de consentement snapshotte maintenant aussi le pseudo/libelle runtime du podium uploadant;
    - l'eligibilite player ne depend plus d'un bridge EP preexistant.
    - la provenance de la photo visible est maintenant relue depuis la trace de consentement (`player` vs `organizer`);
    - si la photo visible provient d'un organisateur, le helper d'acces player la considere comme verrouillee pour le joueur.
  - si l'ecriture de consentement echoue, le media podium nouvellement cree est supprime et la requete echoue.
- [x] Stockage retenu:
  - consentement porte par l'upload, avec lien vers le media et duplication des ids joueur/runtime/bridge utiles a l'audit.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-17 — Libelles joueur partages: prenom only hors pseudo
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - les classements agreges reutilisaient encore un helper commun qui retombait sur `prenom + nom` quand aucun pseudo n'etait disponible;
  - resultat: les sessions affichaient deja des libelles courts, mais certains podiums/classements agreges montraient encore le nom de famille.
- [x] Correctif livre:
  - `app_client_joueurs_dashboard_player_label_get(...)` renvoie maintenant:
    - `pseudo` si disponible;
    - sinon `prenom` seul;
    - sinon `Joueur`.
  - les surfaces qui reutilisent ce helper via le socle partage s'alignent donc sur un affichage joueur `prenom-only`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-17 — Ordre des ex aequo aligne sur `games` pour les resultats de session
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - references relues:
    - `quiz/web/server/actions/gameplay.js`
    - `blindtest/web/server/actions/gameplay.js`
- [x] Cause confirmee:
  - les vues `pro` / `play` / `www` rebrassaient encore localement certaines lignes de podium a egalite de rang;
  - cote `quiz` / `blindtest`, le runtime `games` utilise un ordre stable sur les ex aequo base sur `playerId`;
  - cote `global`, les resultats de session modernes ne relisaient pas toujours cette cle runtime stable, et la normalisation de podium pouvait re-trier differemment du classement complet.
- [x] Correctif livre:
  - `app_session_results_get_context(...)` relit maintenant `player_id` des tables runtime `cotton_quiz_players` / `blindtest_players` quand il existe;
  - cette cle devient la cle d'ordre secondaire prioritaire du classement complet, pour coller au comportement `games`;
  - `app_session_results_podium_normalize(...)` preserve maintenant l'ordre source entre ex aequo au lieu de re-trier par libelle.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-16 — Sessions demo: le helper de statut suit de nouveau le runtime reel
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - `app_session_edit_state_get(...)` court-circuitait encore toute session demo avant le calcul metier par type de jeu;
  - le polling `pro` restait donc actif mais sans jamais pouvoir refléter l'etat reel `pending/running/terminated` d'une demo.
- [x] Correctif livre:
  - retrait du `return` anticipe sur `flag_session_demo = 1` dans `app_session_edit_state_get(...)`;
  - les demos suivent a nouveau le meme calcul runtime que les sessions standard selon leur type et leur etat reel;
  - une demo relancee revient donc naturellement a `is_pending = 1` si son runtime est vraiment reinitialise.
- [x] Invariant conserve:
  - aucun changement cote `games` sur le bypass de relance demo.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-16 — QR code place: suppression du `chmod()` serveur-dépendant
- [x] Audit confirme dans:
  - `global/web/app/modules/qr_code/app_qr_code_place_generator.php`
- [x] Cause confirmee:
  - l'initialisation du generateur QR tentait un `chmod()` sur `sys_get_temp_dir() . '/tmp_qr_codes'` quand `is_writable()` echouait;
  - sur certains environnements `dev`, cette operation est interdite, ce qui faisait remonter un warning PHP lors d'un parcours indirect appelant encore le generateur QR.
- [x] Correctif livre:
  - suppression de la tentative de `chmod()`;
  - fallback simple vers `sys_get_temp_dir()` quand le sous-dossier applicatif ne peut pas etre cree ou n'est pas writable.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/qr_code/app_qr_code_place_generator.php`

## PATCH 2026-04-15 — `Mes joueurs`: requetes dashboard alignees sur `app_session_edit_state_get`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - le dashboard `Mes joueurs` passait a `app_session_edit_state_get(...)` des lignes `championnats_sessions` partielles ne contenant pas `flag_session_demo`;
  - le helper global lisait encore cet index sans garde, ce qui provoquait des notices PHP repetitives sur `GET /extranet/players?async=1`.
- [x] Correctif livre:
  - ajout de `flag_session_demo` dans les deux requetes source du dashboard (`period_has_leaderboard_data` et `context_compute`);
  - durcissement de `app_session_edit_state_get(...)` pour retomber sur `0` si le detail session fourni est partiel.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-15 — `Mes joueurs`: garde `Bingo` quand une playlist client n'existe plus
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - certaines sessions `Bingo Musical` arrivent encore avec un `id_produit` dont la ligne `jeux_bingo_musical_playlists_clients` n'existe plus ou n'est plus relisible;
  - le helper `app_jeu_get_detail()` dereferencait alors sans garde la playlist client puis son catalogue, ce qui finissait en fatal via `module_get_detail()`.
- [x] Correctif livre:
  - le chemin `type 3/6` de `app_jeu_get_detail()` verifie maintenant d'abord la presence effective de la playlist client;
  - le catalogue playlist, le format et `flag_controle_numerique` sont ensuite relus de facon defensive avec fallback vide / `0`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-15 — Photos podium `pro` / `play`: fallback `prod` en environnement `dev`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - le helper de resolution photo podium privilegiait encore l'URL `www dev` quand le fichier etait absent localement, ce qui ne permettait pas de reutiliser en dev une photo publiee uniquement sur l'environnement `prod`.
- [x] Correctif livre:
  - en `dev`, pour les stockages podium publics `www` / `cotton-quiz` / `cotton_quiz`, le fallback URL choisit maintenant d'abord `www_url['prod']`;
  - cela aligne `pro` / `play` sur le confort de verification deja utilise cote FO.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-15 — `Mes joueurs`: alias photo podium renforces pour participants renommes
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause complementaire confirmee:
  - certains chemins runtime `quiz` / `blindtest` / `bingo` sortaient encore avant d'enregistrer l'ancien `username` comme alias sessionnel quand une liaison `games_connectees` existait deja;
  - le fallback `quiz legacy results` attribuait bien les points, mais ne contribuait pas au dictionnaire `label session -> identity` reutilise pour retrouver les photos podium archivees.
- [x] Correctif livre:
  - enregistrement de l'alias brut `username` avant les `continue` runtime lies aux bridges;
  - ajout de l'alias sessionnel dans le chemin `quiz legacy results`;
  - consolidation du helper de podium agrege pour sortir completement une ligne une fois sa photo resolue par identite.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-15 — `Mes joueurs`: podium agrégé de saison enrichi avec la dernière photo podium disponible
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livre:
  - le contexte leaderboard de `Mes joueurs` expose maintenant aussi `players_podium` / `teams_podium`;
  - ces lignes podium reprennent le top 3 agrégé de la saison en conservant score, rang et identité;
  - pour chaque participant ou equipe du podium, le socle relit les sessions classées de la période et reutilise la dernière `photo_src` disponible dans les podiums de sessions déjà archivées;
  - la resolution photo ne depend plus seulement du libelle courant: si un pseudo/nom a change en cours de saison, le rapprochement priorise maintenant l'identite metier sessionnelle pour retrouver la photo historique correspondante;
  - addendum 2026-04-15:
    - les branches runtime `quiz`, `blindtest`, `bingo` et la source `quiz teams` enregistrent maintenant aussi explicitement leurs alias `label session -> identity`;
    - le podium de saison peut donc recroiser les photos meme quand le label historique n'etait connu que dans les tables runtime.
  - si aucune photo n'est trouvée, la ligne podium reste exploitable sans image.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-15 — Photos podium sessions: `play` relit maintenant le stockage public `www`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependances relues:
    - `play/web/config.php`
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
    - `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- [x] Cause confirmee:
  - le helper global `app_session_results_podium_photo_src_from_media(...)` calculait ses chemins et URLs depuis `upload_path` / `upload_root` du front appelant;
  - en `play`, ces bases ne pointent pas proprement vers le stockage public `www` des photos podium de session;
  - resultat: la fiche detail `play` pouvait recevoir une URL photo non resolue ou basee sur une mauvaise racine, alors que `pro` affichait bien la photo.
- [x] Correctif livre:
  - les photos podium publiques (`www`, `cotton-quiz`, `cotton_quiz`) se resolvent maintenant explicitement via `www_root` / `www_url`;
  - la verification locale, l'URL finale et le log de fallback utilisent donc la meme racine publique quel que soit le front appelant.
  - addendum 2026-04-15:
    - le fallback `dev` respecte maintenant d'abord `www_url[$conf['server']]`;
    - le repli vers `www_url['prod']` ne se fait plus que si l'environnement courant n'a pas de racine publique `www` disponible.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-13 — Podium sessions: priorité des photos historiques `Quiz V1`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - la lecture des photos podium essayait d'abord les stockages modernes par rang / ligne avant le fallback historique `cotton-quiz/championnats/resultats`;
  - sur les sessions `Quiz V1`, cela pouvait masquer les photos historiques deja associees aux resultats legacy.
- [x] Correctif livre:
  - pour `game_key = quiz_legacy`, la lecture des photos repasse maintenant d'abord par le stockage historique attache au resultat legacy;
  - les stockages modernes par rang / ligne restent utilises uniquement en fallback si aucune photo historique n'est retrouvee.
  - en plus, le fallback legacy couvre maintenant aussi plusieurs conventions d'emplacement / nommage historiques autour de `championnats/resultats`, avec recherche directe d'un fichier `id_resultat.(jpg|jpeg|png|webp)` si le media legacy existe mal ou pointe sur un chemin devenu obsolete.
  - le helper d'URL accepte aussi a nouveau l'ancien schema de repertoire `u/t` (ex. `cotton-quiz/championnats/resultats`) quand le chemin migre sans `$u` ne resolve pas le fichier.
  - la resolution relit maintenant aussi les vrais champs `a/u/t/m` du media en base quand un `media_id` est disponible, puis teste les variantes legacy `-/_` avant de retomber sur une URL par defaut.
  - en environnement `dev`, si une photo historique publique n'existe pas localement mais reste attendue cote `www`, l'URL retombe maintenant sur la racine publique `www_url['prod']` au lieu de reutiliser par erreur le domaine du contexte appelant (`pro`, etc.).
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-13 — Fiche session: message de classement aligné avec le fallback Bingo legacy `2/3`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - la fiche detail de session testait uniquement `session_edit_state['is_terminated']` pour choisir le message de classement manquant;
  - pour certaines sessions Bingo legacy `2/3` considerees historiques via fallback date, on affichait donc encore a tort `Cette session n'a pas été jouée jusqu'au bout`.
- [x] Correctif livre:
  - le helper de message traite maintenant les Bingos legacy `2/3` passes en date comme des sessions historiquement terminees au sens du fallback;
  - dans ce cas, la fiche detail bascule sur un message d'absence de classement exploitable, au lieu du message `pas jouée jusqu'au bout`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-13 — `Mes joueurs`: le Bingo legacy type `2` rentre dans l'historique utile, avec fallback date sur `2/3`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - dependance relue:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Cause confirmee:
  - le type produit `2` correspond au Bingo legacy mais etait encore exclu du moteur `Mes joueurs`;
  - le besoin metier retenu est d'inclure ce legacy Bingo dans `Archives` / `Mes joueurs`, avec un fallback par date passee pour les types `2/3`, y compris sur les sessions numeriques.
- [x] Correctif livre:
  - le mapping jeu rattache maintenant aussi `id_type_produit = 2` a `Bingo Musical`;
  - les requetes source `Mes joueurs` / detection de periodes incluent maintenant le type `2`;
  - le helper de terminaison historique applique maintenant un fallback par date passee pour les sessions Bingo `2/3`, qu'elles soient papier ou numeriques;
  - le type `6` reste hors de ce fallback et doit etre reellement termine runtime.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — `Mes joueurs` / `Archives`: le fallback Bingo papier n'est plus autorisé sur le type `6`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmee:
  - le fallback legacy ajoute pour preserver certains vieux Bingos papier etait applique a tous les Bingos papier `id_type_produit IN (3,6)`;
  - consequence: des sessions papier recentes de type `6`, passees en date mais non reellement terminees runtime, pouvaient remonter dans `Archives` et entrer dans les agregats `Mes joueurs`.
- [x] Correctif livre:
  - le fallback par date sur session papier est maintenant borne au seul Bingo legacy `id_type_produit = 3`;
  - les sessions Bingo papier type `6` doivent desormais etre reellement terminees pour remonter dans l'historique utile.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — `Mes joueurs`: le selecteur de periodes oubliait la `date` des Quiz legacy
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmee:
  - la synthese `Mes joueurs` charge les sessions avec `date` et compte donc correctement les sessions `Quiz V1` legacy;
  - le helper `app_client_joueurs_dashboard_period_has_leaderboard_data()` ne selectionnait en revanche que `id`, `id_securite`, `id_type_produit`, `id_produit`;
  - or `app_client_joueurs_dashboard_session_is_reliably_terminated()` a besoin de `date` pour considerer un `id_type_produit = 1` comme termine;
  - resultat: les sessions `Quiz V1` etaient visibles dans la synthese mais exclues du selecteur d'annees / saisons.
- [x] Correctif livre:
  - la requete source du helper de periodes charge maintenant aussi `date` et `flag_controle_numerique`, comme le moteur principal de synthese / classement;
  - les periodes contenant uniquement du `Quiz V1` legacy peuvent donc de nouveau etre reconnues comme eligibles.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — `Mes joueurs`: rollback de l'hypothese erronée sur `id_type_produit = 2`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmee:
  - l'hypothese precedente etait fausse: `id_type_produit = 2` correspond au Bingo legacy, pas a `Cotton Quiz`;
  - l'extension de couverture Quiz vers le type `2` etait donc incorrecte et devait etre retiree du moteur `Mes joueurs`.
- [x] Correctif livre:
  - rollback des elargissements Quiz `id_type_produit = 2` dans le mapping jeu, la detection des periodes, le filtrage des sessions et les requetes leaderboard;
  - invalidation du cache `Mes joueurs` via une nouvelle version pour purger tout contexte reconstruit sur cette mauvaise hypothese.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — Historique EC / `Mes joueurs`: Bingo privilégie la vraie fin runtime avec fallback legacy borné
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - dependances relues:
    - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
- [x] Cause confirmee:
  - le moteur partage `app_client_joueurs_dashboard_session_is_reliably_terminated()` traitait encore `Bingo Musical` comme historiquement termine des que `date < today`;
  - l'onglet `Archives` EC reutilisait bien ce moteur, ce qui permettait a une session bingo passee mais non terminee de rester visible si elle avait des participants.
- [x] Correctif livre:
  - `Bingo Musical` repasse maintenant par `app_session_edit_state_get()` comme les autres jeux modernes;
  - si le runtime Bingo est encore disponible, seule une vraie fin runtime valide la session historique;
  - pour les sessions Bingo papier, un fallback legacy par date reste autorise meme si la ligne playlist existe encore mais n'a jamais remonte de fin runtime exploitable;
  - pour les sessions Bingo numeriques, le fallback legacy par date n'est utilise que si la ligne `jeux_bingo_musical_playlists_clients` n'est plus exploitable;
  - le filtre participants reels continue de ne s'appliquer qu'aux sessions numeriques, ce qui preserve les vieux Bingos papier;
  - l'agenda `Archives` EC et `Mes joueurs` restent alignes sur le meme contrat metier.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — Upload podium mobile: premier vrai fichier + orientation EXIF JPEG
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/lib/core/lib_core_upload_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Cause confirmee:
  - le write path podium relisait historiquement `files_img[0]`, ce qui cassait les formulaires mobiles embarquant plusieurs inputs homonymes;
  - le pipeline upload image commun ne normalisait pas l'orientation EXIF des JPEG avant resize/crop.
- [x] Correctif livre:
  - la selection de photo podium isole maintenant le premier fichier effectivement present dans le payload upload;
  - le helper upload commun applique maintenant une normalisation EXIF sur les JPEG avant traitement d'image.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/global/web/lib/core/lib_core_upload_functions.php`

## PATCH 2026-04-13 — Direct access EC: le token n'est plus cassé par un scan QR mobile
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
- [x] Cause confirmee:
  - le lien temporaire `client_contact_direct_access` etait invalidé au premier hit;
  - certains scanners QR mobiles prechargent ou previsualisent l'URL avant la vraie ouverture navigateur, ce qui rendait ensuite le lien `invalide` a l'auth.
- [x] Correctif livre:
  - la consommation du lien direct EC ne vide plus immediatement `pwd_token` / `pwd_token_date`;
  - le lien reste donc reutilisable pendant sa fenetre de validite au lieu d'etre single-use au premier scan.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`

## PATCH 2026-04-11 — Photos podium session: support des ex aequo avec medias distincts
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependances relues:
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
    - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- [x] Cause confirmee:
  - la lecture et l'ecriture des photos podium dediees reposaient exclusivement sur `rank`;
  - une photo `rank:1` etait donc partagee par toutes les lignes `#1` du podium, meme en cas d'egalite.
- [x] Correctif livre:
  - ajout d'une cle stable de ligne de podium (`photo_row_key`) rattachee au contexte de resultats;
  - lecture prioritaire d'un media dedie `row:<photo_row_key>`;
  - fallback conserve sur `rank:X` pour les photos historiques et les rangs sans photo individualisee;
  - `Bingo Musical` enrichit aussi ses lignes podium avec `id` joueur quand il est disponible, pour stabiliser la cle cote runtime.
- [x] Portee:
  - aucun schema DB nouveau;
  - aucune migration de medias existants requise.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-10 — Détection `dev` élargie dans `global_config`
- [x] Correctif livré dans:
  - `global/web/global_config.php`
  - `global/web/global_config.template.php`
- [x] Cause confirmée:
  - le bootstrap Stripe charge désormais `global_config.php` même pour des flows appelés depuis `pro.dev`;
  - la détection historique ne considérait `dev` que pour `global.dev.cotton-quiz.com`;
  - conséquence: un appel depuis `pro.dev.cotton-quiz.com` chargeait bien `global_config.php`, mais avec `server=prod`.
- [x] Correctif:
  - la détection d'environnement considère désormais tout host `*.dev.cotton-quiz.com` comme `dev`;
  - cela réaligne les clés Stripe runtime avec le domaine appelant `pro.dev`.
- [x] Portée:
  - évite l'usage accidentel des clés live dans des flows Stripe déclenchés depuis `pro.dev`.

## PATCH 2026-04-10 — Bootstrap runtime `global_config.php` depuis le SDK Stripe
- [x] Correctif livré dans:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- [x] Cause confirmée:
  - certains contextes d'exécution Stripe utilisaient `stripe_sdk_functions.php` sans que `$conf` ait été initialisé auparavant;
  - d'autres contextes avaient déjà un `$conf` partiel (`server`, etc.) mais sans buckets Stripe;
  - conséquence: les helpers Stripe ne voyaient pas `stripe_private_api_key` et retombaient systématiquement sur les fallbacks hardcodés.
- [x] Correctif:
  - le SDK Stripe tente maintenant de charger `global_config.php` (puis `global_config.local.php`) si `$conf` n'est pas encore disponible;
  - le bootstrap ne s'arrête plus sur un simple `$conf` non vide; il exige désormais la présence d'au moins un bucket Stripe runtime pour considérer la config comme chargée;
  - un log de bootstrap précise:
    - `loaded=/.../global_config.php`
    - ou `no_runtime_config_found`
- [x] Portée:
  - sécurise les contextes historiques qui incluent directement le SDK sans bootstrap global complet.

## PATCH 2026-04-10 — Debug transitoire source config Stripe (`global_config` vs fallback)
- [x] Instrumentation temporaire ajoutée dans:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- [x] Objectif:
  - confirmer en `dev` que les secrets Stripe sont bien lus depuis `global_config.php`
  - avant suppression définitive des fallbacks hardcodés.
- [x] Détail:
  - `lib_Stripe_getConfigValue(...)` journalise maintenant:
    - `key`
    - `server`
    - `source=global_config|fallback`
  - uniquement au moment où une valeur Stripe est effectivement résolue.
- [x] Statut:
  - patch de diagnostic uniquement;
  - retiré après vérification runtime concluante.

## PATCH 2026-04-10 — Secrets Stripe: lecture via `global_config` avec fallback transitoire
- [x] Correctif livré dans:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
  - `global/web/global_config.template.php`
- [x] Objectif:
  - sortir progressivement les secrets Stripe du code versionné;
  - permettre une première bascule `dev` via `global_config.php` avant rotation des clés.
- [x] Détail:
  - `lib_Stripe_getPublicApiKey()` lit désormais `$conf['stripe_public_api_key'][$conf['server']]` en priorité;
  - `lib_Stripe_getPrivateApiKey()` lit désormais `$conf['stripe_private_api_key'][$conf['server']]` en priorité;
  - `lib_Stripe_getPrivateStripeSignatureKey()` lit désormais `$conf['stripe_webhook_secret'][$conf['server']]` en priorité;
  - les anciens fallbacks hardcodés ont été supprimés après validation runtime en `dev`.
- [x] Template:
  - `global/web/global_config.template.php` documente maintenant:
    - `stripe_public_api_key`
    - `stripe_private_api_key`
    - `stripe_webhook_secret`
- [x] Note:
  - aucun `global_config.php` runtime n'est présent dans ce workspace; la mise à jour des vraies valeurs hors git reste à faire sur les environnements concernés.

## PATCH 2026-04-10 — Portail Stripe affilié TdR prod: mapping prod aligné sur la config existante
- [x] Audit confirme dans:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - le runtime prod ne résolvait aucune configuration pour `network_affiliate_cancel_end_of_period`;
  - le debug a confirmé:
    - `env_id=`
    - `env_legacy=`
    - `server_id=`
    - `server_legacy=`
  - Stripe prod expose pourtant une configuration portail existante:
    - `bpc_1RLnEWLP3aHcgkSEBUxGEXa0`
- [x] Correctif livré:
  - le mapping `prod` référence maintenant:
    - `network` => `bpc_1TKulJLP3aHcgkSEn8CdQlt1`
    - `network_affiliate_cancel_end_of_period` => `bpc_1TKulJLP3aHcgkSEn8CdQlt1`
    - `network_affiliate` => `bpc_1TKh9GLP3aHcgkSEMUKlR85t`
    - `network_affiliate_cancel_immediate` => `bpc_1TKh9GLP3aHcgkSEMUKlR85t`
- [x] Portée:
  - rétablit l'ouverture du portail TdR affilié sur le flow `cancel_end_of_period` avec une configuration prod dédiée, séparée du portail standard;
  - rétablit aussi les flows affiliés `immediate` avec une configuration Stripe prod dédiée.
- [x] Statut:
  - instrumentation de debug retirée après confirmation.

## PATCH 2026-04-10 — Audit TdR délégué: piste `Remises 2026` écartée
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - dependance relue:
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- [x] Constat confirme:
  - les TdR sont volontairement exclus du scope `Remises 2026`;
  - cette exclusion est cohérente avec le contrat métier, car les remises réseau sont gérées séparément;
  - aucune correction fonctionnelle n'a donc été conservée sur ce point.
- [x] Statut:
  - fausse piste documentée puis annulée;
  - le sujet restant à auditer est bien la chaîne TdR/réseau propre, pas le moteur `Remises 2026`.

## PATCH 2026-04-09 — Photos podium session: URL versionnee pour le remplacement
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- [x] Cause confirmee:
  - le remplacement d'une photo podium reecrivait le meme nom de fichier par session/rang;
  - la fiche `pro` pouvait donc relire une URL identique et conserver l'ancienne image via cache navigateur.
- [x] Correctif livre:
  - l'URL resolue des photos podium dediees porte maintenant un suffixe `?v=...`;
  - la version est derivee prioritairement de `date_maj`, puis `date_ajout`, puis `id` media;
  - le fallback de lecture reste inchange quand le mount upload n'est pas visible localement.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

> Invariants V1 a proteger dans `app_ecommerce_functions.php`: aucune auto-creation d'offre support `Abonnement reseau`; aucun write path runtime ne doit fabriquer `En attente` sur simple lecture; aucune propagation de fin support vers les delegations `hors_cadre`; aucun auto-reclassement `hors_cadre -> cadre`; aucune logique de remplacement manuel / upsell / downsell comme verite finale des delegations `hors_cadre`.

## PATCH 2026-04-09 — Historique agenda: helper global aligne sur les filtres `Mes joueurs`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
- [x] Correctif livre:
  - `global` expose maintenant un helper `app_client_joueurs_dashboard_session_is_history_useful(...)` pour qualifier une session passee avec le meme contrat metier que `Mes joueurs`;
  - le helper compose:
    - verification `session reellement terminee`;
    - conservation des sessions papier meme sans participation remontee;
    - exigence d'au moins une participation reelle fiable pour les sessions numeriques.
- [x] Sources de participation reprises:
  - `Cotton Quiz`: `equipes_to_championnats_sessions`, runtime `cotton_quiz_players`, fallback legacy `championnats_resultats`;
  - `Blind Test`: bridge consomme `championnats_sessions_participations_games_connectees.date_consumed IS NOT NULL`, puis runtime `blindtest_players`;
  - `Bingo Musical`: runtime `bingo_players`, puis fallback legacy `jeux_bingo_musical_grids_clients` non demo avec `id_joueur > 0`.
- [x] Portee:
  - l'objectif est d'eviter que l'agenda historique EC montre des sessions numeriques sans valeur metier alors que `Mes joueurs` les ecarte deja de ses syntheses.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-13 — Compat sessions liste/archive: alias `id` expose aussi par `app_sessions_get_liste(...)`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependances relues:
    - `www/web/fo/modules/entites/clients/fr/fo_clients_view.php`
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmee:
  - le helper archive `app_client_joueurs_dashboard_session_is_history_useful(...)` attend une cle `id`;
  - `app_sessions_get_liste(...)` ne remontait ici que `id_championnat_session`, ce qui faisait tomber toutes les lignes a `session_id <= 0` dans certains consumers `www`.
- [x] Correctif livre:
  - `app_sessions_get_liste(...)` expose maintenant aussi `cs.id AS id`, en plus de `id_championnat_session`;
  - les consumers qui reutilisent les helpers archive/metier sur cette liste retrouvent donc un identifiant session compatible sans remapping local.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-09 — Helper centralise des résultats finaux de session et des photos podium pour l'EC
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependances relues:
    - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
    - `quiz/web/server/actions/gameplay.js`
    - `blindtest/web/server/actions/gameplay.js`
    - `bingo.game/ws/bingo_server.js`
    - `games/web/includes/canvas/core/canvas_display.js`
    - `games/web/includes/canvas/php/quiz_adapter_glue.php`
    - `games/web/includes/canvas/php/blindtest_adapter_glue.php`
    - `games/web/includes/canvas/php/bingo_adapter_glue.php`
- [x] Sources de verite relues:
  - `Cotton Quiz` legacy: `championnats_resultats` via `cotton_quiz_get_classement_session(...)`;
  - `Cotton Quiz` runtime: `cotton_quiz_sessions.podium_json` + `cotton_quiz_players`;
  - `Blind Test` runtime: `blindtest_sessions.podium_json` + `blindtest_players`;
  - `Bingo Musical`: `bingo_phase_winners` (+ labels `bingo_players`).
- [x] Regles centralisees:
  - `Cotton Quiz` runtime / `Blind Test`:
    - tri score descendant;
    - tie-break stable par id joueur DB ascendant;
    - rang competition `1, 1, 3, 4...`, aligne sur les WS games;
  - `Bingo Musical`:
    - aucun classement complet numerique n'est reconstruit;
    - les distinctions de phase alimentent le podium;
    - la lecture `bingo_players` fournit la liste historisee des joueurs affichee cote EC, sans filtre limite aux actifs live.
- [x] Fallbacks centralises:
  - session non terminee -> message explicite `pas jouee jusqu'au bout`;
  - session terminee sans joueur -> message explicite `Aucun joueur connecté`;
- [x] Compat schema bingo:
  - la lecture de `bingo_players` ne suppose plus la presence de `updated_at`;
  - l'ordre utilise `updated_at`, sinon `created_at`, sinon `id`.
- [x] Portee:
  - helper de lecture des resultats + helper de lecture/ecriture des photos podium session;
  - aucun schema DB nouveau;
  - objectif: eviter un recalcul specifique `pro` et centraliser la consommation de la verite runtime.
- [x] Compteur `Particip.` aligne:
  - avant session, le compteur EC conserve la logique predictive historique;
  - apres session, `app_session_get_participants(...)` relit prioritairement les tables modernes `*_players`;
  - fallback legacy seulement pour les anciens `Bingo Musical` et `Cotton Quiz` sans runtime exploitable;
  - `Cotton Quiz` garde le libelle `equipes`.
- [x] Durcissements legacy `Cotton Quiz`:
  - sans runtime `players`, le compteur post-session lit d'abord le nombre reel de lignes `championnats_resultats`, puis seulement en secours les equipes rattachees a la session;
  - le classement legacy conserve ses rangs historiques mais affiche maintenant le score quiz de session, pas les points agreges de classement general.
- [x] Photos gagnants:
  - ajout d'un stockage dedie par session archivee et rang de podium pour `Cotton Quiz`, `Blind Test` et `Bingo Musical`;
  - fallback de lecture conserve sur le stockage quiz historique `www/images/cotton-quiz/championnats/resultats`;
  - les helpers attachent maintenant la photo resolue directement au contexte podium renvoye a `pro`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-09 — Remises ABN: baseline DB runtime reelle + cause racine prod documentee
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - dependances relues:
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
    - `pro/web/ec/ec_webhook_stripe_handler.php`
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
    - `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
    - `www/web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php`
    - `www/web/bo/www/modules/ecommerce/remises/bdd_ecommerce_remises.sql`
- [x] Cause racine prod confirmee:
  - la prod a casse apres merge/deploiement `remises` sur un double ecart:
    - migration SQL incomplete par rapport au schema reel attendu au runtime;
    - fichier PRO `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` non mis a jour lors du deploy;
  - le script `bdd_ecommerce_remises.sql` ne couvre pas a lui seul l'etat reel du lot:
    - il n'ajoute pas toute la baseline runtime relue par `global` / `pro`;
    - il ne doit donc plus etre traite comme migration unique suffisante.
- [x] Baseline DB runtime retenue pour le lot `remises`:
  - `ecommerce_offres_to_clients`:
    - snapshot commercial de checkout via `id_remise`, `prix_reference_ht`, `prix_ht`, `remise_nom`, `remise_pourcentage`
    - orchestration Stripe via `stripe_subscription_schedule_id`
    - `id_remise` doit rester nullable (`NULL` = pas de remise snapshottee)
  - `ecommerce_remises`:
    - regle BO canonique `Remises 2026`
    - ciblage metier via `id_typologie`, `id_pipeline_etat`
    - fenetre de validite checkout via `date_debut_commande`, `date_fin_commande`
    - duree metier via `duree_remise_mois`
  - `ecommerce_remises_to_offres`:
    - rattachement de la regle a l'offre catalogue (`id_offre = 12` pour l'ABN standard)
    - pourcentage commercial porte par `remise_pourcentage`
  - `ecommerce_remises_to_clients`:
    - ciblage manuel explicite d'un client a une regle `Remises 2026`
  - `ecommerce_commandes_lignes`:
    - snapshot facture/commande via `id_remise` et `prix_reference_ht`
  - `ecommerce_stripe_write_guards`:
    - idempotence webhook/session pour creation schedule et creation commande
- [x] Liens fonctionnels retenus:
  - BO `Remises 2026`:
    - ecrit la regle dans `ecommerce_remises`
    - ecrit le rattachement offre dans `ecommerce_remises_to_offres`
    - ecrit le ciblage client manuel dans `ecommerce_remises_to_clients`
  - lecture preview checkout:
    - `app_ecommerce_discount_candidates_get_for_client_offer()`
    - `app_ecommerce_discount_resolve_for_checkout()`
  - checkout Stripe standard:
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
    - reset puis snapshot de remise sur `ecommerce_offres_to_clients`
    - injection Stripe via `discounts[coupon]` + metadata de moteur attendu
  - webhook:
    - `pro/web/ec/ec_webhook_stripe_handler.php`
    - creation optionnelle d'un `SubscriptionSchedule` pour les cas mensuels bornes
    - stockage du `schedule_id` sur `ecommerce_offres_to_clients`
  - facture:
    - lecture prioritaire du snapshot commande `ecommerce_commandes_lignes`
    - fallback `offre_client` reserve au secours legacy
- [x] Verification prod relevee pendant l'incident:
  - avant correction, la DB prod pouvait afficher une remise visible dans PRO mais non snapshottee au POST paiement (`id_remise = NULL`, `prix_reference_ht = 0`);
  - apres redeploiement du bon `ec_offres_script.php`, les logs checkout confirment:
    - scope OK
    - winner OK
    - resolution OK
    - `snapshot_saved` avec `id_remise`, `prix_reference_ht` et `prix_ht` remises.

## PATCH 2026-04-08 — E-commerce: la periode en cours d'un ABN annuel ne derive plus d'un ancrage mensuel
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - `app_ecommerce_offre_client_abonnement_periode_get_detail()` reutilisait `app_ecommerce_offre_client_abonnement_periode_en_cours_get_date_debut()` pour toute frequence de paiement;
  - ce helper historique avance toujours l'ancre de periode par pas de `1 mois`;
  - sur un ABN annuel, on obtenait donc un debut de periode mensuel glissant, puis une fin recalculee sur `+1 an -1 jour`.
- [x] Correctif livre:
  - le recalcul de `periode_en_cours` par helper mensuel reste borne aux seuls abonnements mensuels (`id_paiement_frequence = 1`);
  - pour un ABN annuel, l'ancre BDD conservee (`date_facturation_debut` puis `date_debut`) reste la base de lecture tant qu'aucune periode Stripe live exploitable ne la remplace.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Sessions legacy Quiz V1: une date vide reste bien `pending`
- [x] Audit confirme dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
- [x] Cause confirmee:
  - `app_session_edit_state_get()` utilisait la date legacy V1 telle quelle;
  - une session incomplète avec date vide ou `0000-00-00` pouvait donc sortir de `pending` a tort et etre marquee `locked`.
- [x] Correctif livre:
  - le resolver d'etat traite maintenant une date vide / `0000-00-00` / invalide comme `legacy_date_missing`;
  - ces sessions restent `pending` tant qu'aucune vraie date n'est programmee.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-08 — Branding facture PDF: logo commun sorti de `pro`
- [x] Audit confirme dans:
  - `global/web/assets/branding/pdf/`
  - `pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
  - `www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`
- [x] Constat confirme:
  - les PDF facture BO/PRO lisaient encore un logo situe dans `pro/web/ec/images/general/logo/`;
  - ce couplage inter-vhost exposait le BO a des erreurs de lecture de fichier.
- [x] Correctif livre:
  - ajout d'un asset partage `global/web/assets/branding/pdf/cotton-facture-logo.jpg`;
  - BO et PRO pointent maintenant vers cette source commune;
  - l'ancien fichier legacy dans `pro` n'est plus utilise par la facture.
- [x] Verification:
  - presence du fichier `global/web/assets/branding/pdf/cotton-facture-logo.jpg`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php`
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php`

## PATCH 2026-04-08 — E-commerce: TTC d'affichage aligne sur le montant canonique facture
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Constat confirme:
  - plusieurs read paths Cotton affichaient encore un TTC reconstruit depuis un HT deja arrondi;
  - ce chemin pouvait produire un ecart visible avec Stripe sur une meme commande, par exemple `99,90 € HT -25 %`:
    - HT affiche `74,93 €`
    - TTC Cotton legacy `89,92 €`
    - TTC Stripe attendu `89,91 €`;
  - le snapshot commande legacy calculait aussi `prix_unitaire_ttc` depuis `prix_ht`, au lieu de repartir d'un montant canonique unique.
- [x] Correctif livre:
  - ajout d'helpers centraux montant/centimes + resolver d'affichage e-commerce dans `app_ecommerce_functions.php`;
  - le TTC affiche est maintenant resolu depuis un montant canonique unique:
    - montant Stripe reel si deja snapshotte en commande/facture;
    - sinon montant exact issu du tarif de reference et de la remise, avant arrondi HT d'affichage;
  - le HT reste une vue informative derivee;
  - le snapshot commande `ecommerce_commandes_lignes` n'applique plus le chemin `HT arrondi -> TTC`;
  - le checkout Stripe standard/delegue recalcule maintenant son `unit_amount` depuis ce resolver canonique, plus depuis `get_ttc(prix_ht_arrondi)`;
  - les cartes ABN avec remise BO recalculent aussi leur TTC preview depuis la base TTC canonique, plus depuis le HT remisé arrondi.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
  - cas reproduit execute:
    - entree `99.90 HT`, remise `25 %`
    - avant `74.93 HT -> 89.92 TTC`
    - apres `74.93 HT -> 89.91 TTC`

## PATCH 2026-04-08 — E-commerce: l'onglet `Offre` n'affiche la remise que si elle couvre encore la periode courante
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Correctif livre:
  - `global` expose maintenant un helper qui relit le snapshot de remise d'une offre et decide si cette remise couvre encore la periode de facturation en cours;
  - la decision se base sur:
    - l'offre snapshottee (`id_remise`, `remise_pourcentage`, `prix_reference_ht`)
    - la duree de regle metier
    - l'ancre de facturation de l'offre
    - la periode courante relue sur l'offre;
  - si la remise n'est plus active pour la periode courante, l'onglet `Offre` reste silencieux;
  - si elle est encore active, `pro` reutilise le meme recap metier que le post-checkout Stripe.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`

## PATCH 2026-04-08 — Remises signup: token public resilient `code` ou `id_securite`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - le resolver public de remise ne depend plus uniquement du champ `code`;
  - un token de lien peut maintenant etre resolu soit par `ecommerce_remises.code`, soit directement par `ecommerce_remises.id_securite`;
  - cela recolle au pattern historique de token opaque pour les liens signup tout en gardant la compatibilite des anciens codes publics.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Signup PRO: rattachement auto d'une `Remise 2026` transportee par lien
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - un helper global reconnait maintenant une regle `Remises 2026` transportee par le flux historique `id_remise` en session;
  - lors du signup, une regle `Remises 2026` en mode manuel est rattachee au nouveau compte via `ecommerce_remises_to_clients`;
  - si la remise session n'est pas une `Remise 2026`, le fallback legacy `ecommerce_remises_clients` reste inchangé.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Remises ABN: recap checkout explicite selon remise/trial
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livre:
  - ajout d'un helper de wording checkout pour les remises ABN;
  - le helper formule maintenant un recap metier explicite selon:
    - remise limitee sans essai gratuit
    - remise limitee apres essai gratuit
    - remise sans limite
    - cas annuel `< 12 mois` relu comme `premiere echeance annuelle`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-08 — Widget ABN: la duree de remise n'est plus affichee avant Stripe
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Correctif livre:
  - le badge de remise BO sur `Tarifs & commande` n'affiche plus la duree d'application;
  - le pourcentage et le prix barre restent visibles;
  - la duree est laissee au recap Stripe au moment du paiement.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`

## PATCH 2026-04-08 — Stripe customer stale en dev: invalidation auto + recreation dans l'environnement courant
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- [x] Cause confirmee:
  - certains clients de `dev` portent un `asset_stripe_customerId` historise sur un autre environnement Stripe;
  - le checkout standard reutilisait cet id tel quel, ce qui bloquait `Checkout Session` sur `No such customer`.
- [x] Correctif livre:
  - `app_ecommerce_stripe_customer_ensure_for_client(...)` verifie maintenant le `customer` Stripe stocke avant de le reutiliser;
  - si Stripe repond `No such customer`, l'id local est vide puis un nouveau customer est recree dans l'environnement courant;
  - le checkout standard passe maintenant systematiquement par ce helper au lieu de faire confiance aveuglement a `clients.asset_stripe_customerId`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`

## PATCH 2026-04-08 — Remises 2026: duree BO + arbitrage coupon/schedule + exception annuelle
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Correctif livre:
  - la regle BO de remise ne porte plus une duree Stripe implicite fixe `12 mois`;
  - `global` normalise maintenant une `duree_remise_mois` avec:
    - valeur par defaut `12`
    - borne numerique positive
    - `0/null` interprete comme `sans limite`;
  - le resolver checkout et le resolver preview remontent maintenant:
    - `duree_remise_mois`
    - `duree_remise_label`
    - `is_unlimited`
    - `execution_engine`
    - `schedule_supported`
    - `schedule_blocked_reason`
    - `trial_period_days` / `trial_eligible` sur le path checkout;
  - la decision moteur est maintenant centralisee:
    - duree `sans limite` => `coupon`
    - ABN mensuel avec duree limitee => `schedule`
    - ABN annuel avec duree limitee => `coupon`, sans phasage intra-annuel;
  - exception metier annuelle explicitement codee:
    - si la duree est strictement inferieure a `12 mois`, l'annuel est interprete comme `remise sur la premiere echeance annuelle uniquement`;
    - si la duree est `>= 12 mois`, l'annuel reste sur un chemin simple et stable `coupon`;
    - aucun prorata, aucun mixed interval, aucun schedule annuel complexe n'est introduit;
  - les coupons Stripe `% off` sont maintenant assures par pourcentage + duree:
    - `forever` pour `sans limite`
    - `repeating` pour une duree bornee;
  - la persistance documentaire et runtime est preparee pour:
    - `ecommerce_remises.duree_remise_mois`
    - `ecommerce_offres_to_clients.stripe_subscription_schedule_id`;
  - le helper schedule depuis une subscription Stripe existante:
    - cree un `SubscriptionSchedule` via `from_subscription`
    - reconstruit les phases `trial` puis `discounted` puis `full_price` pour les cas mensuels limites
    - garde `end_behavior=release`
    - laisse la subscription Stripe comme reference principale.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`

## PATCH 2026-04-07 — Remises BO V1 sur checkout ABN standard: resolver unique + snapshot commande
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Correctif livre:
  - ajout d'un resolver unique de remises BO pour le checkout ABN standard, borne aux regles generiques `ecommerce_remises` + `ecommerce_remises_to_offres` + ciblage explicite `ecommerce_remises_to_clients`;
  - ajout d'un helper de previsualisation sans `offre_client` persistée pour les cartes `Tarifs & commande`, afin de relire la meme remise gagnante avant creation de ligne panier;
  - le scope ABN V1 est borne au runtime periodique moderne:
    - `id_offre = 12`
    - `id_offre_type = 2`
    - `id_paiement_type = 2`;
  - exclusion explicite des contextes reseau uniquement via les gardes prouves du code runtime:
    - `network_delegated_checkout`
    - `id_client_delegation > 0`
    - `clients.id_client_reseau > 0`
    - `app_ecommerce_reseau_support_offer_matches_detail(...)`;
  - ajout du snapshot commercial V1 sur l'offre client:
    - `id_remise`
    - `prix_reference_ht`
    - `prix_ht` final remisé
    - `remise_nom`
    - `remise_pourcentage`;
  - ajout d'un reset de snapshot avant chaque tentative de checkout standard eligible, pour eviter toute derive locale si une tentative precedente avait deja gelé une remise;
  - ajout d'un helper de coupon Stripe `% off` reutilisable par pourcentage, avec retrieve/create defensif et aucun snapshot si le coupon n'est pas garanti;
  - le helper coupon V1 cible maintenant par defaut une duree Stripe de `12 mois` au lieu de `forever`, avec un identifiant coupon versionne pour ne pas reutiliser les anciens coupons permanents deja emis;
  - durcissement du helper Stripe de `Price` catalogue:
    - un `lookup_key` existant n'est plus reutilise aveuglement;
    - le helper revalide maintenant `unit_amount`, devise et periodicite contre le tarif Cotton attendu;
    - si un `Price` actif porte encore la bonne `lookup_key` mais un mauvais montant, un nouveau `Price` conforme est cree avec transfert de `lookup_key`, afin que le checkout reparte sur la bonne base avant coupon;
  - la ligne de commande copie maintenant le snapshot remisé comme source de verite facture:
    - `id_remise`
    - `prix_reference_ht`
    - `prix_unitaire_ht`
    - `remise_*`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`

## PATCH 2026-04-03 — `Mes joueurs`: sessions bingo historiques reintegrees dans la synthese
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Cause confirmee:
  - la synthese haute `Mes joueurs` relisait, pour `Bingo Musical`, un etat runtime derive de la playlist client;
  - cette playlist pouvant etre reutilisee ou reinitialisee, d'anciennes sessions bingo cessaient alors d'etre vues comme terminees, puis disparaissaient des compteurs de synthese.
- [x] Correctif livre:
  - `app_client_joueurs_dashboard_session_is_reliably_terminated(...)` traite maintenant une session bingo passee comme historique/terminee pour la synthese organisateur;
  - la cle de cache journaliere de synthese est versionnee pour forcer le recalcul apres ce changement.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-04 — Classements agrégés: le podium remplace les `100` points de participation
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livre:
  - les bonus de rang et de phase ne s'ajoutent plus aux `100` points de participation;
  - un `1er / 2e / 3e` rang vaut maintenant `500 / 300 / 200` points au total, et non `600 / 400 / 300`;
  - une simple participation sans podium ni gain de phase reste seule a `100` points.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-04 — Classements historiques: fusion prudente des fallback runtime sur identités DB
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livre:
  - les fallback runtime historiques `runtime:quiz_team:*`, `runtime:blindtest:*` et `runtime:bingo:*` sont maintenant recollés sur une identité DB canonique uniquement si le label normalisé pointe de façon unique vers une identité non-runtime déjà connue dans le contexte du client;
  - la fusion reste donc prudente:
    - priorité absolue aux identités canoniques `team:*` / `ep:*`;
    - aucun merge si plusieurs identités DB différentes partagent le même libellé normalisé;
  - effet attendu: les anciens doublons de casse / accents / ponctuation entre runtime et DB sont absorbés sans fusion agressive des vrais homonymes.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-04 — `Mes classements`: ne retenir que les trimestres réellement acceptés par l'organisateur
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livre:
  - `app_joueur_leaderboards_get_context(...)` ne valide plus un trimestre `courant` ou `precedent` sur la seule base de l'historique joueur lie;
  - chaque trimestre candidat est maintenant revalide via `app_client_joueurs_dashboard_get_context(...)`;
  - si le moteur organisateur retombe sur un autre trimestre, le candidat est rejete et le helper essaie la periode suivante;
  - la section joueur est ignoree si aucun des deux trimestres `courant / precedent` n'est reellement exploitable cote organisateur.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-04 — Dashboard classements: compteurs de sessions + liste complete
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livre:
  - le moteur organisateur `app_client_joueurs_dashboard_get_context(...)` remonte maintenant, par jeu, les compteurs `sessions retenues pour le classement` et `sessions de la saison filtree`;
  - le helper expose aussi la liste complete triee (`players_full` / `teams_full`) en plus du `top 10`, pour permettre un toggle front sans recalcul divergent;
  - le helper joueur `app_joueur_leaderboards_highlight_leaderboard_rows(...)` surligne maintenant aussi les lignes de la liste complete, pas seulement celles du `top 10`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-03 — Signup pro: helper global de recherche de compte existant par `email + nom client`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
  - point d'entree relu:
    - `pro/web/ec/modules/compte/client/ec_client_script.php`
- [x] Cause confirmee:
  - `global` exposait deja un test d'existence de contact par email seul, insuffisant pour distinguer un simple contact existant d'un vrai compte client deja cree sous le meme nom;
  - le signup `pro` n'avait donc aucun helper canonique pour recharger proprement un compte existant sur ce critere metier.
- [x] Correctif livre:
  - ajout de `client_contact_client_find_by_email_and_client_name(...)`;
  - jointure `clients_contacts / clients_contacts_to_clients / clients`;
  - comparaison stricte normalisee `LOWER(TRIM(email))` + `LOWER(TRIM(nom client))`;
  - retour borne a un couple `id_client / id_client_contact` exploitable par le write path `pro`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_script.php` OK

## PATCH 2026-04-02 — Historique joueur EP: sessions reellement terminees seulement
- [x] Objectif:
  - aligner la page `Historique` de l'EP sur la meme notion de session terminee que les classements, tout en conservant une regle simple pour le legacy.
- [x] Correctif livre:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout d'un helper local `app_joueur_historique_session_is_eligible(...)`;
    - regle retenue:
      - `Cotton Quiz` legacy `id_type_produit = 1`: session retenue si `cs.date < CURDATE()`;
      - jeux modernes (`5`, `4`, `3`, `6`): session retenue si `cs.date <= CURDATE()` et `app_session_edit_state_get(...).is_terminated = 1`;
    - filtrage applique dans `app_joueur_participations_reelles_get_liste(...)` avant deduplication des lignes par session;
    - `app_joueur_participations_reelles_latest_date_get(...)` reconsomme maintenant la liste historique effective (sans badges) pour ancrer la fenetre glissante sur la derniere session vraiment affichable.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-02 — Classements saisonniers agreges: sessions runtime terminees seulement
- [x] Objectif:
  - exclure des classements saisonniers agreges `pro` et `play` les sessions encore en cours ou simplement configurees, pour ne garder que les parties reellement terminees.
- [x] Correctif livre:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
    - ajout d'un helper local de garde `app_client_joueurs_dashboard_session_is_reliably_terminated(...)`;
    - le helper reutilise `app_session_edit_state_get(...)` et donc la meme interpretation DB que les `3` jeux runtime:
      - `Bingo Musical`: `phase_courante >= 4`;
      - `Blind Test`: `game_status / phase_courante >= 3`;
      - `Cotton Quiz` moderne: `game_status / phase_courante >= 3`;
    - exception legacy explicite:
      - `Cotton Quiz` legacy `id_type_produit = 1` est retenu si `championnats_sessions.date < CURDATE()` au sens strict;
      - le jour courant est donc exclu, meme pour une session legacy deja passee plus tot dans la journee;
    - filtrage applique a la racine de `app_client_joueurs_dashboard_context_compute(...)`, avant consolidation stats / tops / leaderboards;
    - filtrage applique aussi a `app_client_joueurs_dashboard_period_has_leaderboard_data(...)` pour ne plus ouvrir un trimestre dont aucune session n'est runtime-terminee;
    - consequence assumee: les `3` jeux modernes restent sur une preuve runtime DB, tandis que le legacy garde une heuristique date volontairement plus simple.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-02 — Espace joueur: helper global `Mes classements`
- [x] Objectif:
  - permettre a `play` d'afficher, pour un joueur connecte, les classements organisateur deja existants dans `Mes joueurs`, sans dupliquer leur logique metier.
- [x] Correctif livre:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout d'helpers de mapping `id_type_produit -> game_key`;
    - ajout d'helpers de calcul de trimestre courant / precedent;
    - ajout de `app_joueur_linked_clients_rows_get($id_joueur, $date_start, $date_end)` pour isoler les organisateurs lies au joueur sans passer par l'historique detaille complet;
    - compromis 2026-04-02: ce helper reste volontairement borne aux tables stables EP/bridge et legacy pour identifier les organisateurs lies;
    - les classements affiches ensuite continuent de reposer sur `app_client_joueurs_dashboard_get_context(...)`, donc sur la consolidation organisateur complete moderne / legacy / runtime.
    - ajout de `app_joueur_leaderboards_get_context($id_joueur)`;
    - le helper part maintenant de cette liste legere d'organisateurs lies, plutot que de l'historique reel detaille;
    - il limite les organisateurs a ceux deja lies au joueur;
    - il trie les sections du plus frequente au moins frequente;
    - pour chaque organisateur:
      - trimestre courant si le joueur y a des participations reelles;
      - sinon trimestre precedent;
      - sinon section ignoree;
    - la restitution reconsomme ensuite `app_client_joueurs_dashboard_get_context(...)` pour reutiliser les leaderboards organisateur canoniques;
    - seuls les jeux effectivement joues par le joueur sur le trimestre retenu restent affiches dans chaque section.
    - `app_client_joueurs_dashboard_get_context(...)` remonte maintenant aussi les compteurs podium par ligne (`wins`, `second_places`, `third_places`) a partir des memes attributions de points canoniques que le score agrege;
    - `app_joueur_leaderboards_get_context(...)` somme desormais ces compteurs sur la ligne joueur ou equipe surlignee pour alimenter le recap `Participations / 🏆 / 🥈 / 🥉` sans repartir d'un historique detaille.
    - durcissement des classements agreges organisateur: exclusion des bridges `games_connectees` non consommes (`date_consumed IS NOT NULL`) et des joueurs runtime inactifs (`is_active = 1`) sur `cotton_quiz_players`, `blindtest_players`, `bingo_players`, y compris dans la detection des periodes exploitables et les podiums `bingo_phase_winners`;
    - pour `Cotton Quiz`, une participation d'equipe vaut maintenant aussi participation joueur pour tous les membres lies a cette equipe dans l'historique reel moderne `games_connectees`, afin d'aligner `play` sur la lecture equipe deja retenue cote quiz.
    - rollback 2026-04-02: les relectures runtime `cotton_quiz_players` et `bingo_players` ont ete retirees de l'historique reel joueur pour revenir a un etat stable base sur les sources EP/bridge et legacy.
    - `app_joueur_participations_reelles_get_liste(...)` accepte maintenant un bornage temporel optionnel, `app_joueur_participations_reelles_latest_date_get(...)` expose la derniere activite reelle et `app_joueur_participations_reelles_activity_window_get(...)` factorise la fenetre glissante par defaut;
    - `Historique`, les KPI home et `Mes classements` relisent maintenant par defaut les `12 derniers mois` ancres sur la derniere activite reelle du joueur/equipe, avec extension par paliers de `12 mois` uniquement sur `Historique`.
    - l'instrumentation perf temporaire posee pour diagnostic a ensuite ete retiree; le helper conserve seulement les optimisations de cache request-local et de lecture sans badges.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-01 — Branding: reset session avec cascade conditionnelle sur le branding compte
- [x] Objectif:
  - permettre au reset `games` d'un branding session de supprimer aussi le branding compte par defaut quand il est effectivement identique au design de la session;
  - garantir que les sessions futures deja programmees et encore heritees du branding compte conservent ce design via un snapshot session avant suppression.
- [x] Correctif livre:
  - `global/web/app/modules/general/branding/app_branding_ajax.php`
    - ajout d'un preview `action=delete_preview` pour indiquer au front si le reset session supprimera effectivement un branding compte;
    - ajout d'helpers locaux de comparaison de signature branding (couleurs, police, logo, visuel) avec normalisation d'URL;
    - ajout d'un helper de suppression complete par `id_branding`;
    - ajout d'un helper de gel des sessions futures d'un client quand leur branding effectif est encore `branding_client`;
    - `action=delete` accepte maintenant `cascade_client_branding_if_matching=1`:
      - si la session herite directement du branding compte, ou si son branding session a la meme signature visible que le branding compte;
      - alors les futures sessions du client (`date >= CURDATE()`, hors demo, hors session courante) qui heritent encore de ce branding compte sont dupliquees en branding session;
      - puis le branding compte est supprime;
      - enfin le branding session courant est supprime si present.
- [x] Effet attendu:
  - un reset de design depuis `games` peut retirer le design compte par defaut sans faire perdre ce design aux sessions deja programmees qui l'heritaient encore;
  - les sessions futures non encore figees n'utiliseront plus ce design.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php`

## TODO structurant — Branding par type de jeu pour toutes les portees
- [ ] Objectif:
  - permettre un branding borne au type de jeu courant (`quiz`, `blindtest`, `bingo`) pour toutes les portees `session / evenement / reseau / client`, avec fallback retrocompatible vers le branding global existant.
- [ ] Constat:
  - `general_branding` ne stocke aujourd'hui que `id_type_branding + id_related`;
  - les resolvers `app_general_branding_*` et `app_session_branding_get_detail()` n'acceptent pas `id_type_produit`;
  - un branding compte ne peut donc etre que global a tous les jeux.
- [ ] Piste retenue:
  - ajouter `id_type_produit` nullable dans `general_branding`;
  - ajouter un index composite `(id_type_branding, id_related, id_type_produit)`;
  - resoudre d'abord `scope + type de jeu`, puis fallback sur `scope global`.
- [ ] Points d'attention:
  - conserver les lignes actuelles sans `id_type_produit` comme fallback global;
  - figer uniquement les futures sessions du type de jeu concerne lors d'un reset destructif;
  - relire aussi les ecrans `pro` qui editent ou consomment le branding.
- [ ] Reference:
  - `documentation/notes/branding_par_type_de_jeu.md`

## PATCH 2026-04-01 — Sessions: helper global d'historisation effective agenda
- [x] Objectif:
  - permettre a `pro` de traiter une session runtime `terminée` comme `historique`, sans rester strictement dépendant de la date.
- [x] Correctif livré:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `app_session_edit_state_get()` remonte maintenant aussi `is_terminated` et `runtime_status`;
    - les seuils de fin réutilisent les conventions déjà en place côté `games`:
      - `Cotton Quiz` / `Blind Test`: `game_status >= 3`;
      - `Bingo Musical`: `phase_courante >= 4`;
    - ajout de `app_session_is_archive()` et `app_session_display_chronology_get()` pour fusionner chrono date + état runtime terminé.
    - ajout de `app_client_has_archived_sessions()` pour répondre de facon centralisee si un client a déjà au moins une session archivee non demo et complete.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-31 — Dashboard joueurs organisateur: helper global d'agrégation V1
- [x] Objectif:
  - fournir a `pro` une source unique et lisible pour le dashboard `Joueurs`, sans logique metier dispersée dans la vue.
- [x] Correctif livre:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
    - ajout de `app_client_joueurs_dashboard_get_context(...)`;
    - ajout d'helpers locaux de normalisation, de tri et de détection de colonnes runtime;
    - `Membre depuis` base sur la plus ancienne `date_debut` connue dans `ecommerce_offres_to_clients`, avec fallback defensif `clients.date_ajout` si aucune offre n'est historisée;
    - separation des periodes:
      - synthese calculee sur toute la periode d'activite (`member_since -> today`);
      - tops calcules eux aussi sur toute la periode d'activite;
      - filtre applique seulement aux classements, via `annee + trimestre civil`, avec defaut sur le trimestre en cours;
      - la synthese globale est maintenant mise en cache en session par client/jour, et les changements de filtre ne recalculent plus que le scope classements;
      - la detection des periodes exploitables pour les classements est maintenant alignee sur les vraies sources leaderboard, y compris les sources runtime (`cotton_quiz_players`, `blindtest_players`, `bingo_players`) et le fallback legacy `championnats_resultats` pour `Cotton Quiz`;
    - la synthese par jeu expose aussi `Meilleure session`, soit le nb max de participants connectes observes sur une meme session pour le jeu;
    - les classements par jeu sont maintenant tries sur un score agrege fiable:
      - `500 / 300 / 200` points au total pour les rangs `1 / 2 / 3` de session sur `Cotton Quiz` / `Blind Test`;
      - `500 / 300 / 200` points au total pour les gains de phase `Bingo / Double ligne / Ligne` sur `Bingo Musical`;
      - `100` points seulement pour une participation sans podium ni gain de phase;
      - le nb de participations reste affiche en information annexe;
      - pour `Cotton Quiz` historique pre-runtime, les bonus podium sont aussi relus via `championnats_resultats.position`;
      - le classement `Bingo Musical` conserve les sessions runtime scorables de la periode et n'exclut que les sessions historiques sans gagnants de phase recuperables de facon fiable, avec message explicite seulement dans ce cas;
    - sessions filtrées sur la meme regle que le reporting BO: `championnats_sessions.flag_session_demo=0` et `flag_configuration_complete=1`;
    - le compteur de sessions de la synthese est maintenant nuance comme cote reporting BO:
      - les sessions papier non demo et completes restent comptees meme sans participation remontee;
      - les sessions numeriques exigent au moins une participation fiable (`joueur` ou `equipe`) pour etre comptabilisees;
    - la liste `annee + trimestre` du filtre est maintenant derivee des seules periodes qui alimentent reellement les classements, afin de conserver une selection valide au lieu de revenir au defaut;
    - agrégation des participations fiables par jeu a partir de:
      - `championnats_sessions_participations_games_connectees` pour les joueurs EP connectés;
      - `jeux_bingo_musical_grids_clients` pour les joueurs EP bingo historiquement rattachés a une grille réelle;
      - `blindtest_players` et `bingo_players` pour les joueurs runtime non EP connectés;
      - `cotton_quiz_players` pour les équipes runtime quiz;
      - `equipes_to_championnats_sessions` pour les équipes quiz;
    - le compteur principal agrège les participants connectés fiables `joueurs + équipes`;
    - déduplication stricte:
      - une seule participation par identité et par session;
      - priorité a l'identité EP (`ep:<id_joueur>`);
      - fallback runtime borné au pseudo/username normalisé, scoped par jeu;
      - aucun recours a `championnats_sessions_participations_probables`.
- [x] Limites V1 assumées:
  - le quiz ne produit pas de classement joueur: le bridge et le runtime y sont consolidés au niveau équipe;
  - les non-EP ne sont pas fusionnés entre jeux différents.
- [x] UX data vide:
  - message explicite quand aucune donnee exploitable n'est disponible globalement;
  - message explicite quand la periode choisie ne permet ni tops ni classements fiables.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-03-31 — Sessions quiz: garde `papier -> numérique` réalignée sur `games`
- [x] Objectif:
  - supprimer l'écart de règle entre `pro/global` et `games` sur la compatibilité numérique d'un quiz.
- [x] Correctif livré:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - `app_session_quiz_digital_guard_get()` réutilise désormais le même seuil que `games`:
      - passage `papier -> numérique` autorisé dès qu'une question possède sa réponse et au moins une fausse proposition valide distincte;
      - le helper `global` n'exige plus à tort `2` fausses propositions, ce qui provoquait des refus côté `pro` pour des quiz déjà considérés compatibles dans `games`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-31 — Sessions: helper commun d'état d'édition pour `pro/games`
- [x] Objectif:
  - fournir une règle métier partagée pour déterminer si une session officielle est encore `En attente` et donc encore modifiable.
- [x] Correctif livré:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - ajout de `app_session_edit_state_get()`;
    - ajout d'un alias explicite `app_session_format_change_guard_get()`;
    - suppression du second bloc dupliqué `app_session_participation_probable_*` qui provoquait un fatal `Cannot redeclare ...` et un 500 côté `pro`;
    - règle centralisée:
      - démo: jamais verrouillée;
      - `bingo` / `blindtest` / `cotton quiz v2`: verrou dès que la phase/runtime n'est plus `0`;
      - `cotton quiz v1`: conservation du garde-fou historique basé sur la date.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-30 — Historique joueur EP: badges podium live + gains Bingo
- [x] Objectif:
  - enrichir l'historique réel joueur avec des badges de résultat exploitant le bridge `EP -> games` et les tables temps réel quand elles existent.
- [x] Correctif livré:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout d'helpers `app_joueur_history_*` dédiés au calcul de badges d'historique;
    - enrichissement de `app_joueur_participations_reelles_get_liste()` avec:
      - les identités bridge `game_player_id`, `game_player_key`, `game_slug`;
      - `id_equipe` pour le fallback `quiz_legacy`;
      - un tableau `history_badges` prêt pour l'affichage EP;
    - logique de badges appliquée:
      - `quiz` / `blindtest` live: podium limité au top 3 via les tables temps réel joueurs;
      - `quiz_legacy`: fallback sur `championnats_resultats` au niveau équipe;
      - `bingo`: badges par phases gagnées à partir de `bingo_phase_winners`, avec compat `player_id_key` si la colonne existe.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-30 — Routing EP/games: fallback hors session ouverte
- [x] Objectif:
  - éviter qu'un parcours `games_account_join=1` reboucle vers `games` quand la session n'est pas encore ouverte ou déjà expirée.
- [x] Correctif livré:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout d'un helper de lecture d'état temporel de session pour le routing `games_account_join`;
    - règle explicite de fenêtre d'ouverture:
      - `jour J` = session ouverte;
      - `lendemain de session` = encore ouverte strictement avant `12:00`;
      - sinon = session expirée;
    - session future non ouverte: fallback vers le signalement de participation EP;
    - session expirée/non ouverte: fallback vers l'agenda EP;
    - session ouverte: maintien du pont direct vers `games`.
- [x] Note d'interface:
  - le bypass du gating WS en session papier ne vit pas dans `global`, mais cette règle de routing temporel est bien celle que relisent ensuite `play` et `games`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Equipes joueur: socle d'invitation email V1 pour EP
- [x] Objectif:
  - réutiliser le socle joueur/token existant pour permettre à `play` d'inviter un joueur par email dans une équipe, avec un template transactionnel dédié.
- [x] Correctif livré:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout de `app_joueur_invitation_token_generer()`;
    - ajout de `app_equipe_joueur_invitation_envoyer()`;
    - la fonction valide l'email, borne l'équipe à `5` joueurs max, empêche les doublons dans l'équipe, crée le joueur si besoin, l'ajoute à l'équipe, puis envoie l'email transactionnel;
    - pour un joueur déjà existant, le CTA mail renvoie vers `signin`;
    - pour un nouveau joueur, la fonction pose `pwd_token` + `flag_invitation=1` et renvoie vers `signin/reset/{token}`.
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`
    - ajout du template provisoire `ALL_ALL_PLAYER_TEAM_INVITATION`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`

## PATCH 2026-03-27 — Espace joueur: lecture unifiée de l'historique réel
- [x] Objectif:
  - fournir à `play` une source de lecture unique pour l'historique réel joueur, sans réutiliser les participations probables et avec compat legacy Quiz/Bingo.
- [x] Correctif livré:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - ajout de `app_joueur_participations_reelles_get_liste()`;
    - ajout de `app_joueur_participations_reelles_get_stats()`;
    - source moderne prioritaire: `championnats_sessions_participations_games_connectees`;
    - sources legacy de compat:
      - `equipes_to_championnats_sessions` pour Quiz;
      - `jeux_bingo_musical_grids_clients` pour Bingo;
    - dédoublonnage par session et exclusion explicite des participations probables;
    - calcul des marqueurs home `Top organisateur` et `Top jeu` à partir des fréquences observées dans l'historique réel, avec exposition des ids nécessaires aux filtres agenda `play` (`top_organisateur_id`, `top_game_id_type_produit`).
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — New_EJ: `global` recentre sur le bridge EP
- [x] Objectif:
  - conserver dans `new_ej` uniquement le delta `EP -> games`, sans embarquer des changements de logique sur les helpers historiques joueur/session;
- [x] Correctif livre:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
    - conservation des helpers `app_joueur_games_bridge_*` et de `games_account_join`;
    - retour a `develop` de `app_joueur_sessions_inscriptions_get_liste()` et `app_joueur_session_inscription_get_detail()`;
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
    - retour au code `develop` pour `app_session_games_play_get_link()` et `app_jeu_get_detail()`;
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-26 — Sessions: `app_jeu_get_detail()` ne lit plus `quiz_detail` hors contrat
- [x] Audit confirmé dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `pro/logs/error_log`
- [x] Correctif livré:
  - initialisation défensive des champs communs `id_format`, `format`, `id_origine`, `id_securite_jeu`;
  - initialisation explicite de `quiz_detail` avant le switch;
  - branche `id_type_produit = 5` rendue tolérante quand `quizs` est absent ou incomplet.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-26 — Sessions: pont EP -> games pour les joueurs connectés
- [x] Audit confirmé dans:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `documentation/canon/data/schema/DDL.sql`
  - `documentation/canon/data/schema/MAP.md`
- [x] Correctif livré:
  - ajout des helpers `app_joueur_games_bridge_*` pour préparer un retour court vers `games`;
  - `app_joueur_session_inscription_get_link()` accepte maintenant un contexte moderne `games_account_join`;
  - ajout de la nouvelle table `championnats_sessions_participations_games_connectees`;
  - ajout du SQL d'import phpMyAdmin `documentation/championnats_sessions_participations_games_connectees_phpmyadmin.sql`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-26 — Sessions: nouveau support dédié de participations probables pour `play`
- [x] Audit confirmé dans:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `documentation/canon/data/schema/DDL.sql`
  - `documentation/canon/data/schema/MAP.md`
- [x] Correctif livré:
  - ajout d'helpers `app_session_participation_probable_*` sur le domaine sessions;
  - les reads joueur `app_joueur_session_inscription_get_detail()` et `app_joueur_sessions_inscriptions_get_liste()` s'appuient maintenant sur `championnats_sessions_participations_probables`;
  - `app_joueur_session_inscription_get_link()` reste borne au parcours historique `play`, hors exception explicite du flux moderne `games_account_join=1`;
  - ajout du SQL d'import phpMyAdmin `documentation/championnats_sessions_participations_probables_phpmyadmin.sql`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## Invariant — synchro hors workspace avant patch évolutif
- Pour toute évolution touchant `global/ai_studio/**`, `global/web/**`, `website/**` ou des scripts/workflows transverses, commencer par consulter le journal global AI Studio public afin d’identifier les éléments potentiellement plus à jour sur serveur que dans le workspace local.
- Inclure une demande de recharge depuis les serveurs pour les scripts/dossiers signalés avant audit ou patch : `https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb`
- Ce journal sert de contrôle de synchro et de détection d’écarts ; il ne remplace pas la preuve finale par le code, les fichiers réellement rechargés et la documentation canon.

## PATCH 2026-03-26 — E-commerce: confirmation de commande routee vers AI Studio transactionnel
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_functions.php`
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_webhook.php`
- [x] Constat confirme:
  - `app_ecommerce_commande_ajouter()` envoyait encore le mail client de confirmation via `lib_Brevo_sendMailFromTemplate(...)` et le template legacy `287`;
  - le bloc etait deja borne metierement a la premiere facture de l'offre et a un sous-ensemble explicite de types d'offre / paiement;
  - le catalogue transactionnel AI Studio expose maintenant `ALL_ALL_INVOICE_MONTHLY`, dont le contenu correspond a une confirmation de commande avec facture disponible;
  - le webhook AI Studio exige `CONTACT_EMAIL` et gere le destinataire reel cote n8n/Brevo, avec BCC de monitoring.
- [x] Correctif livre:
  - l'ancien bloc Brevo direct est conserve en commentaire pour validation transitoire;
  - l'envoi effectif passe maintenant par `ai_studio_email_transactional_send('ALL', 'ALL', 'INVOICE_MONTHLY', ...)`;
  - les variables transmises sont alignees sur le template AI Studio: `CLIENT_NOM`, `CONTACT_PRENOM`, `CONTACT_NOM`, `CONTACT_EMAIL`, `COMMANDE_DATE`, `COMMANDE_OFFRE_NOM`, `COMMANDE_TOTAL_TTC`;
  - les gardes metier historiques du bloc restent inchangees.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-25 — E-commerce Stripe: socle d'idempotence persistante pour les writes commande/facture
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Constat confirme:
  - le socle `global` savait deja relire un `stripe_invoice_id` dans `commentaire_facture`, mais pas reserver un write avant creation de commande;
  - aucun helper natif n'existait pour dedoublonner les PAK sur `payment_intent.id` ni les retries bruts sur `event.id`;
  - la fenetre `creation commande -> rattachement token Stripe` restait ouverte aux executions concurrentes.
- [x] Correctif livre:
  - ajout d'une table `ecommerce_stripe_write_guards` creee a la demande, avec unicite par `scope_key + object_id`;
  - ajout d'helpers `claim/complete` + verrou `GET_LOCK` pour piloter proprement les retries webhook sur `invoice.id`, `payment_intent.id` et `event.id`;
  - ajout d'un token `stripe_payment_intent_id` et d'un point d'injection `commentaire_facture` directement dans `app_ecommerce_commande_ajouter(...)`;
  - conservation explicite du point d'extension futur pour `customer.subscription.updated`, sans embarquer ce correctif dans ce lot.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK

## PATCH 2026-03-25 — E-commerce: compatibilite read path contact via `app_client_contact_get_detail()`
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - le flux `app_ecommerce_commande_ajouter()` appelait `app_client_contact_get_detail(...)`;
  - seule la fonction legacy `client_contact_get_detail(...)` etait definie, ce qui provoquait un fatal PHP dans le webhook Stripe au moment de finaliser une commande;
  - la quasi-totalite des call sites historiques `pro` et `global` restent encore en `client_contact_get_detail(...)`, donc un renommage brutal aurait ete plus risqué qu'un alias de compatibilite.
- [x] Correctif livre:
  - ajout d'un alias applicatif `app_client_contact_get_detail(...)` qui delegue au helper legacy existant;
  - harmonisation du second call site e-commerce `global` pour reutiliser ce nommage `app_*`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-24 — E-commerce/Brevo: le socle webhook reste silencieux et tolerant aux moves de liste deja faits
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/assets/sendinblue/api/sendinblue_api_functions.php`
- [x] Constat confirme:
  - le socle commandes ne portait encore aucune ancre native pour relier une commande Cotton a un `invoice.id` Stripe deja traite;
  - les helpers Brevo `lib_*` faisaient encore des `print_r` sur succes et des `echo` en erreur, y compris pour les moves de liste `160 -> 161`;
  - ces sorties parasites pouvaient polluer des flux serveur comme le webhook Stripe, et les erreurs metier `already removed/already in list` n'etaient pas traitees comme des no-op idempotents.
- [x] Correctif livre:
  - ajout d'helpers commandes pour attacher et relire un token `stripe_invoice_id` via `commentaire_facture`;
  - les helpers Brevo `lib_Brevo_sendMailFromTemplate`, `lib_Brevo_createUser`, `lib_Brevo_updateUser` et `lib_Brevo_moveListUser` journalisent maintenant les erreurs sans produire de sortie HTTP;
  - `lib_Brevo_moveListUser` accepte maintenant les cas `already removed` / `already in list` comme etats idempotents.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/assets/sendinblue/api/sendinblue_api_functions.php` OK

## PATCH 2026-03-24 — Branding: le pipeline upload visuel perso respecte la qualite demandee et evite l'upscale
- [x] Audit confirme dans:
  - `global/web/lib/core/lib_core_upload_functions.php`
  - `global/web/app/modules/general/branding/app_branding_ajax.php`
  - `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Constat confirme:
  - le core image recadrait encore les JPEG avec une qualite forcee a `80`, meme quand une autre qualite etait demandee;
  - le flux branding `games` demandait une cible fixe trop basse puis pouvait encore upscale artificiellement la sortie;
  - le symptome en jeu etait coherent avec un double probleme `compression finale trop forte + cible figee`.
- [x] Correctif livre:
  - `upload_image_recadrer()` respecte maintenant la qualite JPEG demandee et derive correctement la compression PNG;
  - l'endpoint branding `games` demande maintenant une qualite `100` et une cible visuel max `1600x640`;
  - le helper branding adapte la cible effective du `visuel` a la taille source pour eviter de grossir artificiellement une image plus petite.
  - l'endpoint branding retourne maintenant aussi un message d'erreur explicite pour `logo` / `visuel` quand PHP signale un upload trop lourd, partiel ou bloque, ainsi que pour un POST depassant `post_max_size`.
  - le delete branding borne maintenant aussi explicitement la suppression a la portee demandee (`session` ou `client`) quand `id_type_branding` est fourni, au lieu de supprimer la couche effective resolue.
  - si aucun branding n'existe sur cette portee explicite, le delete repond maintenant en no-op reussi au lieu de retomber sur la resolution effective et de pouvoir toucher une couche amont (ex. reseau TdR).
- [x] Effet attendu:
  - le media final branding conserve mieux les aplats et les textes fins;
  - une source `1280x720` ne ressort plus en `1200x480` fige puis potentiellement molle, mais dans une cible adaptee type `1280x512`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/lib/core/lib_core_upload_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_functions.php` OK

## PATCH 2026-03-19 — Reseau TdR: cloture BO support = fermeture reelle des incluses `cadre`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Constat confirme:
  - le write path BO `modifier -> id_etat=4` passait bien par `app_ecommerce_reseau_support_offer_force_close_from_bo()`;
  - ce helper ne fermait que les incluses encore presentes dans `ecommerce_reseau_contrats_affilies` en `activation_state=active`;
  - une incluse `cadre` encore liee au support par `reseau_id_offre_client_support_source` mais deja desynchronisee de la table d'activations pouvait donc rester active cote SI;
  - ces lignes parasites pouvaient ensuite continuer a polluer la lecture PRO et l'historique TdR.
- [x] Correctif livre:
  - la cloture BO collecte maintenant aussi toutes les delegations actives encore liees au support via `reseau_id_offre_client_support_source`;
  - chaque incluse `cadre` ciblee est fermee en `Terminee`, puis son pipeline affilié est resynchronise;
  - les surfaces TdR `Offres` peuvent maintenant filtrer explicitement ces incluses `cadre` a partir de leur marqueur canonique `reseau_id_offre_client_support_source` et, en secours, du mode d'activation persiste.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-19 — BO support reseau: le champ `Fin` redevient editable
- [x] Audit confirme dans:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php`
- [x] Constat confirme:
  - le formulaire BO custom de l'`Abonnement reseau` cachait `date_fin` dans un `input hidden`, alors meme que la vue BO masquait aussi cette valeur;
  - cela empechait tout test BO cible sur la date de fin locale d'un support reseau sans passage SQL.
- [x] Correctif livre:
  - le champ `Fin` est maintenant affiche et modifiable dans le formulaire custom BO de l'`Abonnement reseau`;
  - la vue BO de ce support affiche aussi explicitement la date de fin courante.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php` OK

## PATCH 2026-03-19 — BO support reseau: la case `Offert` pilote aussi le rendu front
- [x] Audit confirme dans:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Constat confirme:
  - le formulaire BO custom de l'`Abonnement reseau` cachait `flag_offert`;
  - le write path BO forcait encore `flag_offert = 0` a la creation;
  - le front affichait `OFFERT !` uniquement pour les offres non support reseau, meme si `flag_offert = 1`.
- [x] Correctif livre:
  - la case `Offert` est maintenant visible dans le formulaire BO custom support reseau;
  - la vue BO affiche aussi l'etat `Offert`;
  - le create support BO respecte desormais la valeur postee;
  - le front affiche `OFFERT !` des que `flag_offert = 1`, y compris pour l'`Abonnement reseau`;
  - le controle BO `Offert` utilise maintenant un rendu simple aligne sur le bloc, sans decalage lateral ni zone non cliquable;
  - le formulaire n'embarque plus de champ cache concurrent `flag_offert`, et le script BO reapplique defensivement `date_fin` / `flag_offert` apres le sync support pour eviter toute perte au save.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_module_form_custom.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_module_view_top.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-19 — BO support reseau: `date_fin` et `flag_offert` persistent enfin au save
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Constat confirme:
  - apres `module_modifier`, le write path BO support relancait `app_ecommerce_reseau_abonnement_bo_sync_offer_client()`;
  - ce helper republiait prix/periode/jauge/quota, mais ne reinjectait ni `date_fin` ni `flag_offert`;
  - consequence: une `date_fin` saisie manuellement pouvait etre perdue dans le recalcul support, et le flag `Offert` ne restait pas fiable entre vue et modification.
- [x] Correctif livre:
  - le sync BO support republie maintenant aussi `date_fin` et `flag_offert`;
  - le script BO normalise ces deux champs avant `module_modifier` et les transmet aussi au helper de sync.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-19 — BO support reseau: activation forcee avec fin planifiee preservee
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Constat confirme:
  - lors du premier save `En attente -> Active`, `app_ecommerce_reseau_support_offer_activate_from_external_write_path()` reinitialisait volontairement `date_fin = '0000-00-00'`;
  - le BO devait pourtant pouvoir forcer une activation sans paiement tout en gardant une fin planifiee pour les tests et les clotures locales.
- [x] Correctif livre:
  - apres la reactivation support depuis le BO, le script reapplique explicitement `id_etat = 3`, `date_fin` et `flag_offert`;
  - le premier save `Active` peut donc maintenant conserver une fin planifiee au lieu de revenir a une activation ouverte sans date.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-19 — BO support reseau: la creation peut vraiment partir en `Active`
- [x] Audit confirme dans:
  - `www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php`
- [x] Constat confirme:
  - en mode `ajouter`, le write path support forcait encore `$_POST['id_etat'] = 2`;
  - apres insertion, il reappliquait a nouveau `id_etat = 2`, ce qui expliquait un affichage final `pending_payment` meme quand le BO demandait explicitement `Active`.
- [x] Correctif livre:
  - la creation support respecte maintenant `id_etat = 3` quand le BO le demande explicitement;
  - apres insertion, le flux BO active aussi le support via le write path dedie puis reapplique `id_etat = 3`, `date_fin` et `flag_offert`.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/offres_clients/bo_offres_clients_script.php` OK

## PATCH 2026-03-19 — Cron support reseau: la fin effective clot aussi les incluses `cadre`
- [x] Audit confirme dans:
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - le cron `ABN SANS engagement` passait bien l'offre support reseau en `Terminee`;
  - mais il n'appelait ensuite que `app_ecommerce_reseau_support_offer_transition_finalize()`, qui archivait le runtime contrat sans fermer les offres deleguees incluses `cadre`;
  - le BO manuel `Terminee`, lui, passait par `app_ecommerce_reseau_support_offer_force_close_from_bo()` et fermait correctement ces incluses.
- [x] Correctif livre:
  - `app_ecommerce_reseau_support_offer_transition_finalize()` ferme maintenant aussi les delegations `cadre` actives liees au support courant avant archivage du contrat runtime;
  - la fermeture preserve une `date_fin` deja planifiee si elle existe, sinon pose `CURDATE()`;
  - chaque affilié impacte est resynchronise apres fermeture effective.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-19 — Stripe support reseau: la fin de periode ecrit a nouveau `date_fin`
- [x] Audit confirme dans:
  - `pro/web/ec/ec_webhook_stripe_handler.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - le support reseau devait etre retrouve via `asset_stripe_productId` puis recevoir `date_fin = current_period_end` sur `customer.subscription.updated`;
  - mais un premier `case customer.subscription.updated` consommait deja l'evenement pour la seule sync deleguee, rendant unreachable le write path support declare plus bas;
  - `app_ecommerce_reseau_facturation_refresh()` n'effacait pas ensuite cette date: le blocage etait bien en amont, dans le webhook non pris en compte.
- [x] Correctif livre:
  - le traitement principal `customer.subscription.updated/customer.subscription.deleted` prend maintenant aussi en charge le support reseau;
  - la fin de periode Stripe support renseigne de nouveau `date_fin`, relance le refresh local et planifie les incluses liees;
  - le doublon mort du webhook est retire pour eviter toute regression.
- [x] Verification:
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK

## PATCH 2026-03-19 — Reseau TdR: suppression du reclassement implicite au chargement BO
- [x] Audit confirme dans:
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - la page BO `reseau_contrats` appelait `app_ecommerce_reseau_contrat_reclassify_delegations()` des l'ouverture de l'ecran;
  - cette chaine pouvait ecrire dans `ecommerce_reseau_contrats_affilies`, `ecommerce_offres_to_clients`, `clients` et `clients_logs` via les helpers de sync/reclassement/facturation/pipeline;
  - aucune preuve explicite ouverte ne justifie un write cache dans une simple lecture BO.
- [x] Correctif livre:
  - suppression de l'appel automatique au chargement de `bo_reseau_contrats_list.php`;
  - les write paths explicites BO restent inchanges, dont l'action manuelle `sync_legacy` si un raccord historique doit encore etre force volontairement.
- [x] Verification:
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/reseau_contrats/bo_reseau_contrats_list.php` OK

## PATCH 2026-03-19 — Reseau TdR: neutralisation definitive du remplacement delegue `hors_cadre`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - les helpers legacy `app_ecommerce_reseau_delegated_checkout_context_start_replace()`, `app_ecommerce_reseau_delegated_offer_replace()`, la planification differee et son executeur cron restaient encore presents et atteignables;
  - ce socle contredisait l'invariant V1 `hors_cadre = gestion/résiliation explicite uniquement`, meme si l'UI principale n'exposait plus le bouton.
- [x] Correctif livre:
  - les helpers de remplacement immediat / differe renvoient maintenant `replacement_disabled_v1`;
  - l'execution cron d'un plan legacy le marque en erreur metier `replacement_disabled_v1` au lieu de rebasculer une offre;
  - l'invariant V1 est donc porte par le serveur, pas seulement par le retrait de l'UI.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-17 — Reseau TdR: le hors cadre delegue ne depend plus d'un contrat reseau automatique
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - le contexte d'action affilié et les flows `hors_cadre` explicites continuaient de bloquer sur `network_contract_missing`;
  - l'attachement post-paiement tentait encore d'ecrire une activation reseau meme quand aucune ligne `ecommerce_reseau_contrats` n'existait pour la TdR;
  - cette hypothese n'est plus valide depuis le passage a une offre abonnement reseau facultative.
- [x] Correctif livre:
  - `app_ecommerce_reseau_affiliate_action_context_get()` accepte maintenant un mode `allow_missing_contract` pour les flows `hors_cadre`;
  - le checkout delegue `hors cadre` et l'analyse de contexte d'une offre deleguee payee passent maintenant avec `id_contrat_reseau = 0`;
  - l'attachement post-paiement et l'activation explicite `hors_cadre` n'ecrivent plus d'activation reseau quand aucun contrat n'existe;
  - les flows `included/cadre` gardent leur verrou historique sur un support reseau actif et un contrat resolu.
- [x] Invariant V1 fige:
  - l'absence de contrat reseau ne doit plus servir de pretexte documentaire pour reintroduire un parcours de remplacement `hors_cadre`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-17 — Contenu reseau V1: durcissement schema/write/read sans migration SQL dédiée
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirme:
  - la persistance V1 reste portée par `ecommerce_reseau_content_shares` creee a la demande par `app_ecommerce_reseau_content_shares_schema_ensure()`;
  - l'unicité métier est deja visée dans ce helper par `ux_reseau_content_share (id_client_siege, game, content_type, source_id)`;
  - les writes etaient deja idempotents (`INSERT ... ON DUPLICATE KEY UPDATE` pour partager, `UPDATE` borne pour retirer), mais les lectures continuaient de remonter des lignes `active` dont la source pouvait etre inactive ou supprimée.
- [x] Correctif livre:
  - ajout d'une verification source centralisee par jeu pour ne considerer exploitable qu'un contenu encore present, encore actif (`id_etat=2` ou `online=1`) et valide quand applicable;
  - `app_ecommerce_reseau_content_share_set()` refuse maintenant le partage d'une source non exploitable;
  - `app_ecommerce_reseau_content_share_is_active()`, `app_ecommerce_reseau_content_share_ids_get()` et `app_ecommerce_reseau_content_share_counts_get()` ignorent maintenant ces sources cassées en lecture;
  - decision retenue pour ce lot: maintien du lazy-init avec assurance de schema existante, sans extraction immediate vers une migration SQL dediee.
- [x] Risques / dette documentes:
  - contrainte d'unicité prouvée dans le code via `app_ecommerce_reseau_content_shares_schema_ensure()`, mais non reverifiee sur une base locale accessible depuis ce poste;
  - si l'industrialisation du schema hors runtime devient prioritaire, l'extraction doit rester strictement bornee a `ecommerce_reseau_content_shares`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Contenu reseau V1: socle de partage transverse pour la bibliothèque PRO
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Constat confirme:
  - l'affiliation reseau canonique passe deja par `clients.id_client_reseau`;
  - les contrats/activations reseau existent deja dans `ecommerce_reseau_*`;
  - aucune persistance `contenu partagé au réseau` n'existe encore;
  - le pattern le plus proche reste une projection separee du modele source, a l'image de `community_items`.
- [x] Correctif livre:
  - ajout d'un socle `ecommerce_reseau_content_shares` cree a la demande, borne au besoin `partagé au réseau`;
  - la lecture/ecriture reste portee par des helpers `global` dedies, sans changer l'origine du contenu ni toucher au runtime `games`;
  - la lecture affilié reutilise simplement `id_client_reseau` pour retrouver les contenus partages par la TdR.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Branding reseau: ajouter une validite optionnelle et ignorer les couches expirees
- [x] Audit confirme dans:
  - `global/web/app/modules/general/branding/app_branding_functions.php`
  - `global/web/app/modules/general/branding/app_branding_ajax.php`
  - `pro/web/ec/modules/general/branding/ec_branding_script.php`
- [x] Cause / besoin confirme:
  - la hiérarchie type `1/2/3/4` etait bien en place, mais aucune validite temporelle n'etait documentee ni resolue pour la couche reseau type `3`;
  - la page PRO branding existante n'avait donc aucun moyen canonique d'annoncer `Actif jusqu'au ...` ou `Expire`.
- [x] Correctif livre:
  - ajout de la colonne SQL `general_branding.valable_jusqu_au` via migration dediee;
  - `app_general_branding_get_complete()` hydrate maintenant `validite.valable_jusqu_au` et `validite.is_expired`;
  - `app_general_branding_get_detail()` ignore desormais un branding reseau type `3` quand `valable_jusqu_au` est depasse en fin de journee;
  - les helpers d'ajout/modification acceptent maintenant `valable_jusqu_au`;
  - un helper de lookup direct stabilise aussi la lecture du dernier branding type/id_related.
- [x] Effet attendu:
  - un branding reseau actif et non expire continue de participer a la resolution type `3`;
  - au-dela de la fin de la journee choisie, la couche reseau est ignoree et le fallback reprend automatiquement.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/general/branding/ec_branding_script.php` OK
- [x] Correctif media complementaire:
  - le logo reseau PRO ne passe plus par un recadrage hauteur force;
  - l'upload branding reseau conserve maintenant le ratio source et evite la coupe laterale dans le header games.
- [x] Correctif upload final aligne games:
  - le helper branding normalise maintenant les fichiers uploadés avec la meme logique MIME/extension que le flux games/ajax avant l'appel au core upload;
  - le core upload image supporte aussi `webp` et ne reference plus une variable `mime` non definie pendant le redimensionnement;
  - le helper branding garde finalement un comportement de save proche de l'implementation historique: purge puis upload, sans restauration automatique d'un ancien media pendant le save.
- [x] Instrumentation upload:
  - ajout de logs `[branding:upload]` au niveau du helper global de branding pour voir la normalisation du media, le path cible et les fichiers reels avant/apres ecriture.
- [x] Diagnostic final save branding:
  - les logs prouvent que le POST branding reecrit bien le nouveau `logo.png` au bon emplacement apres unlink;
  - le symptome restant venait donc de la relecture d'une URL d'asset stable, pas d'un echec d'upload;
  - `app_general_branding_get_complete()` retourne maintenant des URLs versionnees sur `filemtime` pour `logo` et `visuel`, afin de casser le cache apres save.

## PATCH 2026-03-16 — Facturation reseau: exposer l'affilie facture pour les offres deleguees
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/compte/factures/ec_factures_list.php`
  - `www/web/bo/www/modules/ecommerce/factures/bo_factures_list.php`
- [x] Besoin confirme:
  - une TdR ne differencie pas facilement plusieurs factures d'offres deleguees `hors cadre` quand elles ont le meme montant.
- [x] Correctif livre:
  - ajout d'un helper global qui resolve le nom de l'affilie a partir de l'offre facturee si `id_client_delegation > 0`;
  - affichage de ce libelle (`Affilié : <nom>`) dans les listes de factures PRO et BO;
  - injection du meme libelle dans le texte de ligne produit au moment de creer la commande, pour les nouvelles factures PDF;
  - enrichissement aussi des vues PDF BO/PRO au rendu, pour couvrir les factures deja generees.
- [x] Effet attendu:
  - les factures TdR d'offres deleguees affichent `Affilié : <nom>` directement dans la liste;
  - les factures PDF reprennent aussi ce libelle sous le nom du produit, y compris sur des factures deja existantes.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_list.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/factures/ec_factures_view_pdf.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_list.php` OK
  - `php -l /home/romain/Cotton/www/web/bo/www/modules/ecommerce/factures/bo_factures_view_pdf.php` OK

## PATCH 2026-03-16 — Reseau TdR: prioriser la delegation liee au support courant pour un affilié sans offre active
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - les resolutions runtime/sync legacy privilegiaient encore une delegation active legacy "la plus recente" pour un affilié, meme lorsqu'une autre ligne active etait explicitement rattachee au support reseau courant;
  - apres des historiques BO charges, une activation incluse valide pouvait donc etre relue puis resynchronisee en `hors_cadre`.
- [x] Correctif livre:
  - la resolution canonique des delegations actives choisit maintenant d'abord la ligne active liee au support courant via `reseau_id_offre_client_support_source`;
  - a defaut seulement, elle retombe sur la delegation active la plus recente.
- [x] Portee:
  - `app_ecommerce_reseau_delegations_actives_resolues_get_liste()`
  - `app_ecommerce_reseau_contrat_sync_legacy_delegations()`
  - `app_ecommerce_reseau_affiliate_active_delegated_offer_get_id()`
- [x] Effet attendu:
  - si la TdR a un abonnement reseau actif, qu'il reste du quota et que l'affilie n'a aucune offre active, l'activation manuelle doit marcher quel que soit l'historique des anciennes delegations.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Reseau TdR: conserver `cadre` a l'ecriture pour les activations incluses
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - `app_ecommerce_reseau_activation_write()` calculait `mode_facturation_effective()` depuis un detail contrat incomplet;
  - une activation demandee en `cadre` pouvait donc etre persistee en `hors_cadre`, surtout visible apres suppression de l'ancien auto-reclassement.
- [x] Correctif livre:
  - le helper recharge maintenant le contrat runtime complet via `app_ecommerce_reseau_contrat_get_by_client_siege()` avant de calculer le mode effectif.
- [x] Durcissement complementaire:
  - `app_ecommerce_reseau_activation_mode_facturation_effective()` transmet maintenant aussi `id_client_siege` a `app_ecommerce_reseau_contrat_get_state()`, pour reutiliser l'offre support runtime si la ligne contrat n'a pas encore son `id_offre_client_contrat` a jour.
- [x] Durcissement lecture/runtime:
  - la couverture reseau et la sync legacy deduisent maintenant aussi `cadre` depuis `reseau_id_offre_client_support_source` quand l'offre deleguee est rattachee au support reseau courant.
- [x] Effet attendu:
  - `signup_affiliation` et `Activer via l'abonnement` recreent bien une offre incluse `cadre` quand le support reseau est actif et qu'une place reste disponible.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Reseau TdR: ne plus auto-reclasser les offres deleguees `hors cadre` vers `cadre`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - la couverture reseau absorbait encore implicitement des offres deleguees actives `hors cadre` dans le quota `cadre` des qu'un abonnement reseau etait actif;
  - le reclassement runtime pouvait donc retoucher ces offres alors que la nouvelle regle metier demande de ne plus y toucher automatiquement.
- [x] Correctif livre:
  - `mode_reclassement` reflete maintenant uniquement le mode d'activation reel (`cadre`/`hors_cadre`) deja porte par l'activation reseau;
  - le moteur de reclassement ne declenche plus de remplacement automatique `hors cadre -> cadre` pour les offres deleguees actives.
- [x] Effet attendu:
  - les offres deleguees `hors cadre` actives restent en supplement tant que l'utilisateur ne les resilie pas lui-meme;
  - seules les activations manuelles d'affiliés sans offre entrent dans le quota reseau.
- [x] Invariants a proteger dans `app_ecommerce_functions.php`:
  - ne jamais transformer une delegation `hors_cadre` active en `cadre` par simple recalcul runtime;
  - ne jamais declencher de remplacement automatique d'une delegation `hors_cadre`;
  - ne jamais propager la fin BO ou Stripe du support vers une delegation `hors_cadre`;
  - reserver `En attente` aux seuls write paths explicites.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-16 — Stripe portail reseau: hardening technique historique autour de `subscription_update`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuve log:
    - `pro/logs/error_log` avec `Missing required param: features[subscription_update][products]` sur la config `network`
- [x] Cause confirmee:
  - la sync `network` activait `features.subscription_update.enabled=true` sans pousser le catalogue produit/prix attendu par Stripe;
  - le deep-link `subscription_update` restait donc considere comme desactive/incomplet.
- [x] Correctif livre:
  - ajout d'un helper qui derive `product_id` + `price_ids` recurrents depuis la souscription Stripe ciblee;
  - fusion de ce catalogue avec les `products` deja presents sur la configuration Billing Portal;
  - ajout de `default_allowed_updates=['price']` quand necessaire.
- [x] Correctif complementaire livre:
  - filtrage des prix compatibles Billing Portal `subscription_update` (`active`, `recurring`, `billing_scheme=per_unit`, `usage_type=licensed`, sans `tiers_mode` ni `transform_quantity`);
  - remplacement integral de la liste de prix du produit reseau cible pour eliminer les anciens prix invalides deja stockes sur la config.
- [x] Portee:
  - la sync reseau garde le headline `Cotton - Abonnement réseau`;
  - elle completrait aussi la config Stripe avec un catalogue `subscription_update` coherent pour ce lot historique.
- [x] Realignement metier livre:
  - le portail reseau standard n'essaie plus de synchroniser `subscription_update` hors besoin explicite;
  - la vue PRO abonnement reseau peut maintenant utiliser un flux de resiliation sans trainer ces contraintes de modification Stripe;
  - ce bloc ne doit plus etre relu comme une validation V1 d'un parcours de modification de plan.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Reseau: les affiliés supprimes du SI ne doivent plus consommer le quota reseau
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuve metier:
    - des affiliés supprimes via le BO restaient comptes comme actifs dans la couverture reseau, bloquant la creation d'une offre incluse sur `quota_reached`
- [x] Cause confirmee:
  - la couverture active et la sync legacy relisaient `ecommerce_offres_to_clients` sans verifier l'existence courante de `id_client_delegation` dans `clients`;
  - des delegations orphelines restaient donc consommees meme apres suppression du client cote SI.
- [x] Correctif livre:
  - ajout d'un `INNER JOIN clients` dans `app_ecommerce_reseau_delegations_actives_resolues_get_liste()`;
  - ajout du meme filtre dans `app_ecommerce_reseau_contrat_sync_legacy_delegations()`.
- [x] Effet attendu:
  - un affilié supprime du SI sort du calcul `quota_consumed/quota_remaining`;
  - la place redevient disponible pour un nouvel affilié reel.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Reseau: le signup affilié ne doit plus reclencher un reclassement global avant son activation incluse
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmee:
  - `client_affilier()` relancait encore `app_ecommerce_reseau_contrat_reclassify_delegations()` juste apres l'ecriture de l'affiliation;
  - sur `signup_affiliation`, ce recalcul precoce concurrencait l'orchestration dediee `activation explicite included`.
- [x] Correctif livre:
  - `client_affilier()` accepte maintenant un flag `run_network_reclassify`;
  - `app_ecommerce_reseau_affilier_client()` le passe a `0` uniquement pour `source='signup_affiliation'`.
- [x] Portee:
  - les autres appels a `client_affilier()` gardent le reclassement historique.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Reseau: le reclassement auto ne doit plus terminer l'offre source du signup affilié
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuve fonctionnelle:
    - offre deleguee creee cote SI directement en `Terminee` avec `debut = fin` apres signup affilié sous abonnement reseau
- [x] Cause confirmee:
  - le remplacement auto `hors_cadre -> cadre` recreait la cible via le helper de creation deleguee;
  - la garde d'idempotence pouvait re-selectionner la ligne source elle-meme comme offre active equivalente;
  - le write path de remplacement cloturait alors cette source, d'ou une offre terminee le jour meme.
- [x] Correctif livre:
  - ajout d'un `id_offre_client_exclude` optionnel dans `app_ecommerce_reseau_offre_deleguee_create_for_affilie()`;
  - utilisation de cette exclusion depuis `app_ecommerce_reseau_delegated_offer_replace()` quand la cible `cadre` est creee;
  - garde defensive supplementaire `target_offer_same_as_source`.
- [x] Cause complementaire confirmee:
  - la creation deleguee declenchait `app_ecommerce_reseau_facturation_refresh_from_offer_client()`;
  - ce refresh relancait aussitot `app_ecommerce_reseau_contrat_reclassify_delegations()` pendant le write path, ouvrant une recursion `create -> refresh -> reclassify -> create`.
- [x] Correctif complementaire livre:
  - ajout d'un flag `run_post_create_hooks` sur `app_ecommerce_reseau_offre_deleguee_create_for_affilie()`;
  - les write paths reseau qui font deja un reclassement/activation ensuite desactivent ces hooks immediats pour n'executer qu'un seul recalcul en fin de flux.
- [x] Correctif complementaire 2 livre:
  - `app_ecommerce_reseau_contrat_reclassify_delegations()` est maintenant protege contre la reentrance dans une meme requete PHP pour un meme `id_client_siege`;
  - `app_ecommerce_reseau_delegated_offer_replace()` ne lance plus deux `facturation_refresh_from_offer_client()` successifs apres remplacement, mais un seul `app_ecommerce_reseau_facturation_refresh()` global.
- [x] Correctif d'orchestration livre:
  - `app_ecommerce_reseau_affilier_client()` special-case maintenant `signup_affiliation`;
  - ce flux passe directement par `app_ecommerce_reseau_activation_activate_affiliate_explicit(... activation_mode_request=included ...)`;
  - l'offre deleguee de premiere affiliation est donc creee directement en `cadre` quand le support reseau est actif, sans write path de remplacement.
- [x] Ajustement final livre:
  - `app_ecommerce_reseau_activation_activate_affiliate_explicit()` supporte `skip_post_activation_reclassify`;
  - `signup_affiliation` l'utilise pour ne pas relancer le reclassement final interne sur une premiere creation `cadre`.
- [x] Effet de bord corrige:
  - l'activation explicite reseau relance maintenant `app_ecommerce_reseau_affilie_pipeline_sync_from_effective_offer()`;
  - le pipe affilié redevient coherent (`ABN/PAK`) meme sans passage par le write path de reclassement.
- [x] Ajustement final:
  - l'activation explicite `included` n'est plus bloquante si `id_erp_jauge_cible` n'est pas encore resolue dans la couverture;
  - le helper de creation de delegation reprend alors sa logique de fallback historique.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — AI Studio signup pro: loader fiabilise avec `__DIR__`
- [x] Audit confirme dans:
  - `global/web/global_librairies.php`
  - `global/web/ai_studio/workflows/crm/1_emails_transactional/ai_studio_emails_transactional_functions.php`
  - dependance creation client:
    - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - preuve log:
    - `pro/logs/error_log` sur `POST /extranet/account/establishment/script` avec `Call to undefined function ai_studio_email_transactional_send()`
- [x] Cause confirmee:
  - le fichier workflow existait bien, mais le `require` passait par un chemin relatif sensible au `cwd` PHP;
  - le signup lisait aussi un `id_remise` session non garanti et la creation client pouvait lire un departement non resolu.
- [x] Correctif livre:
  - chargement de la brique AI Studio via `__DIR__`;
  - garde sur `$_SESSION['id_remise']` dans le signup;
  - garde sur la resolution `referentiels_zones_departements`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/global_librairies.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php` OK

## PATCH 2026-03-15 — Reseau: auto-attribution affilié rendue idempotente
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - point d'entree relu:
    - `pro/web/ec/modules/compte/client/ec_client_script.php`
  - preuve log:
    - `pro/logs/error_log` sur `id_client=2054` avec une rafale d'offres deleguees actives (`id_offre_client` successifs `7426` -> `8123`)
- [x] Cause confirmee:
  - le signup affilié sous abonnement reseau pouvait rejouer l'auto-attribution sans verrou metier;
  - la creation deleguee ne reverifiait pas l'existence d'une offre equivalente juste avant l'`INSERT`.
- [x] Correctif livre:
  - verrou MySQL par couple `siege/affilie` dans l'auto-attribution reseau;
  - verrou MySQL dans la creation de delegation;
  - garde SQL d'idempotence sur la combinaison `offre + jauge + frequence + support_source` avant insertion.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-15 — Branding dev: retour vide propre si le client branding est absent
- [x] Audit confirme dans:
  - `global/web/app/modules/entites/clients_branding/app_clients_branding_functions.php`
  - preuve log:
    - `pro/logs/error_log` (`Undefined variable: branding_type_slug`, `Trying to access array offset on value of type null`)
- [x] Cause confirmee:
  - le helper branding continuait avec un `app_client_detail` vide, puis lisait `seo_slug` et d'autres donnees non garanties.
- [x] Correctif livre:
  - initialisation defensive du contexte par defaut;
  - retour immediat du branding vide si aucun client exploitable n'est resolu.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients_branding/app_clients_branding_functions.php` OK

## PATCH 2026-03-15 — AI Studio transactionnel: chemin legacy corrige pour eviter le fatal pro dev
- [x] Audit confirme dans:
  - `global/web/global_librairies.php`
  - `global/web/ai_studio/workflows/crm/1_emails_transactional/ai_studio_emails_transactional_functions.php`
  - preuve log:
    - `pro/logs/error_log` (`Call to undefined function ai_studio_email_transactional_send()` depuis `ec_client_script.php:227`)
- [x] Cause confirmee:
  - le loader global pointait encore vers `ai_studio/workflows/crm/emails_transactional/...`;
  - la fonction existe en realite sous `ai_studio/workflows/crm/1_emails_transactional/...`, donc elle n'etait jamais chargee dans `pro`.
- [x] Correctif livre:
  - le loader global tente maintenant le chemin reel `1_emails_transactional` puis garde l'ancien chemin en fallback;
  - l'URL du webhook transactionnel est elle aussi alignee sur `1_emails_transactional`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/global_librairies.php` OK
  - `php -l /home/romain/Cotton/global/web/ai_studio/workflows/crm/1_emails_transactional/ai_studio_emails_transactional_functions.php` OK

## PATCH 2026-03-15 — Portail Stripe reseau: deep-link sur la souscription support + headline aligne
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Causes confirmees:
  - le CTA `Mon offre` de l'abonnement reseau ouvrait une session Billing Portal globale du customer TdR, sans `flow_data`, donc non ciblee sur la souscription support;
  - le libelle visible cote Stripe restait porte par une configuration portail reseau historique non alignee sur `Abonnement reseau`.
- [x] Correctif livre:
  - le helper Billing Portal supporte maintenant aussi un deep-link `subscription_update` cible sur une souscription donnee;
  - la configuration portail reseau voit son `business_profile.headline` resynchronise vers `Cotton - Abonnement reseau` avant creation de session;
  - le sync reseau active aussi `features.subscription_update` sur cette configuration pour autoriser ce deep-link cible;
  - les autres variantes portail Stripe restent inchangées.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Reclassement support reseau par remplacement de la `hors cadre` legacy (historique abandonné)
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - focus:
    - `app_ecommerce_reseau_contrat_reclassify_delegations(...)`
    - `app_ecommerce_reseau_delegated_offer_replace(...)`
- [x] Cause confirmee:
  - le remplacement auto vers `cadre` ne dependait que de l'etat de la table d'activation (`mode_facturation=hors_cadre`);
  - une offre deleguee legacy pouvait donc rester la meme ligne SI si l'activation etait deja passee en `cadre`, meme sans rattachement au support reseau courant.
- [x] Correctif livre:
  - le reclassement force maintenant un vrai remplacement vers `cadre` quand l'offre active n'est pas deja sourcee par le support reseau courant (`reseau_id_offre_client_support_source`);
  - l'ancien critere sur `mode_facturation=hors_cadre` reste en fallback quand la colonne de source n'est pas disponible.
- [x] Relecture V1 finale:
  - cette logique de remplacement `hors_cadre -> cadre` n'est plus retenue;
  - l'invariant V1 conserve seulement la bonne ecriture des activations `cadre` explicites, sans auto-reclassement.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Checkout reseau: transmettre l'id securite de retour Stripe
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/compte/offres/ec_offres_script.php`
    - `pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php`
- [x] Cause confirmee:
  - le flux `pay_network_support` preparait bien Checkout Stripe mais ne remontait pas l'`id_securite` de l'offre support au retour;
  - `script/cb` redirigeait alors vers `manage/s3/` sans identifiant.
- [x] Correctif livre:
  - le helper reseau remonte maintenant `id_offre_client_support_securite`;
  - le point d'entree compte/offres stocke cette valeur en session avant redirection Stripe;
  - le step 3 garde un fallback sur l'offre support reseau courante si l'identifiant manque encore.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_form_step_3.php` OK

## PATCH 2026-03-13 — Stripe trialing: exposer `trial_end` pour `Mon offre`
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - dependance relue:
    - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Cause confirmee:
  - le snapshot Stripe expose le statut `trialing` mais pas explicitement `trial_end`, donc la vue metier affichait encore la periode abonnement au lieu de la fin d'essai.
- [x] Correctif livre:
  - le snapshot Stripe remonte maintenant `trial_start` et `trial_end`;
  - la vue `Mon offre` peut ainsi afficher une date d'essai Stripe active sans casser l'affichage standard apres essai.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-13 — Stripe standard: autocreation du prix catalogue manquant
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - preuve log complementaire:
    - `pro/logs/error_log` (`reason=stripe_price_not_found ; detail=ABN100M` apres le premier correctif)
- [x] Cause confirmee:
  - certains environnements Stripe n'exposent pas encore le `Price` catalogue attendu, donc la simple resolution `lookup_keys/search` reste vide;
  - un pre-checkout SQL faisait aussi un `fetch_assoc()` sans verifier le resultat de requete.
- [x] Correctif livre:
  - ajout d'un helper global d'autocreation ciblee du `Price` Stripe catalogue avec conservation du `lookup_key`;
  - le checkout standard ne declenche cette creation qu'en fallback sur `price_not_found`, a partir du montant TTC et de la periodicite deja portes par l'offre client;
  - le pre-checkout SQL est garde contre un resultat `false`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK

## PATCH 2026-03-13 — Stripe standard: resolution catalogue robuste + garde-fou portail
- [x] Audit confirme dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - preuves log:
    - `pro/logs/error_log` (`stripe_price_not_found` sur `ABN100A` / `ABN100M`)
    - `pro/logs/error_log` (`No such subscription ... a similar object exists in live mode`)
- [x] Causes confirmees:
  - la resolution des tarifs Stripe standard reposait sur `Price::search` uniquement, ce qui laissait echouer des cles catalogue pourtant attendues;
  - la preparation `subscription_cancel` du portail standard pouvait tenter une annulation sur une souscription inaccessible dans l'environnement Stripe courant.
- [x] Correctif livre:
  - ajout d'un helper global de resolution Stripe par `lookup_key`, qui tente d'abord `Price::all(lookup_keys=...)`, puis seulement un fallback `search`;
  - la preparation de session portail bloque maintenant proprement un deep link `subscription_cancel` si le snapshot de la souscription remonte deja une erreur Stripe.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Réseau TdR: downsell délégué différé (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - en changement manuel `hors cadre` avec `deferred_end_of_period`, la cible payée pouvait être revalidée à `id_etat=3` par le write path post-paiement avant la vraie fin de la source;
  - cela cassait la planification: source sans `date_fin` visible et cible active trop tôt.
- [x] Correctif livré:
  - `app_ecommerce_offre_client_valider(...)` saute désormais l'activation immédiate pour une cible de remplacement différé;
  - le précheck et le planificateur différé acceptent maintenant une cible déjà payée mais encore en `id_etat=2`.
  - le planificateur différé aligne aussi maintenant la `date_fin` source sur `current_period_end` renvoyé par Stripe si la période courante n'est pas encore entièrement résolue localement.
- [x] Relecture V1 finale:
  - cette logique de `downsell` délégué n'est plus une trajectoire produit active;
  - elle reste documentée ici uniquement comme historique technique abandonné.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Stripe: helper local de lecture des configs Billing Portal
- [x] Audit confirmé dans:
  - `global/web/assets/stripe/sdk/tools/list_billing_portal_configurations.php`
- [x] Besoin couvert:
  - récupérer les IDs `bpc_...` et leurs modes Stripe à partir de la clé déjà présente dans le code, y compris en prod, sans dépendre d'une clé recopiée à la main.
- [x] Correctif livré:
  - ajout d'un helper CLI `dev|prod` qui charge `config.php`, `init.php` et `stripe_sdk_functions.php`, puis liste les configurations Billing Portal Stripe avec `subscription_cancel_mode`, `proration_behavior` et `subscription_update_enabled`;
  - validation en `dev`: `bpc_1TAU7iLP3aHcgkSElGilMv0U` est bien en `immediately`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/tools/list_billing_portal_configurations.php` OK
  - `php /home/romain/Cotton/global/web/assets/stripe/sdk/tools/list_billing_portal_configurations.php dev` OK

## PATCH 2026-03-13 — Stripe portail affilié: réalignement sur 2 variantes utiles (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- [x] Décision métier appliquée:
  - pas de variante `network_affiliate_manage`;
  - changements d'offre déléguée `hors cadre` via tunnel Cotton;
  - seules restaient les voies `cancel_end_of_period` et `cancel_immediate` dans cette étape historique.
- [x] Correctif livré:
  - suppression du support utile de `network_affiliate_manage`;
  - préremplissage `dev` des deux variantes sur les configs Stripe déjà existantes:
    - `network_affiliate_cancel_end_of_period` -> `bpc_1T9LACLP3aHcgkSEh2y79vUB`
    - `network_affiliate_cancel_immediate` -> `bpc_1TAU7iLP3aHcgkSElGilMv0U`
- [x] Relecture V1 finale:
  - la vérité finale n'ouvre plus ni réactivation dédiée ni changement d'offre `hors_cadre`;
  - seule la résiliation explicite d'une délégation `hors_cadre` reste à conserver fonctionnellement.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php` OK

## PATCH 2026-03-13 — Stripe portail affilié: variantes dédiées par usage hors cadre (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
- [x] Constat confirmé:
  - une résiliation unitaire déléguée `hors cadre` passait par la mauvaise voie Stripe et finissait en annulation effective au lieu de planifier `cancel_at_period_end`.
- [x] Correctif livré:
  - ajout du support des variantes `network_affiliate_manage`, `network_affiliate_cancel_end_of_period` et `network_affiliate_cancel_immediate`;
  - le helper de préparation de session portail accepte maintenant une `configuration_variant` explicite pour les offres affiliées réseau;
  - la résolution des IDs supporte les nouvelles variables d'environnement Stripe dédiées à ces variantes.
- [x] Relecture V1 finale:
  - `network_affiliate_manage` et les usages de réactivation / remplacement associés ne sont plus retenus comme vérité finale.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php` OK

## PATCH 2026-03-13 — Stripe portail réseau: audit ciblé customer/subscription avant write Stripe
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Constat confirmé:
  - le clic `Voir / résilier` / `Réactiver mon offre` ne fait aucun write Stripe côté Cotton; seul le portail Stripe peut poser `cancel_at_period_end`;
  - le log existant ne permettait pas de vérifier si la session portail était créée avec le bon `customer` pour la souscription ciblée.
- [x] Correctif livré:
  - le helper portail récupère maintenant un snapshot Stripe de la souscription ciblée avant création de session;
  - le résultat et les logs exposent `configuration_id`, `flow_type`, `subscription_customer_id`, `customer_subscription_match`, `subscription_status`, `subscription_cancel_at_period_end` et `subscription_current_period_end`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Réseau TdR: une fin Stripe future doit primer sur la clôture terminale
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause confirmée:
  - une délégation `hors cadre` résiliée via portail Stripe pouvait recevoir un événement terminal alors que `current_period_end` était encore future;
  - le write path terminal rabattait alors la clôture au jour courant si aucune `date_fin` future n'avait encore été persistée localement;
  - même après persistance de la bonne `date_fin`, le helper pouvait encore désactiver immédiatement l'offre et la passer trop tôt à `Terminée`.
- [x] Correctif livré:
  - la réconciliation Stripe -> SI traite désormais toute `current_period_end` future comme une fin planifiée prioritaire, même si Stripe expose déjà un statut terminal;
  - la désactivation réseau immédiate ne doit donc plus partir trop tôt sur une résiliation portail censée courir jusqu'à la fin de période;
  - tant que la fin Stripe est future, le helper sort maintenant sans passer l'offre en `Terminée`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Réseau TdR: réconciliation Stripe des délégations `hors cadre`
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Causes confirmées:
  - une résiliation faite dans le portail Stripe d'une délégation `hors cadre` n'avait aucun write path SI dédié;
  - les scénarios de remplacement immédiat décrits dans ce lot sont désormais à lire comme historiques abandonnés.
- [x] Correctifs livrés:
  - ajout d'une réconciliation Stripe -> SI pour les souscriptions déléguées `hors cadre` sur `customer.subscription.updated` / `customer.subscription.deleted`;
  - `cancel_at_period_end` met maintenant à jour la `date_fin` SI, et un statut terminal déclenche la désactivation/clôture côté réseau;
  - la partie encore valable pour V1 est la réconciliation de résiliation fin de période / fin effective; pas le remplacement.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK

## PATCH 2026-03-13 — Réseau TdR / Stripe: sync pipeline hors cadre et robustesse `customer_id`
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Causes confirmées:
  - une offre déléguée `hors cadre` activée après paiement écrivait bien l'activation réseau, mais ne resynchronisait pas le pipeline affilié;
  - `app_ecommerce_stripe_customer_ensure_for_client(...)` pouvait encore sortir sans `customer_id` exploitable si le client possédait déjà un `asset_stripe_customerId` mais pas de contact principal/email exploitable.
- [x] Correctifs livrés:
  - ajout d'un appel explicite à `app_ecommerce_reseau_affilie_pipeline_sync_from_effective_offer(...)` juste après l'activation hors cadre payée;
  - ajout d'un fallback de sync direct basé sur l'offre déléguée effectivement activée si la lecture canonique de l'offre effective ne remonte pas encore au moment du webhook;
  - le helper Stripe renvoie maintenant le `customer_id` déjà connu même en l'absence de contact exploitable, ce qui limite les blocages standard/portail liés à la qualité des données client.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Réseau TdR: persistance dédiée des remplacements délégués différés (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `www/web/bo/cron_routine_bdd_maj.php`
  - `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql`
- [x] Cause confirmée:
  - les downsells manuels délégués validés fonctionnellement reposaient encore sur des marqueurs `[reseau_replace:*]` et `[reseau_replace_timing:*]` stockés dans `ecommerce_offres_to_clients.commentaire`;
  - cette persistance technique rendait le cron dépendant d’un champ métier libre, alors que la planification différée est maintenant un objet d’orchestration à part entière.
- [x] Correctif livré:
  - ajout d’une persistance dédiée `ecommerce_reseau_delegated_replacements` pour les remplacements planifiés d’offres déléguées;
  - le scheduler différé écrit désormais d’abord dans cette table, puis le cron exécute en priorité les lignes `scheduled` arrivées à échéance;
  - `app_ecommerce_reseau_delegated_offer_replace_context_extract(...)` relit aussi cette table avant tout fallback legacy sur `commentaire`;
  - une compatibilité de reprise reste active pour les anciennes planifications déjà créées via marqueurs, afin d’éviter toute rupture après déploiement du patch.
- [x] Relecture V1 finale:
  - les règles `upsell manuel = remplacement immédiat`, `downsell manuel = remplacement différé` et `auto-reclassement = remplacement immédiat` ne sont plus retenues;
  - cette persistance doit être lue uniquement comme trace d'une étape historique abandonnée.
- [x] Alignement develop/prod 2026-03-23:
  - le script phpMyAdmin de référence `www/web/bo/www/modules/ecommerce/reseau_contrats/bdd_ecommerce_reseau_contrats.sql` ne doit plus créer cette table historique;
  - un SQL one-shot d'alignement supprime aussi `ecommerce_reseau_delegated_replacements` des bases `develop` déjà dérivées de l'ancien état.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Widget délégué: remplacement manuel explicite dans le catalogue (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Cause confirmée:
  - le widget savait afficher le contexte délégué, mais pas distinguer un changement d’offre manuel ni identifier l’offre source active.
- [x] Correctif livré:
  - le bandeau du tunnel passe à `Changement d’offre pour ...` quand le contexte de remplacement manuel est présent;
  - l’offre source reste visible mais son CTA devient `Offre actuelle` et reste désactivé sur la périodicité active.
- [x] Relecture V1 finale:
  - ce contexte de remplacement manuel n'est plus une trajectoire produit V1.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK

## PATCH 2026-03-13 — Stripe portail réseau: IDs test centralisés dans `global` (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/config.php`
- [x] Correctif livré:
  - ajout d'un helper global pour résoudre les IDs de configuration Billing Portal par variante;
  - retrait de l'ID `network` injecté dans `pro/web/config.php`;
  - ajout de la variante test `network_affiliate` dédiée aux offres affiliées sans `Modifier`.
- [x] Relecture V1 finale:
  - la variante `network_affiliate` ne doit plus être relue comme une surface finale active;
  - la vérité V1 conserve seulement la résiliation explicite des délégations `hors_cadre`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/config.php` OK

## PATCH 2026-03-13 — Stripe portail affilié: deep link sur la souscription choisie (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Correctif livré:
  - le helper portail accepte maintenant un `flow_type=subscription_cancel` optionnel;
  - en contexte affilié réseau, la session Stripe peut être créée directement sur la souscription ciblée au lieu d'ouvrir la liste globale client.
- [x] Relecture V1 finale:
  - ce bloc reste un détail technique historique des anciennes variantes portail;
  - il ne doit plus être relu comme la base d'un parcours `Gérer l'offre` ou `Changer d'offre` en V1.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK

## PATCH 2026-03-13 — Réseau TdR: write path unique de remplacement d’une offre déléguée active (historique abandonné)
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
  - `pro/web/ec/modules/compte/client/ec_client_network_script.php`
- [x] Cause confirmée:
  - le flux délégué savait créer ou rattacher une nouvelle offre `hors cadre`, mais pas remplacer proprement une délégation active existante;
  - l’auto-reclassement `hors cadre -> cadre` se contentait encore d’un switch de mode de facturation dans la surcouche réseau, sans clôturer l’ancienne offre ni résilier proprement la subscription Stripe source.
- [x] Correctif livré:
  - ajout du helper central `app_ecommerce_reseau_delegated_offer_replace(...)` avec garde-fous, verrou applicatif par offre source et sortie structurée (`ok`, `blocked_reason`, `stripe_action`, `si_updates`, `facturation_refresh_done`);
  - ajout d’un helper Stripe d’annulation immédiate avec prorata sur la subscription source, déclenché seulement après validation complète de la cible;
  - le flux de paiement délégué peut maintenant embarquer un contexte `manual_offer_change` persistant sur l’offre cible puis appeler automatiquement le helper de remplacement après paiement validé;
  - l’auto-reclassement vers `cadre` réutilise maintenant le même write path central au lieu d’un simple changement de mode.
- [x] Portée Stripe explicitée:
  - le portail Stripe des offres affiliées peut maintenant cibler une configuration dédiée `network_affiliate`;
  - cette configuration doit être fournie via `STRIPE_BILLING_PORTAL_CONFIGURATION_NETWORK_AFFILIATE_ID` ou `STRIPE_BILLING_PORTAL_CONFIGURATION_NETWORK_AFFILIATE` pour garantir un portail `Voir / résilier` sans `Modifier`.
- [x] Relecture V1 finale:
  - ce write path de remplacement, `manual_offer_change` et l'auto-reclassement associe ne sont plus des trajectoires actives a retenir.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/client/ec_client_network_script.php` OK

## PATCH 2026-03-13 — Réseau TdR: sécurisation du repricing Stripe des offres déléguées hors cadre
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/ec_webhook_stripe_handler.php`
- [x] Cause confirmée:
  - le repricing dynamique des offres déléguées hors cadre existait déjà, mais il dépendait d'un `refresh` réseau et pas du cycle Stripe lui-même;
  - un renouvellement automatique pouvait donc repartir sur un montant non rafraîchi si aucun refresh réseau n'était intervenu avant échéance.
- [x] Correctif livré:
  - ajout d'un helper global ciblant uniquement une subscription Stripe rattachée à une offre déléguée `hors cadre` de TdR;
  - le webhook Stripe appelle désormais ce helper sur `invoice.upcoming` et `invoice.created`, puis le relance en contrôle sur `invoice.paid` pour les cycles;
  - les autres abonnements restent hors périmètre de ce mécanisme.
- [x] Point d'exploitation:
  - pour bénéficier de la pré-sync avant prélèvement, l'endpoint Stripe doit bien être abonné aux événements `invoice.upcoming` et `invoice.created`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/ec_webhook_stripe_handler.php` OK

## PATCH 2026-03-13 — Tunnel délégué: fallback serveur sur contexte affilié `pending`
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `pro/web/ec/modules/ecommerce/offres/ec_offres_script.php`
- [x] Cause confirmée:
  - un retour navigateur vers le step 1 pouvait rejouer un POST sans `network_delegated_token`;
  - le flux délégué repartait alors hors contexte affilié, malgré une offre `pending` déjà ouverte pour cet affilié.
- [x] Correctif livré:
  - ajout d'un helper global pour retrouver l'offre déléguée `pending` d'un affilié;
  - le step 1 PRO réutilise maintenant le contexte délégué en session quand le token manque mais qu'une offre `pending` cohérente existe déjà.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/ecommerce/offres/ec_offres_script.php` OK

## PATCH 2026-03-13 — Réseau PRO: CTA `Commander` explicite et remise détaillée en confirmation
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
  - `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php`
- [x] Cause confirmée:
  - le tunnel délégué pouvait encore conserver un libellé hérité comme `Essayer gratuitement` sur la première étape;
  - la page de confirmation n'affichait que `Remise réseau`, sans rappeler le pourcentage réellement stocké sur l'offre.
- [x] Correctif livré:
  - en contexte `network_delegated_token`, le CTA de sélection d'offre affiche maintenant `Commander`;
  - la note d'essai gratuit reste neutralisée dans ce contexte;
  - le bloc marketing CHR retire aussi la mention `testez pendant 15 jours` en contexte affilié;
  - la confirmation affiche désormais `Remise réseau (x%)` quand un pourcentage est présent sur l'offre.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK
  - `php -l /home/romain/Cotton/pro/web/ec/modules/compte/offres/ec_offres_include_detail.php` OK

## PATCH 2026-03-13 — Réseau PRO: tunnel délégué aligné sur la typologie de la TdR, sans promesse d'essai gratuit
- [x] Audit confirmé dans:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - `global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php`
- [x] Cause confirmée:
  - l'entrée de commande déléguée redirigeait en dur vers le segment catalogue `abonnement`, sans reprendre la typologie de la tête de réseau qui commande;
  - en parallèle, le widget catalogue pouvait encore afficher les marqueurs UI d'essai gratuit en contexte affilié, alors que la création `pending` d'offre déléguée force déjà `trial_period_days = 0`.
- [x] Correctif livré:
  - ajout d'un helper global de résolution du point d'entrée catalogue PRO selon la typologie de la TdR (`abonnement` / `evenement` / `particulier`);
  - le démarrage d'un checkout délégué réutilise désormais ce helper pour choisir la bonne route de tunnel;
  - le widget catalogue masque maintenant toute UI d'essai gratuit en contexte `network_delegated_token` et poste aussi `trial_period_days = 0`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php` OK
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` OK

## DOC 2026-03-13 — Réseau BO: navigation croisée vers la TdR et l'offre support
- [x] Documentation transversale alignée:
  - la fiche BO `Abonnement réseau` expose désormais le client TdR en accès direct;
  - la synthèse BO `Affiliés du réseau` permet maintenant de rouvrir directement l'offre support active.
- [x] Portée métier rappelée:
  - aucun helper runtime global ni write path réseau n'est modifié par ce lot;
  - le changement porte uniquement sur l'exposition BO de liens de navigation autour du support réseau.

## PATCH 2026-03-12 — Réseau: rebaseline documentaire du plan pré-prod
- [x] Étapes closes fonctionnellement
  - `Étape 1`
    - resolver canonique confirmé;
    - priorité réelle confirmée: offre propre active, puis accès réseau actif, sinon inactif;
    - mapping final des `inactive_reason` explicitement exposé.
  - `Étape 2`
    - `ecommerce_offres_to_clients` reste le support commercial / Stripe principal;
    - `ecommerce_reseau_contrats*` reste une surcouche technique de capacité, rattachement, mode de facturation et trace.
  - `Étape 2A`
    - pas d’auto-création support encore branchée hors ajout BO explicite;
    - les helpers `ensure/backfill` restent seulement tolérés comme code dormant tant qu’aucun appel actif n’est prouvé.
  - `Étape 2B`
    - lecture BO `reseau_contrats` stabilisée;
    - distinction `Incluse à un abonnement réseau` vs `Hors abonnement réseau` stabilisée;
    - fallback BO historique seulement toléré comme legacy borné.
- [x] Étape close avec réserve
  - `Étape 3`
    - fermée sur le code livré d’après les audits déjà obtenus;
    - invariants métier confirmés:
      - `affiliation != accès actif`
      - offre propre active prioritaire
      - offre propre affilié jamais repricée
      - seules les délégations TdR `hors abonnement réseau` sont repricées
      - pas d’accès réseau effectif sans offre support active
    - réserve explicite:
      - absence de preuve de bout en bout sur un cycle Stripe réel après changement de palier.
- [x] Prochain lot pré-prod attendu
  - hardening final des étapes `1 / 2`:
    - purge des derniers fallbacks legacy encore actifs ou appelables
    - audit final colonne par colonne de `ecommerce_reseau_contrats`
    - normalisation documentaire / SQL prouvée du schéma `ecommerce_reseau_contrats*`
  - validation Stripe réelle finale pour lever la réserve de l’étape `3`.
- [x] Hors périmètre maintenu
  - étapes `4 / 5 / 6` volontairement non ouvertes à ce stade;
  - pas de nouvelles tâches fonctionnelles hors pré-prod.

## PATCH 2026-03-12 — Réseau: remise dynamique persistant les délégations `hors abonnement réseau`
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - la remise réseau était recalculée dynamiquement pour les agrégats et affichages;
  - la facturation réelle des abonnements reposait toutefois sur le `prix_ht` stocké sur chaque offre déléguée.
- [x] Correctif runtime appliqué
  - le calcul des offres `hors abonnement réseau` repart maintenant du tarif catalogue de référence puis applique la remise réseau courante;
  - le refresh réseau persiste le `prix_ht` net, `remise_nom` et `remise_pourcentage` sur chaque délégation active concernée;
  - une synchro Stripe dédiée met aussi à jour la souscription correspondante sans prorata immédiat.
- [x] Périmètre métier explicité
  - la remise réseau ne concerne en prix que les offres déléguées `hors abonnement réseau` portées par la TdR;
  - les offres commandées en propre par un affilié ne sont pas recalculées;
  - en revanche, les affiliés rattachés à la TdR avec offre propre active comptent désormais dans le volume actif servant à déterminer le palier de remise réseau.
- [x] Effet attendu
  - prochaine facturation locale et prochain cycle Stripe alignés sur le palier réseau courant;
  - absence d’impact tarifaire collatéral sur les offres propres affilié.

## PATCH 2026-03-11 — Réseau: rattachement explicite des délégations incluses à l'offre support source
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - aucune offre déléguée ne portait l'id de l'`Abonnement réseau` source;
  - le pointeur `id_offre_client_deleguee` de `ecommerce_reseau_contrats_affilies` reste un état courant, pas un historique fiable.
- [x] Correctif runtime appliqué
  - ajout d'un helper de disponibilité/persistance pour `reseau_id_offre_client_support_source`;
  - les write-paths `cadre` alimentent désormais ce rattachement sur création/réactivation/activation;
  - les flux `hors abonnement réseau` le remettent explicitement à `0`.
- [x] Effet attendu
  - une offre déléguée incluse sait désormais de quel `Abonnement réseau` elle provient;
  - les futures vues d'historique peuvent se brancher sur cette clé sans heuristique fragile.

## PATCH 2026-03-11 — Réseau: helper des offres incluses figé par offre support
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - la couverture canonique BO savait compter le contrat courant, mais pas relire proprement les offres incluses d’une archive `Abonnement réseau`;
  - les vues `offres_clients` risquaient donc de relire le support actif au lieu du support affiché.
- [x] Correctif runtime appliqué
  - ajout d’un helper dédié pour lister les offres déléguées incluses rattachées à une offre support donnée;
  - filtrage par fenêtre de vie de l’offre support affichée pour éviter les biais avec un autre support réseau actif.
- [x] Effet attendu
  - la fiche BO d’un `Abonnement réseau` historique garde son périmètre d’offres incluses;
  - les offres support terminées conservent un historique lisible des délégations reliées.

## PATCH 2026-03-11 — Réseau: reclassement `cadre` vs `hors abonnement` stabilisé
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - la couverture canonique savait déjà distinguer `delegations_cadre` et `delegations_hors_cadre`
  - les libellés métier restaient historiques `contrat cadre` / `hors cadre`
- [x] Correctif runtime appliqué
  - les libellés de couverture sont réalignés sur:
    - `offre déléguée incluse à l'abonnement réseau`
    - `offre déléguée hors abonnement réseau`
  - la vue BO peut désormais s'appuyer sur ces statuts sans ambiguïté métier
- [x] Effet attendu
  - cohérence de lecture entre couverture canonique et écran BO TdR
  - plus de confusion métier entre quota inclus et facturation hors abonnement

## PATCH 2026-03-11 — Reseau post-lot-2: runtime canonique + reorder Stripe
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - la couverture exploitable redevient pilotee par l'offre support active + quota + offre cible
  - aucune reintroduction de `ecommerce_reseau_contrats.contract_state` comme verite metier
- [x] Correctif runtime affiliés applique
  - `app_ecommerce_reseau_contrat_couverture_get_detail(...)` ne depend plus de `contract_state` pour calculer `quota_exploitable`
  - l'activation `cadre` reste conditionnee par l'offre support active et le quota disponible
## PATCH 2026-03-23 — GLOBAL clients_contacts: jeton de connexion EC temporaire
- [x] Audit confirme dans `global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php`
- [x] Correctif runtime applique
  - ajout d'un helper de generation de jeton temporaire pour un `clients_contacts`
  - ajout d'un helper de consommation du jeton avec fenetre courte (`48h`), resolution du client rattache et invalidation immediate
  - aucun nouveau champ SQL ajoute: reutilisation controlee de `pwd_token` / `pwd_token_date`
- [x] Verification
  - `php -l global/web/app/modules/entites/clients_contacts/app_clients_contacts_functions.php` OK

- [x] Correctif BO support applique
  - le flux `ajouter` de l'`Abonnement reseau` resynchronise maintenant les vraies valeurs saisies
  - le premier submit redirige vers la vue enregistree, plus vers un second passage sur le formulaire
- [x] Correctif reorder Stripe appuye sur le write path existant
  - `app_ecommerce_offre_client_gerer(...)` est reutilise pour creer une nouvelle offre avec un nouvel `id_securite`
  - le reorder ne recycle plus une ancienne ligne terminee

## PATCH 2026-03-13 — Remplacement differe des offres deleguees en downsell (historique abandonné)
- [x] Audit confirme dans `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - le write path `app_ecommerce_reseau_delegated_offer_replace(...)` reste adapte aux remplacements immediats
  - le SI disposait deja des briques `date_fin` / cron / webhook Stripe pour porter une fin de periode
- [x] Correctif runtime applique
  - ajout d'une resolution serveur `immediate_prorated` vs `deferred_end_of_period` pour les changements manuels d'offres deleguees hors cadre
  - ajout d'un helper Stripe `cancel_at_period_end` dedie au downsell manuel
  - la cible payee d'un downsell manuel repasse en `id_etat=2` avec date d'effet future, au lieu d'etre rattachee tout de suite
  - la planification SI `source -> cible` est stockee sur l'offre cible via marqueurs de commentaire reutilisables par le cron
- [x] Effet attendu
  - ces hypotheses `upsell manuel`, `downsell manuel` et `auto-reclassement` ne sont plus retenues en V1 finale
  - cette section est conservee seulement comme historique technique

## PATCH 2026-03-13 — Instrumentation du downsell differe delegue (historique abandonné)
- [x] Le diagnostic montre encore un trou entre la cible `En attente` et la planification effective de la source
- [x] Des logs applicatifs ont ete ajoutes sur:
  - `app_ecommerce_reseau_delegated_checkout_offer_attach_after_payment(...)`
  - `app_ecommerce_reseau_delegated_offer_replace_schedule_deferred(...)`
- [x] Les prochains tests doivent maintenant produire une preuve explicite de:
  - blocage `precheck`
  - retour Stripe `cancel_at_period_end`
  - calcul `period_end/effective_date`
  - `affected_rows` sur l'update SQL source
- [x] Le premier test instrumente a isole le vrai root cause:
  - fatal PHP sur appel a `app_ecommerce_offre_client_abonnement_periode_en_cours_get_detail()` (fonction inexistante)
  - correctif applique en reutilisant `app_ecommerce_offre_client_abonnement_periode_get_detail(...)`
- [x] Le test `upsell` a isole un second root cause:
  - au retour webhook, la cible immediate pouvait deja etre consideree comme l'offre active courante
  - `app_ecommerce_reseau_delegated_checkout_offer_context_get(...)` bloquait alors sur `source_offer_not_current` avant la cloture immediate de la source
- [x] Relecture V1 finale:
  - cette instrumentation documente un chantier de `downsell`/`upsell` désormais abandonné comme trajectoire produit;
  - elle reste utile seulement pour mémoire technique.
  - correctif applique pour autoriser ce cas quand l'offre courante est precisement la cible marquee

## PATCH 2026-03-26 — New_EJ: restauration du contrat `develop` autour des participations probables et du bridge EP
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - restauration des helpers `app_session_participation_probable_*` et `app_session_participations_probables_*` supprimés par `new_ej`;
  - `app_joueur_sessions_inscriptions_get_liste()` et `app_joueur_session_inscription_get_detail()` redeviennent compatibles avec les participations probables legacy, y compris pour les types `4` et `5`;
  - conservation du nouveau bridge `EP -> games`;
  - ajout d'un garde-fou sur l'insert bridge `championnats_sessions_participations_games_connectees` pour retomber proprement sur le parcours legacy en cas d'échec SQL.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Signup joueur: tolérance département vide sur création de compte
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - normalisation de `id_zone_departement` à `NULL` dans `app_joueur_ajouter(...)` quand aucun département n'est fourni;
  - évite l'échec SQL sur insertion joueur quand le signup public envoie un département vide.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Joueur: helpers `pseudo` + fallback nom d'affichage
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout des helpers de support `pseudo` (`support colonne`, `normalisation`, `validation`, `lecture`, `save/delete`);
  - contrainte de longueur alignée sur `games`: `1–20` caractères;
  - ajout d'un helper de nom d'affichage avec fallback sur `prenom`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Joueur: helper de suppression de liaison équipe
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un helper `app_joueur_equipe_supprimer(...)` pour retirer une liaison `joueur <=> équipe`;
  - usage destiné à la page EP `Pseudo / Equipes`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Joueur: joueurs liés par équipe + suppression contextuelle
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un helper pour lister les joueurs liés à une équipe avec nom d'affichage pseudo/prénom;
  - évolution de `app_joueur_equipe_supprimer(...)` pour distinguer `left_team` et `team_deleted`;
  - suppression automatique de l'équipe devenue vide après retrait du dernier joueur lié.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-27 — Joueur: suppression compte RGPD depuis l'EP
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un helper `app_joueur_compte_supprimer(...)`;
  - retrait des liaisons équipe avant suppression;
  - purge des tables directement personnelles (`participations_probables`, `participations_games_connectees`, `jeux_bingo_musical_grids_clients`, logs joueur, lots joueur);
  - neutralisation des références legacy de contribution en remplaçant `id_equipe_joueur` par `0` sur les contenus qui doivent rester visibles.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-28 — Joueur: invitation équipe alignée sur `PLAYER_ALL_TEAM_INVITATION`
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `global/web/ai_studio/workflows/crm/emails_transactional/ai_studio_emails_transactional_templates.php`
- [x] Correctif livré:
  - l'envoi invitation équipe appelle maintenant `ai_studio_email_transactional_send('PLAYER','ALL','TEAM_INVITATION', ...)`;
  - le payload alimente les nouvelles variables `CONTACT_PRENOM` (invitant) et `CONTACT_PRENOM_INVITE` (invité), sans dépendre des anciens champs `INVITER_*`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-30 — Sessions: métadonnées `Cotton Quiz` V2 par séries
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - ajout du helper `app_cotton_quiz_get_series_meta(...)` qui lit `quizs_series` pour un quiz client;
  - ajout du helper `app_cotton_quiz_get_session_series_meta(...)` qui lit `championnats_sessions.lot_ids` et résout les noms de lots `L...` / `T...` dans l'ordre de session;
  - `app_jeu_get_detail()` pour `id_type_produit=5` remonte maintenant:
    - `quiz_series_count`
    - `quiz_series_label`
    - `quiz_series_names`
  - `app_session_get_detail()` remonte aussi ces métadonnées session pour que `play` puisse afficher les lots classiques `L...` sans dépendre uniquement de `quizs_series.nom`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-03-30 — Joueur: equipe quiz remontee dans les inscriptions EP
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - `app_joueur_sessions_inscriptions_get_liste(...)` remonte maintenant pour chaque session:
    - `id_equipe_inscrite`
    - `equipe_nom_inscrite`
    - `nb_equipes_inscrites`
  - ces champs permettent a `play` d'afficher un message coherent entre la home et les cartes agenda quiz sans redeviner l'equipe depuis un simple boolen d'inscription.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-03-31 — Session quiz: helper global de compatibilite numerique
- [x] Audit cible:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livre:
  - ajout de `app_session_quiz_digital_guard_get(...)` pour reconstruire la compatibilite numerique d'une session `Cotton Quiz` depuis `lot_ids`, `questions` et `questions_propositions`;
  - la regle alignee avec `games` exige une bonne reponse non vide et au moins deux propositions distinctes de cette reponse.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-04 — Classements agrégés: cohérence des compteurs podiums
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - le mapping `victoire / 2e / 3e` repose désormais sur les bonus nets réellement ajoutés au score agrégé;
  - suppression de l'ancien mapping implicite sur valeurs brutes, devenu incohérent après le passage à `podium remplace participation`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-16 — Helpers de description lieu
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - ajout de helpers globaux pour normaliser `descriptif_court` et `descriptif_long`;
  - nettoyage des anciens `<br>` / balises héritées;
  - conservation des retours à la ligne du descriptif long;
  - `app_client_modifier(...)` stocke désormais ces descriptions sous forme texte normalisée.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-04 — Joueur: helper léger pour `Top classement`
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `play/web/ep/modules/communication/home/ep_home_index.php`
- [x] Correctif livré:
  - ajout de `app_joueur_leaderboards_best_rank_get(...)` pour la home EP;
  - arrêt anticipé dès qu'un rang `#1` est trouvé;
  - cache de session court sur le meilleur rang;
  - suppression de l'appel au contexte complet `app_joueur_leaderboards_get_context(...)` sur la home.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
  - `php -l /home/romain/Cotton/play/web/ep/modules/communication/home/ep_home_index.php`

## PATCH 2026-04-04 — Joueur: historique aligné sur la terminaison des classements
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - `app_joueur_historique_session_is_eligible(...)` réutilise désormais la même notion de session réellement terminée que les classements;
  - exclusion explicite des sessions démo et des sessions incomplètes;
  - les requêtes d'historique remontent les drapeaux session nécessaires (`flag_session_demo`, `flag_configuration_complete`, `flag_controle_numerique`).
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-10 — Stripe portail TdR: fallback subscription snapshot pour offre affiliée déléguée
- [x] Audit ciblé:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
- [x] Cause exacte:
  - le message `network_affiliate_subscription_snapshot_unavailable` venait d'un `asset_stripe_productId` non vide mais non exploitable comme souscription Stripe;
  - pour une offre affiliée déléguée TdR, aucun fallback ne reconstituait la vraie souscription via les métadonnées Stripe `offre_client_id(_securite)`.
- [x] Correctif livré:
  - ajout d'un resolver global `app_ecommerce_stripe_subscription_id_resolve_from_offer_client(...)`;
  - validation du `sub_...` stocké puis fallback via `\Stripe\Subscription::search(...)` sur les métadonnées de l'offre cliente;
  - persistance du `subscription_id` retrouvé dans `ecommerce_offres_to_clients.asset_stripe_productId`;
  - `app_ecommerce_stripe_customer_backfill_from_offer_subscription(...)` et `app_ecommerce_stripe_billing_portal_session_prepare(...)` utilisent désormais ce resolver avant de conclure à `subscription_snapshot_unavailable`;
  - le fallback est borné aux offres déléguées affiliées pour ne pas modifier le comportement des portails Stripe standard.
  - pour les offres non affiliées, `app_ecommerce_stripe_billing_portal_session_prepare(...)` revalide désormais le `customer` Stripe via `app_ecommerce_stripe_customer_ensure_for_client(...)` avant d'essayer d'ouvrir le Billing Portal.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/ecommerce/app_ecommerce_functions.php`

## PATCH 2026-04-07 — Joueur: cache court du contexte leaderboards
- [x] Audit ciblé:
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un cache de session court pour `app_joueur_leaderboards_get_context(...)`;
  - ajout d'un cache mémoire par requête pour éviter les recomputations intra-request;
  - `app_joueur_leaderboards_best_rank_get(...)` réutilise ce cache de contexte quand il existe.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
## PATCH 2026-04-13 — Fiche session Bingo: fallback identité joueur sur résultats
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - le moteur `app_session_results_get_context(...)` réconcilie maintenant les labels `Bingo Musical` avec les liaisons joueur EP (`games_connectees`) puis le fallback legacy `grids_clients`;
  - le podium de phases et la liste des joueurs n'affichent plus seulement `bingo_players.username` quand il est vide;
  - priorité d'affichage: `pseudo`, sinon `prenom nom`, avec appariement via `game_player_id`, `game_player_key` puis libellé normalisé;
  - le switch de résultats session couvre aussi les anciens `Bingo Musical` `id_type_produit = 2`;
  - la liste Bingo fusionne aussi les participants legacy prouvés absents du runtime, et un message dédié est remonté quand seul le podium reste indisponible.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-15 — Helpers podium `play`
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - ajout d'un helper global de stabilisation d'URL photo podium pour les vues `play`, avec priorité au domaine public `www/upload` et fallback final `www prod`;
  - correctif complémentaire: si l'entrée est déjà en `www prod`, le helper reconstruit malgré tout l'URL `www` du serveur courant quand elle est déductible, au lieu de conserver `prod` par défaut;
  - le surlignage joueur `play` couvre désormais aussi `players_podium` / `teams_podium` en plus des lignes de tableaux.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-15 — Archive dashboard: option `historique seul`
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - `app_client_joueurs_dashboard_archive_sessions_get(...)` accepte désormais un drapeau pour éviter le chargement des sessions à venir quand seul l'historique est demandé;
  - le helper accepte aussi un `offset` explicite pour permettre une pagination archive par lots côté `www`;
  - les consumers FO `place` l'utilisent pour `Sessions passées` et les `sessions récentes` liées aux classements.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-16 — Dashboard joueurs: fallback classements sur saison vide
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - ajout d'une finalisation commune du contexte dashboard joueurs pour recalculer `has_summary`, `has_filter_results` et les messages fallback à la fin du pipeline;
  - le cas `synthèse disponible + aucun classement exploitable` remonte maintenant bien `empty_filter`, y compris quand la saison par défaut n'a aucune session filtrée;
  - `app_client_joueurs_dashboard_get_context(...)` et `app_client_joueurs_dashboard_get_context_fo_place(...)` réappliquent aussi cette finalisation après fusion du cache synthèse.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-16 — Cotton Quiz: visuel multi-séries
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - ajout d'un helper `app_cotton_quiz_get_series_visual_src(...)` pour sélectionner le visuel de la dernière série effectivement illustrée d'un quiz;
  - les copies inchangées de `default_cotton_quiz.jpg` sont exclues de cette sélection;
  - `app_jeu_get_detail(...)` réutilise maintenant ce helper pour les quizzes multi-séries, avec fallback inchangé sur `default_cotton_quiz.jpg`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-16 — Branding Blind Test: instrumentation diagnostic
- [x] Audit ciblé:
  - `global/web/app/modules/general/branding/app_branding_ajax.php`
  - `games/web/includes/canvas/core/session_modals.js`
- [x] Instrumentation livree:
  - ajout d'un helper `branding_trace_log(...)` dans `app_branding_ajax.php`;
  - traces ajoutees sur `get`, `save` et `delete_preview` pour journaliser la portee demandee, les ids branding resolus et le branding effectif apres sauvegarde;
  - objectif: confirmer si une session `Blind Test` reste resolue en `branding_session` apres une sauvegarde `branding_client`.
- [x] Correctif livre:
  - suppression de la dependance a `app_session_get_detail(...)` dans `app_branding_ajax.php` pour la resolution du contexte branding;
  - lecture SQL minimale de `championnats_sessions` pour recuperer `id_client` et `id_operation_evenement`;
  - effet attendu: plus de fatal `app_blind_test_get_detail()` sur `get`, `save`, `delete_preview` et `delete` du module branding `global`.
- [x] Verification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_ajax.php`

## PATCH 2026-04-16 — Branding visuel: ratio final force cote `global`
- [x] Audit ciblé:
  - `global/web/app/modules/general/branding/app_branding_functions.php`
  - `games/web/includes/canvas/core/session_modals.js`
- [x] Correctif livré:
  - `app_general_branding_visuel_uploader(...)` ne rabaisse plus la cible `visuel` à la taille source avant upload;
  - ajout d'un post-traitement `app_general_branding_cover_fit(...)` qui recadre par le centre et force le média actif exactement aux dimensions demandées;
  - le backend conserve donc la cible demandée par `app_branding_ajax.php` (`1600x640`, même ratio que `600x240`) et coupe/centre le visuel si nécessaire pour tenir dans ce gabarit;
  - `session_modals.js` est revenu au flux simple avec envoi prioritaire du fichier source brut pour `branding_visuel`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_functions.php`

## PATCH 2026-04-16 — Duplication branding client -> session sécurisée
- [x] Audit ciblé:
  - `global/web/app/modules/general/branding/app_branding_functions.php`
- [x] Correctif livré:
  - `app_general_branding_duplicate_to_target(...)` prépare maintenant les assets dans un dossier de staging puis effectue un swap atomique du dossier cible;
  - si la copie des médias source échoue, la fonction retourne `0` avant toute écriture `general_branding` sur la cible session;
  - le dossier cible précédent est restauré automatiquement si le swap final échoue;
  - effet attendu: plus de `branding_session` écrit avec `logo/visuel` absents lors du gel des sessions programmées avant suppression d'un branding client.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/general/branding/app_branding_functions.php`

## PATCH 2026-04-17 — Sessions: helper partagé de bascule agenda / archive
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - ajout des helpers `app_session_list_item_is_archive(...)` et `app_sessions_filter_by_archive_state(...)`;
  - la décision `agenda` vs `archive` peut désormais être réutilisée par les listes `play`, `www` et widgets `pro` sans reposer uniquement sur `cs.date >= CURDATE()`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-17 — Leaderboards agrégés: labels joueurs / équipes en uppercase
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
- [x] Correctif livré:
  - `app_client_joueurs_dashboard_player_label_get(...)` renvoie désormais `pseudo` ou `prenom` en uppercase;
  - ajout du helper `app_client_joueurs_dashboard_label_display_format(...)`;
  - les lignes/podiums de leaderboards agrégés passent maintenant toutes par ce formateur avant rendu, ce qui harmonise l'uppercase sur joueurs et équipes.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`

## PATCH 2026-04-17 — Résultats de session: labels joueurs en uppercase
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - ajout de `app_session_results_label_display_format(...)`;
  - les labels podium / classement de session sont maintenant formatés en uppercase dans les helpers `app_session_results_*`;
  - le fallback `pseudo` / `prenom` reste bien en `prenom seul`, sans retour à `prenom + nom`;
  - couverture explicite ajoutée aussi sur le cas `Bingo` qui ne passait pas par le ranking compétitif standard.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-17 — FO place: leaderboards recalculés au reload + ordre des jeux aligné sur `pro`
- [x] Audit ciblé:
  - `global/web/app/modules/entites/clients/app_clients_functions.php`
  - `global/web/app/modules/entites/joueurs/app_joueurs_functions.php`
- [x] Correctif livré:
  - `app_client_joueurs_dashboard_get_context_fo_place(...)` ne relit plus un cache de session journalier pour les leaderboards `www place`; le contexte est recalculé au reload afin qu'une session `bingo` nouvellement terminée apparaisse sans attendre une invalidation manuelle;
  - `app_joueur_leaderboards_get_context(...)` impose maintenant l'ordre `blindtest`, `bingo`, `quiz` dans les sections `play`, avec conservation des jeux additionnels éventuels en fin de liste.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/clients/app_clients_functions.php`
  - `php -l /home/romain/Cotton/global/web/app/modules/entites/joueurs/app_joueurs_functions.php`

## PATCH 2026-04-17 — Sessions `quiz`: libellé court `1 série` / `x séries` exposé aussi aux listes
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - `app_sessions_get_liste(...)` sélectionne maintenant aussi `lot_ids`;
  - les lignes de session sont enrichies avec `quiz_series_count`, `quiz_series_label`, `quiz_series_names` pour les types `1` et `5`;
  - `app_session_get_detail(...)` applique le même enrichissement aux sessions `quiz` legacy et V2;
  - `app_jeu_get_detail(...)` expose aussi les métadonnées de séries sur le `quiz` legacy quand elles sont reconstructibles depuis `id_produit`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-17 — Sessions `quiz`: helper partagé de libellé compact agenda
- [x] Audit ciblé:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- [x] Correctif livré:
  - ajout de `app_session_quiz_compact_label_get(...)`;
  - priorité à `quiz_series_label` côté session, puis fallback `quiz_series_label` côté jeu, puis fallback `theme` pour les anciens formats;
  - le helper masque aussi les faux doublons du type `Cotton Quiz`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/app/modules/jeux/sessions/app_sessions_functions.php`

## PATCH 2026-04-30 — Config Stripe isolée du contexte applicatif
- [x] Audit ciblé:
  - `global/web/assets/stripe/sdk/stripe_sdk_functions.php`
  - `global/web/global_config.php`
  - `global/web/global_config_stripe.php`
- [x] Correctif livré:
  - le bootstrap Stripe ne charge plus `global_config.php` en fallback, afin d'éviter l'écrasement de `$conf['site_url']` dans les runtimes `pro` / `www`;
  - les clés Stripe sont isolées dans `global_config_stripe.php`;
  - `global_config.php` inclut désormais cette config dédiée pour conserver le comportement des scripts exécutés dans le contexte `global`.
- [x] Vérification:
  - `php -l /home/romain/Cotton/global/web/global_config.php`
  - `php -l /home/romain/Cotton/global/web/global_config_stripe.php`
  - `php -l /home/romain/Cotton/global/web/assets/stripe/sdk/stripe_sdk_functions.php`
  - test runtime: appel `lib_Stripe_getPrivateApiKey()` avec `$conf['site_url']['prod']='https://pro.cotton-quiz.com'`, valeur conservée après bootstrap.
# PATCH 2026-05-11 - Parametrage LP sur abonnement reseau

- [x] Audit cible:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php`
  - BO `www/web/bo/www/modules/ecommerce/offres_clients/*`
  - LP `www/web/lp/lp.php`
- [x] Correctif livre:
  - ajout de la table runtime `ecommerce_reseau_support_lp_settings`;
  - ajout des helpers `app_ecommerce_reseau_support_lp_settings_get/save`;
  - ajout du resolver `app_ecommerce_reseau_support_offer_active_latest_get(...)` pour la regle V1 "abonnement actif le plus recent";
  - aucune modification de `app_ecommerce_reseau_affilier_client(...)` ni des regles d'activation d'offre incluse.
- [ ] Recette serveur:
  - verifier creation/lecture table sur une fiche `Abonnement reseau`;
  - verifier plusieurs supports actifs et dates incompletes.
# PATCH 2026-07-12 — Resolver Hub papier

- [x] Traiter les sessions papier avant `app_games_hub_runtime_participation_ensure()`.
- [x] Préserver `left` et la réactivation manuelle existante.
- [x] Ne pas promettre qu'un UPSERT moteur prouve l'authentification WS.
# SchedulePlan canonique — terminé le 2026-09-02

- [x] Ajouter validation, résolution du Hub cible, commit, postconditions, compensation et reprise idempotente communs.
- [x] Interdire `reconcile` dans le chemin normal quick-add et compenser les créations en échec.
- [x] Libérer un contexte Hub inactif vide lorsque seule sa projection de publication subsiste.
- [x] Ajouter les contrats `schedule_plan_commit_contract_test.php` et `schedule_plan_commit_behavior_test.php`.
- [ ] Sur dev authentifié, vérifier les lignes `programming_quick_operations` et les ensembles exacts `games_hubs_sessions` après la recette navigateur.
