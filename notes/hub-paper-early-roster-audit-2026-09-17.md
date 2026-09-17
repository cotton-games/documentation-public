# Hub Remote — préparation anticipée des joueurs papier — 17/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-paper-early-roster-audit" owner="codex" -->

## Statut

Patch local Games du17/09/2026, non déployé. Arbitrages utilisateur intégrés : recherche unifiée sans sélecteur ni choix de session, distinction Joueur/Équipe limitée au lookup, clés existantes conservées, fallback « Nouvel invité ». Aucun changement de modèle, migration ou différenciation runtime. Les arrêts d'audit initiaux sont levés par ces arbitrages et la confirmation historique retrouvée pour REMO.

## 1. Journal AI Studio et préconditions

Consultés en RAW : [START, Discipline de génération](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), [SITEMAP texte](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), [README, Doc discipline](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), [manifest, Update triggers et R11](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), [HANDOFF, actions du17/09](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md). Le sitemap HTTP rafraîchi porte `fc96afa40498d9da82ff4265c772a1dd45cc9452`, distinct de la révision initialement fournie. Manifest/HANDOFF/TASKS ciblés identiques au RAW avant édition.

Journal AI Studio lu à l'URL fournie, Markdown extrait de `const raw` dans la réponse HTTP du lecteur public ; relu avant reprise, identique hors CRLF/LF. Il signale campagnes/WWW/AI Studio/CRM/ecommerce et `global_librairies.php`, aucun fichier ciblé du sas/roster/lookup. Aucun reload applicatif nécessaire dans ce périmètre ; aucune garantie sur les changements serveur non journalisés. Copie locale de lecture : `/tmp/cotton-paper-ai-roadmap.md`.

Au départ : Games `aa35070`, Global `4eeb704`, documentation `fc96afa4`, dépôts propres. Les correctifs17/09 sont déjà versionnés et préservés. Aucun checkout/reset/commit, SSH, DB réelle, navigateur intégré, déploiement ou restart.

## 2. Flux et identités avant/après

Avant : clic Lancer papier → sas → lecture du roster Hub actif, lookup contextualisé par la session, ajout/réactivation Hub-only → confirmation finale → commande launch_session → injection au vrai lancement.

Après : le CTA global ouvre **le même sas**, en scope Hub, sans sélectionner une carte. Le footer « Fermer » n'appelle jamais le lancement. Le parcours Lancer papier reste identique, avec les joueurs déjà présents. Les handlers `paper_lobby_players/lookup/player_add/player_remove/close` sont réutilisés ; aucune copie du service add. Le nouveau paramètre `paper_lobby_scope=hub` déclenche une résolution serveur. En scope historique, `session_id` reste accepté.

Global inchangé : `app_games_hub_player_ensure` (:5675) délègue à upsert (:5501). Identités `ep:<id_ep_player>` pour une source `equipes_joueurs`, sinon `guest:<player_token>`. Une équipe sélectionnée conserve le `p:` stable dérivé de `team:<id>` ; sa nature n'est pas persistée séparément, conformément à l'arbitrage. L'invité libre reçoit un nouveau token : il ne crée ni compte `equipes_joueurs` ni équipe `equipes`. Au lancement Quiz, il devient un participant `cotton_quiz_players`.

`app_games_hub_session_inject_active_players` (:9589) parcourt le roster Hub actif lors du vrai lancement officiel papier (:10325), sans nouvelle sélection par jeu. Une reprise d'exécution conservée retourne avant cette injection. Préparer plusieurs sessions ne duplique donc pas l'inscription Hub. Aucun mapping `games_hubs_players_sessions`, runtime player, focus, exécution, routing generation ou commande de lancement créé par la préparation.

## 3. Éligibilité et contexte technique

Calcul dans Games `games_hub_remote_paper_preparation_context`, exposé par `paper_preparation.available/uses_teams` au rendu initial et aux snapshots. Aucun calcul métier parallèle JS.

Conditions : Hub actif et non deleting, accès officiel, état temporel canonique `before` ou `open`, au moins un membre papier satisfaisant `games_hub_session_is_organizer_launchable` et `games_hub_remote_session_action(...).paper_lobby_required`. Ne pas utiliser `action.available` directement : il interdit le lancement avant ouverture, alors que la préparation anticipée doit rester possible.

La liste canonique `app_games_hub_sessions_get` sélectionne membres active, propriétaire, non démo et configuration complète ; les membres retirés sont exclus. `app_session_edit_state_get` produit pending/running/terminated, avec projection running d'une suspension conservée même à phase0. Résultat : pending éligible ; running nécessitant recréation éligible ; running/suspendue avec exécution officielle réutilisable non éligible à elle seule ; terminée, retirée, programme numérique/vide, prospect ou fenêtre close/invalid : CTA masqué. Les droits/presence Remote existants restent applicables.

Référence technique : première session éligible dans l'ordre canonique date/heure/position/id. Elle sert au propriétaire du lookup et à l'undo, sans mutation ni sélection fonctionnelle. Dès qu'un membre Quiz papier existe, la première session Quiz papier fournit le contexte de recherche équipe. Le lookup joueur Blind Test/Bingo utilise le token de la référence uniquement pour retrouver `id_client` ; il ne nécessite pas une session runtime Blind Test. Revalidation à chaque requête. Si la référence change après ouverture, add refuse la preuve d'ouverture périmée plutôt que changer silencieusement son contexte.

## 4. UX, lookup et annulation

Un CTA « Participants » dans le groupe flex existant, avant le QR ; QR Agrandir/Réduire et contrôleur inchangés. Sans éligibilité, le bouton caché libère sa largeur. Le nouveau texte peut revenir à la ligne sur largeur réduite.

Modale globale « Ajouter des participants » : « N inscrits », « Inscrits aux parties de la soirée. » / « Inscrits aux parties de l’événement. » via le resolver canonique. Sas : titre « Vérifier les participants », « N participants », « Ils seront intégrés à cette partie. ». Même toggle discret « Voir la liste ▾ » / « Masquer la liste ▴ », sans fond ni bordure, aria-expanded/aria-controls conservés. Liste repliée à chaque ouverture, sans filtre ni appel supplémentaire ; scroll interne borné min(28svh,220px). Section unique « Ajouter un participant », champ contextuel, aide courte « 3 caractères minimum. Si aucun résultat n’est trouvé, tu pourras ajouter un nouvel invité. ». Suppression des titres/labels visibles et longs paragraphes redondants ; aria-label conservé. À360px : modale336px, marges12px, champ100% border-box/min-width:0, contenu sécable. Présentation compacte aussi conservée sur desktop pour éviter deux hiérarchies concurrentes. Dans les deux modales : sous « Ajouter un participant », avant le champ, texte exact « Ajoute les participants non inscrits avec le QR code pour gérer la correction et le classement des parties papier. ». Cette phrase précède le champ ; l’aide « 3 caractères minimum… » reste sous le champ dans les deux accès. Le compteur reste contextuel à la partie. Footer global Fermer seul (croix conservée) ; footer session inchangé. Blind Test/Bingo seuls : « Joueur » et « Rechercher un joueur ». Dès Quiz papier : « Joueur / Équipe », « Rechercher un joueur ou une équipe », interrogation des deux lookups existants et liste unifiée avec type discret. Homonymes conservés séparément ; aucun rapprochement/tri par pseudo ne modifie l'identité. Maximum8 résultats par famille. Seuil3 caractères, debounce180ms et rejet des réponses obsolètes conservés.

Fallback seulement si la liste complète est vide : « Nouvel invité », y compris dans le sas historique. Une erreur d'une branche refuse la recherche complète et n'ouvre pas une création libre à partir d'un résultat partiel. Pas de création d'équipe à partir d'un nom.

Undo existant : preuve600s liée Hub/session technique/joueur/ouverture, uniquement created/reactivated ; les joueurs déjà actifs, y compris QR, restent sans bouton de retrait. Requête remove sans preuve refusée. Fermeture/réouverture efface le droit ; aucune provenance durable. Les réponses tardives d'une ancienne ouverture ne repeuplent pas la modale. Close global reste utilisable après disparition de la dernière session éligible et vérifie l'ouverture pour ne pas effacer les droits d'une ouverture plus récente.

## 5. REMO et guard commun avant mutation

Sur demande de l'utilisateur, historique local des fils relu : conversation du10/09, fichier `rollout-2026-09-10T12-52-26-01a08af2-8d6d-79f2-a66f-96a5671aed29.jsonl`, message utilisateur179. Il confirme REMO lié au compte10, invité sans identité historique ; l'audit du fil identifie le refus `USERNAME_REFERENCED`. Le problème concerne un participant historique du compte organisateur, **pas** le prénom du profil Game Master. Aucun accès DB réel supplémentaire nécessaire pour ce contrat.

Avant patch, le front masquait l'ajout libre lorsqu'il affichait des résultats, mais l'endpoint ne contrôlait pas l'historique avant ensure. Le lookup n'est pas équivalent à la réservation runtime : LIKE SQL, limites et filtres de présentation contre comparaison normalisée exhaustive de l'historique. En particulier, les emails internes `@cotton-quiz.com` sont masqués dans les suggestions joueurs, mais leurs noms restent réservés au runtime. Écart reproduit en test ; ce filtre particulier n'est pas déclaré cause certaine de REMO.

Nouveau `games_hub_remote_paper_free_guest_guard` appelé par le handler commun **avant** `app_games_hub_player_ensure`. Seulement saisie libre (absence de player_id/sourceTable/sourceId) ; les sélections historiques restent sur leur chemin existant. Réutilisation directe de `canvas_session_has_referenced_participant_name` : historique équipes Quiz, historique joueurs Blind Test/Bingo, propriétaire résolu depuis le token de session. Le global vérifie les familles recherchées ; le sas de lancement garde le contexte de son jeu.

Même normalisation runtime `canvas_participant_lookup_normalize` : minuscules, trim, décomposition Unicode si intl présent, retrait des marques combinantes, espaces regroupés. Pas de copie approximative du normaliseur Hub, qui conserve les accents. Le helper accepte un argument optionnel `failClosed=false` : la préparation le passe à true et refuse sans écriture si le contexte/lecture échoue ; les appels runtime historiques restent inchangés.

Refus409, wording exact : **« Ce pseudo est déjà utilisé sur ton compte organisateur. Choisis un autre pseudo. »** Aucune mutation roster/mapping/runtime ni émission de token undo après ce refus. Indisponibilité de vérification :503, erreur explicite, pas d'ajout partiel.

## 6. QR, identité et limites conservées

Upsert Hub refuse séquentiellement un pseudo normalisé appartenant à une autre identité active avec USERNAME_TAKEN avant UPDATE/INSERT. Une sélection d'identité déjà active retourne already_active ; une réactivation exige la même identité. Aucune association durable sur pseudo seul. Les anciens homonymes inactifs ne sont pas fusionnés.

Limite inchangée : le SELECT de collision dans upsert ne constitue pas une garantie de concurrence atomique QR/papier. Play possède son verrou spécifique, que le chemin papier ne partage pas. Aucun nouveau modèle/verrou/migration ajouté dans ce patch. Limite UI préexistante : liste du sas limitée à120 joueurs affichés ; l'injection lit tous les actifs.

## 7. Fichiers et tests

Applicatif Games uniquement :

- `web/modules/app_hub_remote_ajax.php` : contexte/éligibilité, scope des handlers, recherche unifiée, guard commun, CTA/modale et réponses tardives.
- `web/includes/canvas/php/boot_lib.php` : option de refus sur erreur dans le helper historique existant, défaut runtime conservé.

Tests ajoutés/adaptés : nouveau `web/tests/hub_paper_preparation_test.php` ; `hub_remote_polling_test.mjs`, `hub_remote_contract_test.php`, `hub_remote_paper_teams_test.mjs` ; doubles de resolver papier dans `hub_empty_commercial_test.php` et `hub_theme_renewal_display_test.php`. Aucun code Global/Quiz/Blindtest/Bingo/Master/runtime modifié.

Commandes exécutées depuis Games, toutes réussies après adaptation des doubles :

```sh
php web/tests/hub_paper_preparation_test.php
php web/tests/hub_remote_contract_test.php
node web/tests/hub_remote_polling_test.mjs
node web/tests/hub_remote_paper_teams_test.mjs
node web/tests/hub_remote_paper_confirmation_test.mjs
php web/tests/hub_session_settings_test.php
node web/tests/hub_session_settings_dom_test.mjs
node web/tests/hub_player_qr_test.mjs
php web/tests/hub_master_test_visibility_test.php
php web/tests/hub_demo_ux_contract_test.php
node web/tests/hub_demo_lifecycle_test.mjs
php web/tests/hub_demo_runtime_surfaces_test.php
php web/tests/hub_empty_commercial_test.php
php web/tests/hub_suspend_test.php
node web/tests/hub_suspend_test.mjs
```

Depuis Global :

```sh
php web/tests/hub_player_roster_registration_state_test.php
php web/tests/hub_session_test_remote_retry_test.php
php web/tests/hub_demo_mode_contract_test.php
php web/tests/hub_paper_cold_runtime_bootstrap_contract_test.php
```

75 contrôles PHP nouveaux : états/SSR, pas de mutation à l'ouverture, recherches séparées/homonymes/clés, lookup partiellement indisponible, refus historique exact avant écritures dans les deux accès, panne de lecture, saisie libre, roster commun à deux sas, répétition de sélection, undo/stale, reproduction du vrai filtre email interne contre le vrai guard runtime. PDO et mutations remplacés par des doubles, pas de DB réelle. Polling JS étendu : vrais handlers dans DOM simulé, global soirée/événement avec/sans Quiz, scope sans session_id, badges, identité sélectionnée, absence de lancement/sélection/redirection, fermeture et réponse tardive. Les suites existantes couvrent QR, confirmation finale, tests ciblés/prospects, Master et suspension/reprise. Aucun résultat de recette navigateur/SQL réelle revendiqué.

Correctif UX complémentaire : seuls le HTML/CSS/JS de présentation Remote et trois tests existants sont adaptés. Relancés avec succès : `node web/tests/hub_remote_polling_test.mjs`, `node web/tests/hub_remote_paper_teams_test.mjs`, `node web/tests/hub_remote_paper_confirmation_test.mjs`, `php web/tests/hub_remote_contract_test.php` ; `php -l web/modules/app_hub_remote_ajax.php`. Compteur, liste repliée/dépliée, footer, modes lookup, ajout, absence de lancement global et confirmation finale couverts. Complément mobile : les mêmes quatre suites ont été relancées avec succès pour les compteurs courts/toggles, lookup et confirmation ; assertions CSS statiques sur largeur360px, champ100%, retours de ligne et liste scrollable. Layout flex mobile/QR conservé ; absence d’overflow visuel non mesurée dans un navigateur, validation visuelle réelle restante. Le compteur utilise toujours la liste du payload, donc reste soumis à la limite préexistante120 : aucune extension backend dans ce correctif UX. Rollback UX : retirer seulement ces changements de présentation/tests et leurs mentions documentaires, garder le patch métier précédent.

## 8. Documentation, recette et rollback

Routing du diff Games : R11 + boot_lib/R1 et règles transversales. README/TASKS Games, TASKS Global (audit et helper inchangé), HANDOFF, CHANGELOG, bridge-contract et présente note mis à jour dans leurs blocs AUTO-UPDATE. README Global consulté mais inchangé : pas de nouveau contrat Global. Index/sitemap régénérés via `npm run docs:sitemap`, sans édition manuelle ; URLs générées et `git diff --check` vérifiés. Note encore locale tant que les docs ne sont pas publiées.

Recette DEV restante après diffusion autorisée : desktop/mobile et QR réduit/agrandi ; programme mixte, retrait de la dernière session papier, fermeture pendant réseau lent ; saisir un nom historique masqué, choisir un existant légitime, ajouter un invité, vérifier sa présence dans plusieurs sas puis son injection uniquement au lancement. Concurrence réelle QR/papier à observer, sans garantie ajoutée. Aucun déploiement/restart exécuté. Rollback : retirer uniquement ce patch Games et ses tests/docs, conserver les changements17/09 antérieurs ; aucune donnée/migration à annuler.

<!-- AUTO-UPDATE:END id="hub-paper-early-roster-audit" -->
