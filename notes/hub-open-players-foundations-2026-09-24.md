# Hub open_players — première unité locale, 24/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-open-players-foundations-20260924" owner="codex" -->

## A. Préflight

**Statut initial : V2 locale, non déployée lors de cette implémentation.** V2 ensuite déployée en DEV par l’opérateur ; première recette en échec et correctif local décrits en M. Reprise de la fondation existante, sans remise à zéro. START main, SITEMAP/README/manifest/HANDOFF develop consultés ; journal AI Studio raw consulté avant patch, aucun conflit ciblé détecté. Aucune DB/SSH/DEV/PROD, aucun navigateur intégré, aucun merge/restart/déploiement.

## B. Open branché

Le seul premier lancement officiel numérique passe au service `app_games_hub_pregame_open_locked`, après les guards historiques. Action Master `open_players` ; Remote conserve son transport launch_session et rejoint le même service. Capacité et stock restent Hub. E officielle et slot game_events unique ; même slot sain → même E, pas de nouvelle activation focus. URL Organizer explicite `hub_transition=open_players`. `hub_execution_opened` est distinct d’un lancement joué ; `hub_first_start_accepted` alimente l’historique seulement après acceptation.

## C. Focus verrouillé

Les setters focus/presentation/mode/clear prennent le verrou Hub partagé, réentrant dans la requête. B, commandes différées, quick-add et podium/idle ne peuvent réaligner la présentation d’un slot actif. Le resolver Player et l’admission service vérifient le slot. Writes HTTP sensibles sérialisés jusqu’au dispatch. Invalidation/expiration interne compare l’E ; un callback ancien ne ferme pas le slot courant. game_events seul est transactionnel, aucune promesse d’atomicité MyISAM.

## D. Organizer Hub-open

Bootstrap, store, primary et adaptateurs historiques conservés. Auto-start désactivé en contexte slot. Dialogue provisoire réutilisant le véritable bouton Play, compteur et Abandonner ; les autres contrôles sont couverts. Proof opening→open : Quiz/BT après application de l’init avec playlist utile ; Bingo après auth, hydratation et état phase zéro. Ready navigateur seul ne suffit pas. Reload du runtime conservé reprend la même incarnation ; incarnation perdue ferme l’ouverture, sans E2.

## E. Player

Resolver Hub → player_canvas → admission ciblée → register/auth WS. État neutre, attente « La partie va bientôt commencer », sans spinner, question/média/grille jouable ; erreurs visibles et retry. Projection indépendante par identité Hub/participation/E/socket après state envoyé. Rebind remplace l’ancienne socket ; son close ne retire pas la nouvelle. Perte de la socket courante décrémente. Aucun seuil et départ possible à zéro.

## F. Premier Lancer

Gardes historiques puis `HUB_PREGAME_START` au primary courant ; bridge service revalide Hub/session/E/lifecycle/focus/version, persiste starting + marqueur dans une même transaction InnoDB. ACK avant reset/intro/Play. Retries reprennent la clé stable. Preuve moteur réelle après handleStart ou playing_state consomme le slot. Crash avant confirmation conserve starting ; récupération garde l’intention, sans retour open vierge. HTTP et WS refusent les mutations durant Open.

## G. Bingo / Quiz / BT

Bingo : zéro reset à Open/Abandon ; premier reset canonique au Lancer, request_id stable issu du premier départ et idempotence existante. Reprise historique sans nouveau reset initial. Grilles/secrets/propriétaires conservés. Quiz : state neutre sans question/countdown avant départ. BT : state neutre sans média/countdown, garde contre régression nonwaiting→waiting pendant starting ; équipes inchangées/désactivées.

## H. Abandon

closing durable avant détachement ; nouvelles admissions/start refusés. Serveur diffuse ABORTED, arrête/détache runtime et sockets puis confirme cleanup. E complétée et slot closed/aborted avant libération du focus. Aucun endSession(serverLogout), suspension, résultat/podium ou reset. Reprise du cleanup et réparation après close commis mais projection focus inachevée ; un échec de stockage reste fermé aux mutations. Nouvelle ouverture uniquement explicite.

## I. Remote

Premier bouton « Lancer » ; navigation existante vers la même E. Readiness Remote après preuve serveur Open. Owner/version/E revalidés ; Start et Quit durant Open sont relayés au primary comme Lancer/Abandon. Play/Next historiques sont refusés avant départ. Ownership/takeover/secondary et générations restent historiques. Suspendue avec E réutilisable : seul libellé Reprendre→Relancer harmonisé sur instruction utilisateur.

## J. Tests

```sh
node /home/romain/Cotton/games/web/tests/hub_first_launch_contract_suite.mjs
```

14 suites : parcours prégame, reset Bingo PHP/JS, matrice lancement 155 contrôles, reprise active JS, suspension PHP/WS, temps/grâce, expiry, réconciliation papier, démo, expiration Remote, attente runtime et slot/writers. Harnais prégame : 19 scénarios sur les trois contrôleurs réels + bridge PHP + storage CAS réel, transport DB simulé. Open 0/1, double Open, stale E, reload/incarnation, compteur/rebind/old close, double Start/ACK perdu/crash, confirmation moteur, abandon 0/1, stale callback et réouverture. Les handlers WS Quiz/BT réels sont aussi soumis à la garde Open. Vérification syntaxe PHP/CommonJS/ES modules séparée.

Ce sont des preuves offline : ni connexions navigateur réelles ni concurrence MySQL multiprocessus validées ici. La recette DEV doit vérifier les temps de bootstrap, le DOM et les retours de navigation réels.

### Repères de code

- `global/web/app/modules/jeux/hubs/app_games_hub_pregame.php:192` — `function app_games_hub_pregame_open_locked`.
- `games/web/includes/canvas/php/hub_pregame.php:3` — `function canvas_api_hub_pregame`.
- `games/web/includes/canvas/core/boot_organizer.js:1755` — `await hubPregameBeforePlay`.
- `quiz/web/server/actions/wsHandler.js:558` — `case 'mainPlayerStarted':`.
- `blindtest/web/server/actions/wsHandler.js:593` — `case 'mainPlayerStarted':`.
- `bingo.game/ws/bingo_server.js:1769` — `await this.hubPregame.started`.
- `bingo.game/ws/bingo_reset.js:55` — `startsWith('HUB_PREGAME_')`.

Test statique Remote hors runner : `php /home/romain/Cotton/games/web/tests/hub_remote_contract_test.php` conserve trois écarts historiques (placement QR/aide, ordre du resolver papier, sortie Remote). Son extraction du bloc launch a été adaptée à l’alias open_players ; la garde papier reste testée avant l’appel central. Ces écarts ne sont pas masqués par les 14 suites du lot.

## K. Documentation et fichiers

HANDOFF, TASKS/README des cinq dépôts, CHANGELOG/manifest, actions/bridge/write-map/entrypoints/runbook DEV/markers et cette note actualisés dans AUTO-UPDATE. Index/sitemap générés via `npm run docs:sitemap`.

### global

- `global/web/app/modules/jeux/hubs/app_games_hub_pregame.php`
- `global/web/tests/hub_pregame_slot_test.php`
- `global/web/app/modules/jeux/hubs/app_games_hub_runtime_expiry.php`
- `global/web/app/modules/jeux/hubs/app_games_hub_suspension.php`
- `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `global/web/tests/hub_paper_resume_reconciliation_test.php`
- `global/web/tests/hub_runtime_expiry_test.php`

### games

- `games/web/includes/canvas/core/hub_pregame.js`
- `games/web/includes/canvas/php/hub_pregame.php`
- `games/web/tests/hub_first_launch_contract_suite.mjs`
- `games/web/tests/hub_pregame_bridge_fixture.php`
- `games/web/tests/hub_pregame_flow_test.cjs`
- `games/web/games_ajax.php`
- `games/web/includes/canvas/core/boot_organizer.js`
- `games/web/includes/canvas/core/session_sync.js`
- `games/web/includes/canvas/php/boot_lib.php`
- `games/web/includes/canvas/php/hub_capacity.php`
- `games/web/includes/canvas/play/play-ws.js`
- `games/web/includes/canvas/remote/remote-ws.js`
- `games/web/modules/app_hub_remote_ajax.php`
- `games/web/modules/app_hub_view_helpers.php`
- `games/web/organizer_canvas.php`
- `games/web/player_canvas.php`
- `games/web/tests/hub_active_resume_test.php`
- `games/web/tests/hub_remote_contract_test.php`
- `games/web/tests/hub_runtime_suspension_time_test.cjs`
- `games/web/tests/hub_suspend_test.mjs`
- `games/web/tests/hub_suspend_test.php`

### quiz

- `quiz/web/server/actions/hubPregame.js`
- `quiz/web/server/actions/envUtils.js`
- `quiz/web/server/actions/gameplay.js`
- `quiz/web/server/actions/hubSuspension.js`
- `quiz/web/server/actions/registration.js`
- `quiz/web/server/actions/wsHandler.js`

### blindtest

- `blindtest/web/server/actions/hubPregame.js`
- `blindtest/web/server/actions/envUtils.js`
- `blindtest/web/server/actions/gameplay.js`
- `blindtest/web/server/actions/hubSuspension.js`
- `blindtest/web/server/actions/registration.js`
- `blindtest/web/server/actions/wsHandler.js`

### bingo.game

- `bingo.game/ws/hub_pregame.js`
- `bingo.game/ws/bingo_reset.js`
- `bingo.game/ws/bingo_server.js`
- `bingo.game/ws/envUtils.js`

## L. Restant et retour arrière

Qualification fonctionnelle DEV par l’opérateur, puis UI finale et coque fullscreen uniquement. Tester chaque moteur avec deux navigateurs, perte ACK/réseau, fermeture primaire, rebind Player, reprise suspendue/interrompue, Remote et session B concurrente. Contrôler Bingo 0/0/1 reset, identité/grille identiques, et une session abandonnée toujours non jouée. L’UI reste provisoire ; aucune qualification réelle ni livraison PROD revendiquée.

Retour arrière : restaurer ensemble les fichiers applicatifs des cinq dépôts après fermeture des slots ouverts ; ne pas supprimer les marqueurs de premier départ/reset ni rétrograder partiellement un moteur avec un slot actif. Aucun schéma nouveau. Inventaire ci-dessus ; les fichiers de documentation générés sont reconstruits par le générateur.

## M. Première recette DEV et correctif local du transport proof

### Préflight et diagnostic

Préflight privé authentifié : `START.md` sur `main`, puis `SITEMAP.ndjson`, `README.md`, `DOCS_MANIFEST.md`, `HANDOFF.md` sur `develop`, note V2, interface Canvas et README/TASKS Games résolus via le sitemap. Journal AI Studio raw consulté : aucun fichier ciblé signalé plus récent côté serveur. Routing du manifest Open Players / interface bridge appliqué.

V2 déployée en DEV par l’opérateur. Hub350, client442, Quiz27972 : init moteur à13:11:30 le24/09, puis Canvas409 `HUB_PREGAME_INIT_UNPROVEN` ; abandon à13:13:36 suivi de409 `HUB_PREGAME_CLEANUP_UNPROVEN`. Aucun départ gameplay ni admission Player démontrés par ces logs. État DB actuel non consulté.

Cause : `quiz/web/server/actions/envUtils.js` fait `JSON.stringify(proof)` dans `URLSearchParams`. `games_ajax.php` reçoit une chaîne via `$_POST` ; `(array)$jsonString` ne décode pas ses clés. Le harnais antérieur transmettait directement un tableau PHP et masquait cette rupture.

### Correction et couverture

Seul code applicatif corrigé : `games/web/includes/canvas/php/hub_pregame.php`. Helper explicite partagé par publish/started/cleanup : JSON objet/tableau décodé ou tableau PHP conservé, autres enveloppes refusées par `HUB_PREGAME_PROOF_INVALID`. Preuves incomplètes : erreurs métier inchangées. Traces minimales stage/type/normalisation/clés reconnues/erreur/Hub/session/E disponibles ; valeurs de preuve, clés arbitraires et tokens exclus.

`hub_pregame_bridge_fixture.php` accepte désormais un corps formulaire, décodé par `parse_str` avant le bridge. `hub_pregame_proof_transport_test.cjs` exécute le fragment d’encodage du runtime Quiz réel, couvre publish/started/cleanup sous les deux formats, JSON invalide/scalaires, clés manquantes, absence de mutation au refus, confidentialité des traces et reprise du cleanup via le contrôleur Quiz réel. Ce trajet échouerait avec l’ancien cast. Transport réseau et DB restent simulés ; aucun navigateur exécuté.

Commandes de validation :

```sh
node /home/romain/Cotton/games/web/tests/hub_pregame_proof_transport_test.cjs
node /home/romain/Cotton/games/web/tests/hub_first_launch_contract_suite.mjs
php -l /home/romain/Cotton/games/web/includes/canvas/php/hub_pregame.php
php -l /home/romain/Cotton/games/web/tests/hub_pregame_bridge_fixture.php
node --check /home/romain/Cotton/games/web/tests/hub_pregame_proof_transport_test.cjs
node --check /home/romain/Cotton/games/web/tests/hub_first_launch_contract_suite.mjs
```

Résultats exécutés : test dédié **19/19**, suite agrégée **15/15**, syntaxes PHP/JS valides et `git diff --check` propre dans Games et documentation. Sitemap/index régénérés avec `npm run docs:sitemap`. Ces résultats restent locaux avec DB simulée.

### Slot closing : procédure avant nouvelle recette

Une nouvelle action Open ne répare pas `closing` : `app_games_hub_pregame_open_locked` et le chemin Master refusent `HUB_PREGAME_OCCUPIED`. Le contrôleur Quiz `hubPregame.restore` sait reprendre l’abandon pour **la même E** : détachement puis cleanup ; le test passe de closing à closed/aborted et libère le focus avec le transport corrigé. Cependant `hubLifecycle.restore` précède ce chemin et peut refuser une E invalide, expirée ou suspendue : pas de récupération réelle garantie sans lecture du contexte.

Lecture opérateur proposée, non exécutée :

```sql
SELECT event_id, action, session_id, payload_json
FROM game_events WHERE event_id = 'hub-pregame-350';
SELECT id, active_session_id, presentation_session_id, presentation_mode
FROM games_hubs WHERE id = 350;
```

Après livraison du bridge, si le slot est encore closing et l’E corrélée reste activable, rouvrir l’URL Organizer originale portant `hub_execution=<même E>&hub_transition=open_players` pour laisser le runtime reprendre son cleanup. Vérifier closed/aborted et focus libéré avant une nouvelle ouverture. Aucun UPDATE SQL proposé ni preuve synthétique à injecter ; si le lifecycle refuse, diagnostiquer ce refus avec le contexte réel avant réparation opérateur. L’état réel du Hub350 demeure inconnu.

### Livraison et prochaine recette

Correctif local seulement, aucun commit/déploiement/restart ; Global et moteurs inchangés dans cette passe. Fichiers Games : bridge PHP, fixture PHP, test transport, runner de suite. Retour arrière : retirer uniquement ce delta de normalisation/instrumentation et ses tests, en conservant les travaux V2 préexistants ; cela réintroduirait le défaut connu.

Après vérification/récupération du slot :

1. Open : opening → open, trace publish `proof_type=string`, `normalization=accepted`, même Hub/session/E, aucune erreur init.
2. Player : admission WS, compteur cohérent, attente sans gameplay.
3. Lancer : ACK puis gameplay, trace started acceptée, slot consommé pour cette E.
4. Sur une ouverture fraîche séparée, abandon : cleanup accepté, closed/aborted et focus libéré.

## N. Recette DEV client10 — Hub351 / Quiz27974, 24/09 à14:10

Audit des logs rechargés uniquement, sans modification applicative. Préflight privé START main puis sitemap/README/manifest/HANDOFF develop, note et TASKS Games consultés ; journal AI Studio sans mention des fichiers front ciblés.

- Games `logs/error_log:230` à14:10:19 : publish reçu comme string, normalisation accepted, quatre clés init présentes, ok=true/error=null, Hub351/session27974/E corrélée. Le correctif de transport init est observé en DEV.
- Quiz `web/server/server-logs.log`,12:10:24.425–.430Z : Remo (player5805) inscrit et lié au WS, compteur1, updatePlayers envoyé au Master. L’inscription visible correspond bien à une admission WS.
- Games `logs/error_log:264` à14:10:51 : cleanup string accepté ; logs suivants active_session_id=0. Le runtime ferme les sockets pour abandon. Aucun started/gameplay démontré sur cette tentative ; les WS_SESSION_NOT_FOUND après fermeture ne précèdent pas le blocage du CTA.

Cause front probable, incohérence reproduite localement : `core/prelaunch_check.js:2549` quitte initPrelaunchCheck lorsque isOfficialHubOrchestrated() est vrai ; `core/boot_organizer.js:1725` exclut déjà ce contexte du précontrôle de lancement. Mais `core/canvas_display.js:3166` calcule encore prelaunchRequired pour une session ouverte sans cette exclusion, puis ligne3194 désactive le bouton si waitingForPrelaunch. Exécution du fragment réel avec session ouverte en attente et prelaunch.status=untested : prelaunchRequired=true, waitingForPrelaunch=true. Le rendu prégame (`core/hub_pregame.js:31`) agit sur le même bouton et ne retire pas la classe CSS disabled posée par le renderer historique. Des rendus successifs peuvent donc maintenir/rétablir le blocage après open.

Limite : aucune capture DOM/console de cette recette ; l’état effectif prelaunch/disabled du navigateur n’est pas enregistré dans les logs serveur. Correction ciblée ensuite autorisée et appliquée localement, décrite ci-dessous. Aucun déploiement, restart ou accès DB dans cette passe.

### Correctif CTA local après autorisation

`games/web/includes/canvas/core/canvas_display.js` utilise maintenant la même autorité `isOfficialHubOrchestrated()` que le contrôleur de lancement pour exclure le précontrôle historique. En attente, la phase prégame reste bloquante pendant opening/closing ; open et starting autorisent le CTA sous réserve des guards de chargement existants. Le fallback AppConfig protège aussi le premier rendu avant réception du snapshot WS. Hors Hub, le précontrôle demeure inchangé.

`core/hub_pregame.js` synchronise propriété disabled et classe CSS, puis émet `hub/pregame-render` pour réappliquer les guards du renderer commun. Ainsi un nouveau snapshot/compteur ne déverrouille pas un support encore en chargement, et un rafraîchissement du renderer ne rétablit pas l’attente d’un précontrôle désactivé. Aucun changement moteur, transport proof, focus ou admission Player.

Nouveau test `web/tests/hub_pregame_cta_test.cjs` : exécution des fonctions réelles de rendu, du module prégame et de l’autorité Hub avec DOM/Bus simulés. Quatre cas : opening→open, compteurs successifs et closing avec cohérence CSS/propriété ; chargement conservé ; précontrôle hors Hub ; clic start attendant l’ACK corrélé avec starting réessayable. Ajout au runner `hub_first_launch_contract_suite.mjs`. Validation exécutée : `node games/web/tests/hub_pregame_cta_test.cjs`4/4 ; `node games/web/tests/hub_first_launch_contract_suite.mjs`16/16 suites ; syntaxe des deux modules JS, du test et du runner valide ; `git diff --check` Games/documentation propre. Sitemap régénéré. Aucun navigateur réel exécuté.

Livraison future ciblée : les deux modules JS Canvas. Après chargement des nouvelles ressources, refaire Open puis admission Player (CTA actif), clic Lancer (ACK puis gameplay). Retour arrière : retirer uniquement ce delta CTA et ses tests, en conservant le correctif proof et la V2 ; le blocage connu du bouton reviendrait.

## O. UX prégame Hub — confirmation de départ, correctif local

### Préflight et parcours

START main puis sitemap, README, DOCS_MANIFEST et HANDOFF develop relus via API privée authentifiée ; note V2 résolue dans le sitemap, README/TASKS Games et interfaces Canvas/actions consultés. Journal AI Studio lu et décodé : aucun fichier ciblé signalé plus récent. Aucun accès DB, SSH, navigateur intégré, déploiement ou restart.

Contrat UX : **Lancer → prégame → Démarrer le jeu → gameplay**, sur Master et Remote. Le premier clic conserve le service canonique de lancement : création/réutilisation de E, slot unique et admission automatique. L’alias HTTP `launch_session` et `open_players` rejoint déjà le même dispatcher ; le choix technique ne dépend plus du texte du bouton.

### Présentation partagée

Nouveau module Games `core/hub_pregame_view.js`, consommé par Master et Remote : panneau modal responsive, « Les joueurs rejoignent la partie… », compteur canonique WS « N joueurs prêts » sans dénominateur, « Démarrer le jeu », « Retour à la soirée ». Le Master possède un bouton propre à la surface de transition et appelle le handler de lancement existant via le Bus ; ses guards techniques sont projetés par le renderer commun. Aucun bouton ou composant visuel du lobby n’est déplacé dans le prégame. Remote relaie START/ABANDON au primary avec E/version. Opening/closing, chargements et guards serveur restent bloquants ; zéro joueur n’empêche pas le départ. Starting permet le retry prévu par V2, sans nouvelle intention métier.

Indicateur discret sur hausse du compteur : arrêt après **1,8 seconde** sans nouvelle hausse ; snapshots identiques ne prolongent pas le délai, baisse seule ne crée pas une vague d’inscription. Message calme « Les connexions sont stabilisées » : stabilité des observations, aucune affirmation exhaustive sur les joueurs éligibles. Animation désactivée pour prefers-reduced-motion, compteur aria-live ; timer purement UI, sans effet sur CTA, slot ou lifecycle. Les rebinds à compteur identique ne sont pas distinguables par ce snapshot : aucune nouvelle instrumentation moteur ajoutée.

### Surface Hub isolée (2bis/2ter/3bis)

Masquage du contenu historique dès le HTML initial lorsqu’un slot prégame officiel numérique est identifié ; backdrop opaque et dialog modal isolé. Liste joueurs, gestion du lobby et contrôles historiques restent sous le capot, invisibles et non interactifs. La vue utilise uniquement des classes `hub-pregame*` et ses propres boutons, sans composants Bootstrap/legacy. Le masquage est retiré au départ accepté/consommation du slot ; aucun handler de fermeture de page n’abandonne le slot.

Contexte fourni par `organizer_canvas.php` et `remote_canvas.php` : libellé Hub déjà résolu, jeu, titre/thème de la playlist préchargée, logo/visuel du branding déjà hydraté et variables de couleur/police existantes. Pas de nouvel appel HTTP ; Remote lit le slot canonique au bootstrap pour éviter d’exposer son lobby avant le premier snapshot WS. Modules concernés versionnés par filemtime dans les bootstraps/import maps pour éviter le mélange d’anciennes interfaces en cache. Métadonnées absentes omises, URLs d’images limitées aux chemins locaux ou HTTP(S), textes rendus avec textContent. Pas de nouvelle fiche complète, durée inventée ni refonte graphique détaillée.

Avant le premier compteur WS : « Connexion à la session… » / synchronisation ; ensuite « N joueurs prêts ». Aucune cible, fraction, pourcentage ou nombre manquant. La surface ne promet ni roster exhaustif ni livraison du state au navigateur au-delà du compteur canonique V2 déjà implémenté.

### Confirmations et erreurs

La confirmation historique du premier départ n’est plus demandée sur l’entrée Hub officielle numérique ; l’Organizer traite le prégame comme confirmation humaine et conserve les contrôles de fenêtre avant START. Papier, démo et hors Hub conservent leurs confirmations. Marqueur durable de premier départ, ACK puis preuve moteur inchangés.

L’erreur HUB_PREGAME_NOT_STARTED observée précédemment peut être provoquée par le signal audio firstClickDetected avant START. Ce signal est désormais différé jusqu’à l’ACK en contexte prégame opening/open, sans modifier l’allowlist moteur. Une erreur sans request_id correspondant ne rejette plus une demande START en attente. Double clic partage la promesse existante ; timeout et retry conservent le contrat serveur.

### Retour volontaire et retour après fermeture (6bis)

« Retour à la soirée » appelle uniquement l’abandon canonique : closing, détachement, cleanup, closed/aborted, focus libéré, retour Hub ; pas de résultat/reset. Aucun handler unload/pagehide ne déclenche d’abandon. Le maintien du runtime et sa grâce restent ceux des moteurs existants ; aucune nouvelle expiration.

Le libellé numérique repose sur les marqueurs canoniques de départ, et le retour prégame sur le slot opening/open sans first_start, session/E concordantes et runtime officiel : **Lancer** avant départ, y compris open déjà occupé ; **Reprendre** après départ réel puis suspension/interruption ; résultats existants après terminaison. Focus ou existence d’E seuls ne suffisent plus à afficher Reprendre. Papier/démo restent sur leurs chemins historiques.

Le service Global déjà en place réutilise le slot sain et l’E dans `app_games_hub_pregame_open_locked`, sans réserve supplémentaire ni START. Tests : même slot/intention/E côté PHP ; véritable fonction Quiz de déconnexion involontaire conservant runtime/roster, retour du primary et restore/initialized du contrôleur réel avec compteur conservé, puis START explicite. Perte d’incarnation serveur ou expiration restent hors promesse de reprise saine : politique V2 inchangée.

### Fichiers, validation et limites

Games uniquement : `organizer_canvas.php`, `remote_canvas.php`, `modules/app_hub_view_helpers.php`, `modules/app_hub_remote_ajax.php`, `includes/canvas/core/{hub_pregame_view,hub_pregame,canvas_display,boot_organizer,ws_effects}.js`, `includes/canvas/remote/remote-ws.js` ; tests étendus `hub_pregame_cta_test.cjs`, `hub_pregame_flow_test.cjs`, `hub_active_resume_test.php`, `hub_master_mobile_actions_test.mjs`, `hub_master_mobile_cards_test.php`. Aucun fichier moteur ni Global modifié dans cette passe.

Commandes depuis Games :

```sh
node web/tests/hub_first_launch_contract_suite.mjs
node web/tests/hub_pregame_cta_test.cjs
node web/tests/hub_master_mobile_actions_test.mjs
node web/tests/hub_launch_confirmation_test.mjs
php web/tests/hub_active_resume_test.php
php web/tests/hub_remote_contract_test.php
```

Tests locaux avec DOM/transport/DB simulés ; aucune qualification navigateur revendiquée. Suite agrégée16/16 ; test UI dédié11/11 (identité/branding, masquage du lobby, boutons propres, compteur, animation, Master/Remote, ACK/corrélation, audio, confirmations). Parcours moteurs20/20, matrice PHP164 vérifications, tests mobile et confirmations historiques valides. Syntaxes JS/PHP et diff contrôlés. Le test statique `hub_remote_contract_test.php` présente trois échecs préexistants (texte d’aide lobby, motif textuel du guard papier, sortie Remote historique), reproduits sur les sources HEAD des assertions concernées ; ils ne sont pas corrigés par ce lot UX.

### Recette DEV minimale / rollback

1. Master puis Remote : Lancer → panneau prégame ; zéro joueur autorise le départ dès open, sans popup de confirmation supplémentaire.
2. Connexions Player : compteur WS et pulsation, CTA toujours disponible ; stabilité après silence sans attente de quorum.
3. Fermer/recharger le Master sans retour volontaire, revenir au Hub : Lancer, même E/slot/compteur, aucun START automatique.
4. Démarrer depuis chaque surface sur des essais distincts : ACK puis gameplay ; double clic/retry sans second départ. Après vrai départ/suspension, Reprendre.
5. Sur une ouverture fraîche, Retour à la soirée depuis Master puis Remote : cleanup, closed/aborted, focus libéré et aucun résultat.

Livrer ensemble les modules Games de cette passe, dont le nouveau module de vue importé par les deux surfaces. Retour arrière : retirer uniquement ce delta UX et ses tests ; conserver la V2 et les correctifs proof/CTA précédents. Aucun déploiement ni restart effectué.

## P. Recette DEV client1018 — Hub353 / Quiz27976 — audit du 24/09

Audit des copies locales Games/Global/Quiz et `quiz/web/server/server-logs.log`, sans modification applicative ni accès DEV. Créneau : 16:12–16:14 Paris (14:12–14:14 UTC côté WS). E `hubexec-ff67e7883bd87b27e19a082d596357f8`, commande Remote732, Player Hub1854.

- Ouverture : `games/logs/error_log:1584` commande créée, focus appliqué, puis `:1594` publish/proof accepté à16:12:50. Le défaut INIT_UNPROVEN antérieur ne se reproduit pas dans cette trace.
- WS : `quiz/web/server/server-logs.log:26993` Organizer primary enregistré ; `:27000` initialisation En attente, puis hydratation sans joueurs et updatePlayers count0. Remote secondaire enregistré à14:12:56 (`:27015`). Aucun registerPlayer/bind Player ni départ gameplay observé pour cette session. Le compteur zéro correspond aux inscriptions WS observées.
- Admission : `games/logs/error_log:1603` et suivantes montrent les tentatives auto répétées du Player1854 ; joueur Hub reconnu. Les messages PHP agrégés sont tronqués : la réponse finale du resolver n’est pas disponible. Les HTTP200 des polls ne prouvent pas une admission métier réussie. Cause exacte de l’arrêt avant WS non établie.
- Message signalé HUB_PREGAME_NOT_STARTED : non trouvé littéralement dans ces logs. Le guard WS `quiz/web/server/actions/hubPregame.js:80` émet cette erreur pour une commande non autorisée avant START. `update_session_infos` est envoyé par le front et absent de l’allowlist ; une occurrence est tracée pendant la registration à14:12:49.503, avant fin de restauration. Les traces WS sont limitées par type/fréquence : elles ne permettent pas d’identifier avec certitude la commande effectivement rejetée. Contrairement à la recette précédente, aucun firstClickDetected observé ici ; ne pas reconduire cette attribution sans preuve.
- Le code HTTP local autorise déjà player_register pendant open (`games/web/includes/canvas/php/hub_pregame.php`) : ne pas conclure que toutes les inscriptions sont bloquées par ce guard. Parité exacte du code déployé non vérifiée.
- Les retries runtime_expired relatifs au Hub351/Quiz27974 appartiennent à l’ancienne recette ; ils ne prouvent pas une expiration de cette nouvelle E. Aucune erreur PHP Quiz pertinente sur ce créneau ; traces Global de branding présentes.

Suite ciblée : recueillir la réponse JSON complète du poll auto-admission côté Player et la commande WS accompagnant le rejet côté Organizer (type/E/phase, sans données personnelles), ou ajouter des traces serveur dédiées non tronquées. Distinguer échec d’admission et erreur d’action avant START avant correction. Audit/documentation uniquement ; aucune validation navigateur, aucun déploiement/restart. Vérification documentaire : générateur sitemap/index et git diff --check ; pas de suite applicative relancée pour cet audit.

## Q. Admission EP numérique sans historique organisateur — correctif local

**Correctif local admission EP Hub numérique (non déployé).** La réponse DEV Blind Test27977/Hub353 expose `PARTICIPANT_SOURCE_INVALID` dans `access.ensure.api`, avant URL/redirection. Le motif interne exact (historique absent, clé, contexte ou SQL) n’est pas distingué par ce code erreur ; le même refus Quiz n’est pas encore capturé. L’ensure numérique atteste désormais une identité EP Hub active via un contexte PHP interne limité à l’appel `player_register`, restauré dans finally. Les adaptateurs Quiz/BT/Bingo vérifient jeu, session, identité et clé canonique avant d’exempter cette provenance du filtre d’historique organisateur. Aucun champ navigateur n’accorde cette confiance. Capacité, lifecycle, mappings left, marqueurs de jonction, protection des pseudos invités et injection papier inchangés. Aucun changement WS, schéma ou compteur prégame. Détails et recette : section Q de la note Open Players V2.

### Preuves et portée

Capture navigateur fournie par l’opérateur : session27977, focus actif, `ok=true` au niveau poll mais `access.ok=false`, `ensure.ok=false`, reason `runtime_registration_failed`, API `PARTICIPANT_SOURCE_INVALID`, aucune play_url. L’échec se produit dans player_register, pas dans le WS ni dans le renderer prégame. Le validateur d’identité source et son branchement aux adaptateurs apparaissent dans le commit Games b9f55da1 du21/09. Ce validateur vérifie l’historique client pour une sélection d’identité ; l’ensure Hub numérique déjà validé ne doit pas exiger cet historique. Le correctif est autorisé indépendamment du sous-motif exact de cette capture. Aucune preuve de déploiement déduite du Git local.

### Modification

Global : `web/app/modules/jeux/hubs/app_games_hubs_functions.php` fournit `app_games_hub_digital_player_admission_context` uniquement autour du dispatch numérique pour une identité EP active appartenant au Hub de l’ensure. Papier et identité non éligible ne créent pas cette attestation ; une valeur extérieure est masquée puis restaurée après l’appel, y compris sur exception. Les guards et l’ensure métier existants restent en place.

Games : `web/includes/canvas/php/{quiz,blindtest,bingo}_adapter_glue.php` vérifient contexte interne, IDs positifs, jeu/session, source EP et clé canonique concordante. Seule cette provenance serveur est exemptée du contrôle d’historique. Sélection distante non prouvée, substitution d’identité, protection des noms invités et contexte papier existant conservés. Aucun payload ni nouvelle autorisation HTTP ; aucun contexte transmis au navigateur. Les écritures de mapping/participation et leur idempotence ne sont pas modifiées.

### Tests et livraison

`php web/tests/hub_digital_ep_admission_test.php` : 115 vérifications cumulées, avec validateur et fragments de production, PDO simulé sans connexion. Inclut absence d’historique, trois adaptateurs, contexte navigateur forgé, substitutions jeu/session/source/clé/IDs, exclusion left/papier/autre Hub pour l’attestation numérique, nettoyage/restauration sur exception ; réexécute les protections papier/identité/pseudo existantes. Ces tests ne prouvent pas un bind navigateur réel. Syntaxes PHP et diff contrôlés ; suite V2 agrégée `node web/tests/hub_first_launch_contract_suite.mjs` : 16/16 suites réussies (fixtures offline, sans DB ni navigateur).

Livrer ensemble les quatre fichiers applicatifs ci-dessus. Le test reste local. Aucun moteur WS modifié, aucun restart effectué. Recette opérateur : EP sans historique → poll access.ok=true et play_url → Player Canvas → bind WS → compteur ; retry conserve participation/mapping, invité avec pseudo EP réservé et identité falsifiée restent refusés. Papier et left à recontrôler. Risque : exemption d’un contrôle d’identité, bornée au contexte interne concordant ; rollback limité à ce delta sur les quatre fichiers, sans retirer les changements V2 antérieurs. Note, README/TASKS Games et Global, interfaces, HANDOFF/CHANGELOG actualisés, sitemap/index par générateur.

## R. Recette après correctif EP — Hub353 / Blind Test27977

Déploiement et nouveau test confirmés par l’opérateur. Copies Games et WS Blind Test rechargées pendant le diagnostic. Nouvelle E `hubexec-a40eb0e2096967f459486cd4ef584f58` : publish accepté à17:16:39 Paris (`games/logs/error_log:3729`). Ne pas confondre avec l’E Quiz initiale ni les ouvertures/abandons intermédiaires.

Chaîne Player1854 désormais démontrée : GET `/play/blindtest/[token masqué]` HTTP200 à17:16:45 (`games/logs/access_log:7998`, paramètre hub_player_id1854), identité1854 et mapping2379 actif retrouvés par Player Canvas (`error_log:3744`), puis bind WS à15:16:46.624Z =17:16:46.624 Paris (`blindtest/web/server/server-logs.log:18241`), participation221319. La clé canonique de ce bind correspond à celle de l’ensure en échec fourni précédemment, comparaison locale sans publication de la clé.

Le compteur session passe de1 à2 à17:16:46.625 (`:18242`) et updatePlayers est envoyé aux organisateurs (`:18245`). L’autre participation221318 était déjà liée ; son rebind à17:16:51 n’est pas Player1854 et ne doit pas être interprété comme une deuxième identité de ce joueur. Aucune preuve START dans cette dernière séquence fournie. Le résultat ensure brut et la décision JS ne sont pas capturés, mais mapping/navigation/bind prouvent que l’ancien blocage avant Player Canvas est levé sur ce test BT.

Limites : SESSION_PLAYER_COUNT/updatePlayers ne sont pas une capture du compteur `HUB_PREGAME_STATE` ni du rendu navigateur. Le compteur visuel prégame reste à confirmer, ainsi que Démarrer/Retour et retour sur même E. Les logs WS Quiz locaux restent arrêtés à16:14:47 Paris : aucune qualification Quiz après correctif. L’erreur Organizer HUB_PREGAME_NOT_STARTED reste un sujet distinct, non expliqué par le refus PHP corrigé.

Audit seulement, aucun nouveau code ni restart/déploiement par Codex. Note, HANDOFF et TASKS Games actualisés ; sitemap/index régénérés. Prochain contrôle opérateur : Player1854 visible en attente, compteur prégame correspondant aux binds, puis START humain ou abandon sur essais distincts ; même recette Quiz à capturer.

## S. UX prégame et synchronisation parasite avant START

**Passe UX prégame locale, non déployée :** Master/Remote partagent « La partie va bientôt commencer » et « Prépare-toi à jouer ! ». Master borné au viewport sans scroll, visuel/espacements réduits selon la hauteur ; Remote compact. Halo renforcé sur arrivée WS, compteur « N joueur(s) ont rejoint la partie » avec accord, messages calmes propres au jeu, sans cible ni blocage START. Retour soirée/événement en lien discret ; START légèrement souligné au calme. Player : bouton Réessayer retiré, polling/navigation/reconnexion existants conservés. BT27977 : update_session_infos paperMode=false observé en open à17:16:45.458, rejet reproduit par le guard réel ; synchronisation Organizer différée jusqu’à l’ACK START, dernières valeurs fusionnées et limitées à E. Code brut HUB_PREGAME_NOT_STARTED traduit en attente normale sur les trois surfaces ; autres erreurs maintenues. Aucun changement ensure/mapping/moteur/lifecycle. Détails, tests et limites en section S de la note V2.

### Diagnostic de la commande

Dernière E BT27977 : publish PHP accepté à17:16:39, puis `blindtest/web/server/server-logs.log:18224` montre WS_IN Organizer `update_session_infos` avec paperMode=false à15:16:45.458Z. L’émission initiale à15:16:39.785 précède la fin de registration ; la seconde se produit après open. `core/ws_effects.js:pushPaperParamsNow` produit ce payload, appelé par options/updated, ws/registered et ws/open:debounced. Les logs n’identifient pas lequel de ces callbacks a produit la seconde émission et ne journalisent pas la frame ERROR elle-même ; le guard réel BT rejette déterministement cette commande en open, reproduit dans le test. Aucun lien causal avec l’ancien refus PHP d’identité.

Le front diffère update_session_infos sous autorité Hub officielle opening/open, conserve les dernières valeurs par E et les envoie une seule fois sur hub/pregame-started (émis après ACK). Abandon annule l’attente ; une autre E ne récupère pas l’ancien payload. Aucun changement de l’allowlist moteur ni de la décision START. Papier/démo/hors Hub sans ce contexte restent immédiats. Les autres erreurs continuent d’être affichées ; la traduction du seul code NOT_STARTED est une protection résiduelle, pas une levée de guard.

### Présentation et fichiers

La vue isolée conserve branding/contexte/session et boutons propres. Sous-titre au-dessous du titre, compteur mis en évidence par bordure/halo et légère variation d’échelle quand count augmente. Le debounce UI existant de1800ms et la détection de binds restent inchangés ; reduced-motion retire les animations en conservant le signal statique. Aucun quota, cible ou nouveau timeout métier. Le libellé calme ne prouve pas une population complète.

Games : `web/includes/canvas/core/{hub_pregame_view,hub_pregame,ws_effects}.js`, `web/includes/canvas/remote/remote-ws.js`, `web/includes/canvas/play/play-ws.js`, `web/player_canvas.php` (version du module Player par filemtime pour éviter une ancienne copie avec bouton retry). Test `web/tests/hub_pregame_cta_test.cjs` étendu. Aucun fichier Global ni moteur modifié dans cette passe ; le correctif EP précédent est conservé.

### Ajustement écran externe et Remote

Master : dialog en grille, hauteur bornée à min(850px, viewport−24px), 100vh et 100dvh, débordement page/dialog bloqué ; espace branding flexible, visuel réduit d’abord, typographies et espaces selon hauteur, paliers600/420px. Sur très faible hauteur les images cèdent la place aux textes et contrôles. Remote : carte compacte, grand visuel retiré, mêmes textes et actions. Compteur : « 1 joueur a rejoint la partie » / « N joueurs ont rejoint la partie ». Le compteur garde sa source WS ; aucun changement de calcul. État calme : artistes/oreille pour BT, questions/pièges pour Quiz, morceaux/grilles pour Bingo ; halo START statique léger, aucune auto-action. Retour souligné, transparent et contextuel, intitulé d’abandon explicite au survol. gameSlug fourni depuis les données PHP déjà présentes ; contextType déjà canonique.

Fichiers supplémentaires de cet ajustement : organizer_canvas.php et remote_canvas.php pour gameSlug ; vue partagée, contrôleur Master et Remote pour présentation/wording résiduel ; test CTA. Aucun ajustement métier ni moteur. Tests UI désormais16/16 ; syntaxes PHP et JS/diff valides. Pas de navigateur intégré : l’absence de débordement et la lisibilité restent à vérifier visuellement à1920×1080,1366×768,1280×720,1024×600 et laptop à zoom usuel, avec branding/titres longs. Ne pas présenter les assertions CSS/DOM comme une mesure réelle de layout.

### Validation et recette

Tests UI avec DOM/horloge simulés : wording, zéro, arrivée/retour calme, CTA indépendant, Remote, suppression du bouton Player, traduction sans suppression des autres erreurs. Test producteur/guard BT réel : rejet avant START, aucune émission avant ACK, fusion dernière valeur, émission après ACK, abandon et parcours historique. Le polling Hub et sa redirection automatique sont inchangés, vérifiés par inspection ; pas de preuve navigateur supplémentaire ni de validation graphique intégrée.

Commandes : `node web/tests/hub_pregame_cta_test.cjs`, `node web/tests/hub_first_launch_contract_suite.mjs`, syntaxe modules JS/PHP et git diff --check. Résultats : 15/15 tests UI, 16/16 suites V2 ; syntaxes et diffs valides. Recette DEV à faire : ouvrir depuis Master puis Remote, vérifier titre/sous-titre, arrivée de joueurs/halo/retour calme, START à zéro possible ; Player attend et rejoint automatiquement sans bouton, sans code brut. Vérifier retour volontaire et reload même E. Aucune livraison/restart effectuée ; rollback limité au delta de cette section, sans retirer le correctif EP ni la V2 précédente. Documentation HANDOFF/README/TASKS Games/actions/CHANGELOG actualisée, sitemap/index régénérés.

## T. Compteur regroupé et départ automatique — 24/09/2026, local non déployé

Contrat courant, remplaçant les seuils3s/1,8s/12s puis5s/2,5s/15s des passes précédentes : minimum5s depuis open réellement accepté ; aucun bind encore observé → grâce10s puis départ ; au moins un bind observé →5s entières sans nouveau bind, sous réserve du minimum. Aucun plafond normal. Une vague peut durer plus de30s. Watchdog exceptionnel90s pour éviter une attente technique indéfinie ; trace explicite, même START canonique et idempotent. Zéro joueur est valide ; aucun quorum/roster attendu. CTA déjà supprimés dans la passe précédente : aucune reprise de leur layout. Seul le retour volontaire reste visible.

Préflight relu avant modification : dépôt privé cotton-games/documentation, START.md/main puis SITEMAP.ndjson, README.md, DOCS_MANIFEST.md (Open Players V2 / Server restart markers) et HANDOFF.md sur develop, via API Contents authentifiée. Point d’entrée exact : https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=main ; manifest : https://api.github.com/repos/cotton-games/documentation/contents/DOCS_MANIFEST.md?ref=develop. Journal AI Studio brut relu depuis le lien du START ; aucun conflit ciblé identifié. Les modifications locales antérieures restent conservées.

### Compteur et effet historique de paquets

Dans Quiz `web/server/actions/registration.js` (`PLAYER_LIST_INTERVAL_MS`, `schedulePlayerListUpdate`, appel depuis `registerPlayer`) et Blindtest au même chemin, le roster historique est publié au maximum une fois par seconde : première publication immédiate si la fenêtre est écoulée, puis un seul timer pour regrouper les arrivées suivantes. L’hydratation DB peut aussi restituer plusieurs lignes d’un coup, sans prouver leur connexion. Cette explication est établie pour Quiz/BT ; aucune généralisation du throttle à Bingo n’est revendiquée.

Le compteur pregame conserve les identités distinctes de la même E effectivement liées à un socket ouvert. Il ne compte ni mappings PHP seuls ni roster historique. Sa publication WS reste inchangée. Master/Remote présentent un grand nombre central, légende fixe dessous avec accord singulier/pluriel ; seul le nombre porte l’animation d’activité. Les changements visuels sont regroupés par fenêtres fixes de250ms (dernière valeur reçue), sans retarder indéfiniment l’affichage sous flux continu. La fermeture annule le timer ; reduced-motion conserve un signal statique. Cette agrégation n’alimente jamais le départ.

### Décision serveur et START canonique

Les trois contrôleurs identiques appliquent `nominal = aucun_bind ? open+10000 : max(open+5000, dernier_bind+5000)`, puis `échéance = min(nominal, open+90000)`. L’instant local de publish accepté préserve le minimum malgré la précision à la seconde de opened_at. lastArrival=null distingue « jamais de bind » de « compteur revenu à zéro ». Déconnexion seule, doublon, remplacement d’un socket encore connecté ou preuve d’une autre E ne prolongent pas le calme. Une reconnexion effective après déconnexion le prolonge. Les participations/mappings et l’affichage ne participent jamais au calcul.

À échéance, message HUB_PREGAME_AUTO_START au primary courant, execution_id/version et reason empty_grace/quiet/watchdog. En open, le Master passe par ui/play et START/ACK/guards existants. Delivery retry au plus1Hz jusqu’à acceptation. Watchdog : logs JSON sans données personnelles, event hub_pregame_auto_start, stage requested puis start_accepted, reason watchdog, E/phase/version. requested atteste le signal ; start_accepted atteste l’intention durable, pas une preuve de gameplay. Pas de trace d’acceptation sans succès PHP. Les retries de livraison ne créent pas de seconde intention ; la sérialisation et le premier START durable restent canoniques. Le watchdog ne contourne pas un primary absent ou un refus métier.

Audit ACK : l’ancien timeout rejetait la promesse et une nouvelle tentative générait un UUID différent ; en starting, les signaux automatiques serveur étaient déjà arrêtés. Le front retente désormais toutes les15s avec le même request_id `hub-pregame-start:<E>`, la même promesse pending et la version courante. ACK arrête le timer ; erreur explicite/abandon l’annulent. Une remontée starting ou runtime-ready après reload reprend le même START/ACK avec ce même identifiant, sans nouvelle E ni second événement durable. Le départ conserve la preuve moteur réelle ; ce changement ne touche pas les protocoles auth/register ni le retry Player.

Reload du primary dans le même runtime/E conserve la deadline. Une incarnation perdue suit toujours l’abandon canonique existant. Abandon accepté annule le timer ; les opérations concurrentes restent sérialisées par le contrat existant. Papier/démo/hors Hub ne passent pas par ce contrôleur officiel.

### Fichiers, validation et livraison

Delta applicatif : Games `web/includes/canvas/core/hub_pregame.js` et `hub_pregame_view.js`, `remote/remote-ws.js` avait été modifié dans la passe précédente et reste inchangé dans cet ajustement ; Quiz/Blindtest `web/server/actions/hubPregame.js` ; Bingo `ws/hub_pregame.js`. Markers locaux des trois moteurs incrémentés à `restart 24-09-2026/04`, conformément au manifest ; aucun redémarrage exécuté.

Tests Games : `hub_pregame_autostart_test.cjs` nouveau, `hub_pregame_cta_test.cjs`, `hub_pregame_flow_test.cjs` et runner `hub_first_launch_contract_suite.mjs` adaptés. Le test historique du départ manuel gèle les timers pour conserver sa portée.

Tests auto-start :37/37, douze scénarios par moteur et contrôle d’identité des trois implémentations. Zéro : aucun signal avant10s puis empty_grace. Un bind dès open : minimum5s ; ouvertures retardées20s sans consommation du minimum ; premiers binds3s/4,9s puis calme5s. Vagues10/50/200/5000 étalées de4,5s à40,5s, aucun départ à15s ni30s, signal à45,5s. Vague discontinue4s/7s/11,9s →16,9s (arrivées strictement espacées de moins de5s). À la frontière exacte5s, le traitement d’un bind et celui du timer suivent l’ordre des événements serveur. Watchdog : activité chaque seconde jusqu’à89s, aucun signal avant90s, raison/traces watchdog et un seul START durable malgré doublons. Reload, absence/retour primary, abandon, E périmée et rebind couverts.

UI20/20 : absence du CTA et CSS dédié, retour soirée/événement Master/Remote, compteur/agrégation indépendante, wording, ACK perdu/renvoyé sous même request_id, reload starting et abandon annulant le retry. Les tests DOM/CSS attestent les contraintes déclarées de viewport, pas une mesure de layout réelle. Aucune qualification navigateur ni charge réseau réelle revendiquée.

Master : « La partie va bientôt commencer » / « On réunit tout le monde, prépare-toi à jouer ! ». Remote : « Les joueurs rejoignent la partie » / « Le jeu démarre automatiquement dès que les arrivées se calment. ». Remote : nombre et légende joueur connecté/joueurs connectés. Gros nombre/légende Master, ambiance et retour léger conservés ; aucun message demandant de cliquer pour démarrer. Le timeout ACK indique une attente du serveur sans demander de cliquer sur un bouton absent. Master conserve sa grille bornée au viewport sans scroll, réduction du visuel/espacements et compteur réduit sur très faible hauteur ; le retour reste dans le flux visible. Qualification graphique réelle restant à faire.

Vérification : `node web/tests/hub_first_launch_contract_suite.mjs` depuis Games (résultat :17/17 suites réussies), syntaxe et git diff --check. Recette DEV opérateur restante : les trois jeux, Master/Remote, zéro et fortes vagues de bots réels, same-E reload, abandon avant échéance, absence/reconnexion primary et START unique ; mesurer les délais et la lisibilité sans scroll. Aucun déploiement ni restart par Codex.

Livrer de façon cohérente les cinq fichiers applicatifs de cet ajustement et les trois markers ; prise en compte WS par l’opérateur lors d’un redémarrage ultérieurement autorisé. Rollback : retirer uniquement ce delta dans les cinq fichiers, en conservant les correctifs précédents, restaurer également le contrôleur Master et le wording Remote précédents, puis suivre la procédure habituelle de marker/restart autorisé ; retour à la passe précédente (5s/2,5s/15s, CTA toujours absents) en annulant seulement cet ajustement. Aucune migration, configuration, donnée ou route PHP nouvelle.

## U. Recette Bingo client1018 — Hub353 / session27981 — audit des logs rechargés

E `hubexec-2492e71906410d0202b481231f4a5cea`, playlist moteur17116. Horaires ci-dessous Europe/Paris (WS UTC+2). Aucun patch applicatif dans cet audit.

-18:59:33 : publish accepté, Games logs/error_log:11822 (ok:true). Organizer AUTH_OK à18:59:33.409 puis appel pregame réussi à33.496, Bingo ws/server-logs.log:21298–21299.
-18:59:36.741 : première erreur observée de cette séquence, hub_pregame HTTP409 hub_busy (WS:21304).
-18:59:39.363 : bingo:reset refusé HTTP409 hub_pregame_not_started (WS:21310–21311), event_id hub-first-start-7c09ebe59807316129a73362a81df4ef5b276bc083c7a515. Un event_id de première intention est présent ; les logs ne capturent pas directement la frame START/ACK ni le slot au moment du rejet. Le code Bingo associe cet event_id au reset en phase starting (bingo_server.js:1509).
-18:59:40.516 : premier PLAYER_WS_BOUND (WS:21333), donc l’ancien blocage avant Player Canvas n’explique pas cette recette. Jusqu’à19:00:51.177 :28 événements de bind pour22 player_id distincts, incluant reconnexions et redémarrage ; ne pas assimiler à28 joueurs prêts simultanément.
-18:59:40–19:00:33 : player_register/grid_assign/grid_hydrate refusés ponctuellement avec hub_pregame_not_started (Games:11855,11869,11875,11925,11943,11955,11964–11965,11998,12002,12030,12062,12067,12084,12092). La présence de binds prouve que certains Players passent, pas que toutes les admissions réussissent.
-19:00:28.592 : WS_SERVER_START (WS:21525–21526), donc observation interrompue par un redémarrage. À19:00:45.644 : WS_SEND_NO_PRIMARY_ORGANIZER (21612), puis Organizer AUTH_OK à49.383 (21659). Dernière ligne WS à51.177. Aucun gameplay réussi attesté dans cette fenêtre.

Cause établie par code local : canvas_hub_pregame_apply retourne HUB_BUSY si app_games_hub_delete_lock_acquire échoue (games/web/includes/canvas/php/hub_pregame.php:53). Ce verrou est GET_LOCK(...,0), donc sans attente (Global app_games_hubs_functions.php:3902). Chaque restore d’auth Bingo appelle la lecture pregame et prend ce même verrou (bingo_server.js:3758). Autre point établi : canvas_hub_pregame_write_blocked retourne true aussi lorsque ce verrou est indisponible (:124) ; boot_lib.php:191 traduit indistinctement ce true en HUB_PREGAME_NOT_STARTED. Les admissions et hydratations neutres sont pourtant autorisées en open (:134).

Déduction : contention du verrou pendant les arrivées fortement étayée ; le code mélange refus technique de verrou et refus lifecycle. Hypothèse restante : le reset a pu être refusé par contention alors que l’intention START était déjà acceptée. Non démontré pour cette requête : slot/version, raison interne exacte du guard et détenteur du verrou absents des traces. Ne pas retirer le guard ni modifier ensure/mapping sur cette seule hypothèse.

Le reset est tenté environ5,9s après publish et avant le premier bind journalisé : incompatible avec une validation du scénario sans bind/grâce10s du dernier contrat. Origine précise de cette tentative, version effectivement chargée front/WS et raison auto-start ne sont pas attestées ; ne pas conclure à un défaut du timer90s. Aucun signal/traces watchdog exploitable trouvé dans cette fenêtre, interrompue avant90s depuis open.

Suite ciblée : distinguer dans les traces du guard lock_busy/phase_blocked/event_id_mismatch (sans secrets), relever stage start/slot/version et raison du signal auto-start, vérifier les versions effectivement chargées et refaire une recette sans restart pendant open. Le détenteur concurrent exact reste non trouvé. Ne changer ni admission ni lifecycle sans cette distinction. Audit uniquement ; aucun test applicatif relancé, aucun déploiement/restart par Codex. Documentation note/HANDOFF/TASKS Games+Bingo et sitemap/index actualisés.

## V. Complément logs Blind Test sur Hub353 — client1018

La recharge suivante étend les preuves PHP : Bingo27981 atteint finalement started accepté à19:02:34 (Games logs/error_log:12578, même E2492…). La section U décrit uniquement la première capture, limitée côté WS à19:00:51 : son absence de preuve gameplay ne vaut pas échec définitif. Le reset initial refusé et la contention observée restent établis ; la récupération ultérieure ne démontre pas leur cause précise.

Blind Test27982, E `hubexec-09c06afad94e90dbbb05f6e419b9bcfb` :

-19:02:53 : publish accepté (Games logs/error_log:12627).
-19:02:55.564 : premier bind (Blindtest web/server/server-logs.log:19193).
-19:03:11.787 :29e bind, fin de la première vague (19476).
-19:03:16.970 : update_session_infos, puis firstClickDetected16.975 (19484–19488) ; indices du chemin post-ACK, pas de frame ACK explicitement journalisée.
-19:03:17.009 : premier état En cours (19491),5,222s après dernier bind et environ24s après publish. Cohérent avec calme5s et retrait du plafond15s ; raison du signal et timestamp START exact non journalisés, donc qualification temporelle partielle.
-19:03:18.220 /19.035 /19.253 : trois binds supplémentaires après le premier état En cours (19500,19514,19526) ; les late joiners continuent d’arriver.
-19:03:30 : preuve started acceptée (Games:12755), TRACK_START_SIGNAL_RX30.251 puis WS_GAME_COUNTDOWN_START30.256 (Blindtest:19554–19556). Gameplay effectif attesté, environ13,2s après le premier état En cours ; ne pas attribuer ce délai supplémentaire au timer pregame sans preuve.
-19:03:31.316 : compte à rebours en pause (19559).

Aucun hub_busy ni rejet NOT_STARTED retrouvé dans la fenêtre Blind Test analysée. Les28 binds Bingo et32 binds BT sont des événements de la fenêtre, à distinguer du compteur pregame courant. Le compteur historique Bingo31 après hydratation ne constitue pas une mesure de ses binds pregame. Conclusion : BT atteint le gameplay et le timing de sortie pregame est compatible avec le contrat ; Bingo montre une contention initiale puis une récupération tardive. Le watchdog90s et le cas zéro joueur ne sont pas qualifiés par ces recettes. Aucun nouveau patch, déploiement ou restart effectué. Prochaine investigation : raison structurée du rejet reset Bingo et délai entre premier En cours et démarrage du média BT.

## W. Nouvelle recette Bingo après stabilisation serveur — client1018 / Hub353

Session27983, playlist17117, E `hubexec-9384c39a09630637491a2976799c0222`. Horaires Europe/Paris. Cette recette distincte ne remplace pas les preuves des sections U/V.

-19:06:26 : publish accepté (Games logs/error_log:13143).
-19:06:26.788 : Organizer AUTH_OK (Bingo ws/server-logs.log:21951).
-19:06:32.521 /34.519 /39.627 : trois hub_pregame HTTP409 hub_busy (21980,21994,22046), suivis d’AUTH_FAIL ; contention encore présente sans restart pendant cette fenêtre.
-19:06:32.807 : premier bind (21988).
-19:06:48.211 :13e bind, dernier de la première vague (22154).
-19:06:53.834 : SESSION_RESET réussi (22162), event_id hub-first-start-228ad11abf8261c4de08348af100e9d5ff0ae7848842a630 ;5,623s après ce dernier bind. Le reset survient environ27s après authentification Organizer : pas de plafond15s observé.
-19:06:54 : started accepté côté PHP pour la même E (Games logs/error_log:13337).
-19:06:54.101 et ensuite : binds tardifs ;29 événements de bind pour29 identités distinctes au total dans la capture, dernier19:07:34.015 (Bingo:22331). Ne pas confondre effectif cumulé et compteur instantané.
-19:07:06.254 : TRACK_START (22215), soit12,420s après reset. Le gameplay est attesté ; ce délai média post-reset n’est pas le délai de calme pregame.

Aucun WS_SERVER_START dans la fenêtre19:05→19:07:36.906. Auto-start observé compatible avec5s de calme ; timestamp/reason du signal START non directement journalisés. Pas de qualification du watchdog ni du cas zéro à partir de cette recette.

Anomalie persistante et distincte :32 refus (15 grid_assign,7 player_register,8 grid_hydrate,2 grid_cells_sync). Games journalise des BINGO_REGISTER_ACTION_REJECTED hub_pregame_not_started sur player_register/grid_assign/grid_hydrate et grid_cells_sync, avant ET après started accepté (par exemple13342 à19:06:54 ;13398 à19:07:09 ;13406 à19:07:10 ;13554 à19:07:41). Cela exclut d’interpréter systématiquement ce code comme « gameplay jamais démarré ». Le code local du guard retourne true sur verrou indisponible avant même lecture du slot ; les trois hub_busy établissent des échecs d’acquisition. Contention comme origine des refus NOT_STARTED fortement étayée, mais sans motif interne par requête on ne peut pas attribuer chacun des refus au verrou ni identifier son détenteur exact.

Conclusion : nouvelle recette réussie pour départ/reset/gameplay et late joins ; anomalie d’accès concurrent au verrou et diagnostic de guard subsistent. Aucun changement ensure/mapping/admission/timer justifié par ces seules traces. Étape ciblée restante : discriminer lock_busy / phase / event_id dans le guard et tracer stage/version du slot pour démontrer chaque branche avant correctif. Documentation seule modifiée, pas de tests applicatifs nécessaires ; aucun patch, déploiement ni restart effectué.

## X. Régression suspension Blind Test27984 — 25/09/2026 matin

Client1018, Hub353, E `hubexec-5059f862f8adda5fd0396beee9a55384`. Préflight privé START main → SITEMAP/README/manifest/HANDOFF develop et journal AI Studio brut relus le25/09 ; aucun passage récent ciblé pregame/suspension trouvé dans le journal. Audit et reproduction locale uniquement.

Chronologie Europe/Paris : publish accepté08:11:22 (Games logs/error_log:314), bind Player08:11:25, état En cours08:11:30.446 (Blindtest web/server/server-logs.log:19681). Aucun mainPlayerStarted/track start ni proof started dans la capture matinale. À08:11:41, HUB_SUSPEND_REQUESTED trigger master_button/surface master (Games:334). Trois échecs Canvas hub_lifecycle HTTP409 errCode hub_pregame_focus_locked à08:11:41.646,08:11:49.110,08:11:58.573 (Blindtest:19695,19699,19703). Aucun hub_busy trouvé dans cette fenêtre ; ce refus est distinct de la contention Bingo des sections U/W.

Chaîne de cause localisée : hubLifecycle.js.suspend appelle validate → pause → suspend durable → envoi HUB_SUSPEND_ACK → release. Canvas hub_lifecycle.php:69–75 appelle app_games_hub_focus_clear au stage release. Le patch pregame enveloppe désormais cette fonction dans app_games_hub_pregame_projection(...,0,'clear',...). La fonction app_games_hub_pregame_focus_allowed n’autorise pas ce clear pour un slot actif ; active inclut starting. Ce wrapper est ajouté dans le diff Global par rapport à HEAD ; le corps historique devient focus_clear_locked sans ce guard auparavant.

Blindtest wsHandler.js:593–595 ne clôture le pregame via started que lorsque mainPlayerStarted prouve le départ moteur. L’état En cours ne constitue pas cette preuve. Ainsi, START accepté mais média non encore parti laisse starting actif et le nouveau guard empêche la libération historique du focus lors de la suspension. État starting déduit du chemin et des traces, pas d’une lecture DB directe. Le refus release explique une suspension partielle : le chemin persiste suspended avant cette erreur ; ne pas traiter l’UI en erreur comme preuve que rien n’a été enregistré. L’ACK lui-même n’est pas journalisé dans cette capture.

Reproduction locale sur code réel : appel PHP du helper focus_allowed avec slot opening/open/starting puis closed → false/false/false/true pour un clear. Contrôleur réel hubLifecycle avec transport simulant le refus release observé → appels validate,pause,suspend,release ; émissions HUB_SUSPEND_ACK puis HUB_SUSPEND_ERROR ; suspended=true,released=false. Aucun runtime/DB réel touché. Le test ne prétend pas lire l’état persistant DEV ; il démontre l’enchaînement du code face à cette réponse. Le scénario intercontrat « START accepté, média non parti, suspension immédiate » manquait aux validations précédentes malgré leurs suites vertes.

Correctif à cibler : intégrer la suspension canonique d’une même session/E après START accepté au guard de projection et à la conservation/reprise du slot, avec preuve serveur de suspension et idempotence. Vérifier aussi le lancement d’une autre session après libération et la reprise de l’ancienne ; ne pas se contenter d’autoriser clear tout en laissant un slot actif verrouiller le Hub. Préserver opening/open, protection contre changements de focus arbitraires, même E/intention START, absence de faux gameplay et comportement papier/démo. Ne pas forcer started/playing pour contourner le refus. Cette passe établit le diagnostic ; aucun patch métier ni modification du contrat demandé.

Contenu du lot : note V2, HANDOFF et TASKS Global/Games/Blindtest mis à jour, index/sitemap régénérés. Aucun déploiement/restart, aucun SQL ni patch applicatif. Suite : correction ciblée avec scénario de suspension pendant starting, après gameplay et reprise, séparée du chantier lock_busy Bingo.

## Y. Cause structurelle des hub_busy Bingo — audit approfondi25/09

Le verrou concerné est games_hub_delete_<hub_id>, donc games_hub_delete_353 pour la recette, commun à l’ensemble du Hub et acquis avec GET_LOCK(...,0), sans attente (Global app_games_hubs_functions.php:3893–3915). Le patch pregame ajoute son acquisition dans les lectures du bridge hub_pregame (Games hub_pregame.php:53), les projections et le guard des écritures Canvas.

Cause démontrée dans le code : canvas_hub_pregame_write_blocked prend le verrou AVANT la lecture du slot, même si le slot est absent, concerne une autre session ou est closed/started. Ces cas font continue sans libération immédiate. game_api_dispatch conserve ce verrou pendant tout le handler et ne le libère que dans finally (boot_lib.php:183–209). Une opération grid_assign maintient ainsi le verrou Hub pendant résolution identité/session, recherches SQL et transaction d’attribution de grille (bingo_adapter_glue.php:2156–2270). Les autres handlers protégés, notamment player_register/grid_hydrate/grid_cells_sync, prennent le même verrou. Aucune durée effective de possession n’est instrumentée : ne pas confondre les31–44ms des appels refusés avec la durée du détenteur.

Amplification Bingo : chaque auth Player numérique appelle restoreHubRuntime (bingo_server.js:897), qui relit le lifecycle puis le pregame (:3751–3758). Cette lecture pregame exige aussi le verrou exclusif ; la contention remonte jusqu’au catch AUTH_FAIL et à la fermeture WS1008 (:1034–1044). Le reconnect peut alors reproduire la même concurrence avec les appels HTTP admission/grilles. Blind Test restaure le runtime à l’inscription Organizer (registration.js:120), pas de restore pregame similaire dans son chemin registerPlayer observé ; il n’exécute pas les opérations de grille Bingo. Ceci explique une exposition différente, sans prouver une immunité BT au verrou partagé.

Deux traductions différentes du même échec technique : lecture hub_pregame → HUB_BUSY ; guard d’écriture → booléen true → HUB_PREGAME_NOT_STARTED dans boot_lib. Le deuxième code ne distingue pas contention, phase réellement bloquée ou event_id reset incorrect. Il est donc cohérent de voir NOT_STARTED après started accepté. Ce mécanisme est introduit par le delta pregame du dispatch ; il ne constitue pas une exigence nouvelle légitime de l’ensure.

Reproduction locale sans DB/réseau : /tmp/pregame-lock-audit.php charge le vrai bridge et le vrai game_api_dispatch (extrait sans bootstrap), avec PDO/verrou/handler doubles. Pendant une attribution grille autorisée, simulation d’une requête indépendante de lecture et d’une inscription. Trois états testés open, closed/started et slot absent : handler exécuté sous verrou dans les trois cas ; lecture concurrente HUB_BUSY ; inscription concurrente HUB_PREGAME_NOT_STARTED ; verrou libéré à la sortie dans les trois cas. Ce test reproduit l’interleaving et les branches réelles, pas des threads MySQL ni une charge DEV. Aucun indice de fuite permanente dans ce scénario : finally et profondeur réentrante sont équilibrés. Il démontre une portée de verrou trop large et sa persistance inutile hors pregame actif.

Limite de preuve : les logs d’hier démontrent les refus mais ne nomment pas le détenteur du verrou pour chacun des trois incidents27983 ni pour le reset27981. Les opérations grille/inscription/projection/lecture sont des concurrents identifiés par le code ; attribuer une requête précise serait une hypothèse. La contention peut notamment exister entre requêtes PHP malgré la sérialisation JS des restores d’un même runtime.

Orientation du correctif minimal à étudier : distinguer le refus technique du guard lifecycle ; éviter que les lectures pregame et le parcours ordinaire après clôture retiennent/requièrent inutilement le verrou global ; circonscrire la protection des transitions actives tout en conservant les protections contre les courses START/abandon/écritures. Ne pas simplement retirer tous les locks, libérer avant toute écriture sans revalidation, ni remplacer GET_LOCK0 par une attente globale longue. Pour vérifier les détenteurs réels si nécessaire : traces acquire/release/fail avec Hub/session/action/stage et durée de possession, sans tokens/pseudos. Aucun patch de cette passe ; pas de changement admission, compteur, auto-start, SQL ou retry Player.

Documentation : note/HANDOFF/TASKS Games/Global/Bingo/Blindtest, sitemap/index. Reproduction locale réussie et git diff --check ; aucun déploiement/restart. Anomalie distincte du focus_locked de suspension (section X).


## Z. Correctifs séparés A / B / C — 25/09/2026, locaux non déployés

Préflight privé relu dans l’ordre START main → SITEMAP develop → README → manifest → HANDOFF, puis note V2 (W/X) et canons Global/Games/Quiz/Blindtest/Bingo, actions/bridge/runbook. Journal AI Studio raw consulté : aucun fichier ciblé signalé plus récent. Les constats X/Y restent l’historique du diagnostic ; cette section décrit le correctif local qui les suit. Aucun déploiement, restart, accès DB ou changement de schéma.

### A — suspension pendant starting

Cause : le wrapper pregame de `focus_clear` rejetait le release canonique après suspension durable/ACK tant que le slot restait `starting`. `canvas_api_hub_lifecycle(release)` appelle désormais `app_games_hub_pregame_suspend_release` : relecture sous verrou de la suspension persistée, même session/E/request, puis transition dédiée `starting → closed(reason=suspended)` et clear canonique. Aucune preuve gameplay fabriquée ; E non complétée, premier START durable inchangé. Le slot libéré accepte une autre session. Les projections arbitraires restent interdites pendant opening/open/starting.

La projection historique de suspension avant première écriture gameplay (`hub_runtime_status=running`) reste inchangée et rend la même E réutilisable. Le journal de release conserve `pregame_first_start` quand le slot est retiré avant gameplay ; le read pregame le transmet hors slot actif, même si une autre session a remplacé ce slot. Les trois moteurs reprennent le chemin historique sans recréer de pregame ; Bingo conserve l’event_id initial pour son reset de reprise, puis libère ce cache à la preuve gameplay. Une suspension après vrai gameplay suit toujours son parcours historique.

Preuves offline : bridge/reducer/dispatch PHP réels, suspension persistée simulée → release → autre réservation → resume même E/premier START ; service de launch réel sur les trois moteurs, slot closed/suspended et `started=false` → `resume_existing_runtime`, même E. Suite lifecycle existante : ordre/ACK, refus, reprise et temps suspendu. Pas de qualification navigateur.

### B — portée du verrou et erreurs

| Opération | Avant | Après |
| --- | --- | --- |
| `hub_pregame/read` lors de l’auth | GET_LOCK Hub sans attente | lecture du snapshot InnoDB engagé, sans verrou exclusif Hub |
| player_register, grid_assign/get_or_assign, grid_hydrate | Hub verrouillé pendant le handler complet | contrôle avant/après handler, sans verrou Hub pregame ; contrôles propriété/grille existants conservés |
| Slot absent ou closed/started/suspended | acquisition Hub préalable même pour parcours historique | aucune acquisition ajoutée par pregame |
| Écriture gameplay sensible sous slot actif | Hub détenu pendant écriture | sérialisation maintenue, relecture après acquisition, identité/phase/event contrôlés |
| START, abandon, cleanup, suspension-release, removal | mutations sérialisées | sérialisation/CAS E/version conservés |

Les traitements neutres n’exécutent plus grille/hydratation/inscription sous le verrou global. Deux snapshots contrôlent l’identité session/E ; une fermeture ou un remplacement pendant le handler refuse la réponse d’admission. Une écriture de participation déjà engagée peut subsister : aucun rollback SQL fictif ; elle n’autorise pas un bind WS après fermeture, grâce au contrôle d’admission canonique et au tombstone de retrait. Ensure/mappings/compteurs de jonction inchangés.

Les écritures sensibles tentent au maximum trois acquisitions (deux pauses de10ms), puis `HUB_BUSY, retryable=true`. Une phase interdite reste `HUB_PREGAME_NOT_STARTED` ; event reset incorrect → `HUB_PREGAME_STALE_EVENT`, E obsolète → `HUB_PREGAME_STALE_EXECUTION`. Le dispatcher restitue les verrous en finally, y compris refus/exception. La lecture d’auth ne peut plus refuser pour contention du verrou pregame ; les autres erreurs réelles ne sont pas masquées.

Preuves : vagues simulées50/200/5000 opérations, phases open/starting/closed/absent, verrou détenu par un concurrent simulé ; aucune acquisition Hub pour opérations neutres ni read. START/reset sensible reste clôturé par le verrou ; abandon concurrent bloque l’admission, remplacement E détecté après handler. Ce ne sont ni une concurrence MySQL réelle ni une capacité réseau mesurée.

### C — retrait/récupération (première version, remplacée par AC)

Cause UI/backend : `app_games_hub_session_removal_state` classait le focus actif `running` avant de distinguer le slot pregame ; le rendu `games_hub_session_settings_state.can_remove` excluait cet état. Le serveur refusait aussi `SESSION_RUNNING`. L’éligibilité est maintenant partagée avec Remote et revalidée au traitement de la commande Master.

| État serveur | Éligibilité et effet |
| --- | --- |
| Jamais ouverte, pending | suppression physique canonique historique, inchangée |
| opening/open/starting ou closing du slot correspondant | recovery : confirmation destructive existante, tombstone durable puis fermeture/détachement |
| Vrai gameplay sain, focus actif, slot consumed | protection historique `SESSION_RUNNING` conservée |
| Suspension durable, y compris release incomplet | recovery, retrait logique historique sans effacer le journal |
| Terminée | retrait de membership avec histoire conservée |
| Expiration canonique `hub_runtime_expired` | recovery ; preuve serveur relue, pas seulement projection UI |
| Simple erreur visuelle, heartbeat absent, runtime supposé perdu | pas de nouvel état error ni d’heuristique : ces signaux seuls ne prouvent pas une expiration |
| Papier/démo | politique historique conservée |

Ordre : intent `hub_execution_removed` → E non admissible → slot `closing(removal=true)` → observation moteur toutes les2s → broadcast retour Hub, détachement canonique et fermeture sockets → preuve cleanup → slot closed/removed → focus libéré → membership inactive, mappings left, présence/commandes neutralisées, classement recalculé. Réutilisation du cleanup existant ; l’opération `remove` autorise ce cleanup après premier START sans forcer started/finished. Le retrait d’un pregame déjà ouvert est logique afin de conserver ses preuves d’exécution ; seul le cas historique jamais ouvert reste physique. Aucun résultat/podium créé.

`status=removing` signifie intent accepté, pas retrait finalisé. Le moteur retente un cleanup échoué ; le serveur accepte sa répétition après réponse perdue, même membership déjà inactive. E/version/provenance sont contrôlées ; un callback started tardif ne ressuscite pas la session. L’observation n’entre pas dans la file START pour ses lectures et ne modifie pas les délais auto-start. Elle cesse pour un slot retiré ou consommé.

**Limite explicite :** si aucun moteur ne peut confirmer le détachement et qu’aucune expiration canonique n’a été enregistrée, le retrait reste en attente, admissions fermées. Une absence de heartbeat n’est pas convertie en preuve de cleanup. Aucun critère fiable supplémentaire pour « runtime en erreur » après vrai gameplay n’a été trouvé dans le contrat consulté. Ce sous-cas exige une preuve moteur/canonique ; il n’est pas déclaré réparé par une heuristique UI.

Surfaces publiques : les filtres historiques memberships/tombstones restent actifs ; tests de présentation, Play, reprise et programme Pro couvrent la non-réapparition. Pas de nouveau fallback www/Play. La route Canvas des anciennes memberships utilise le contexte historique uniquement pour refuser leurs writes/reconnexions, jamais pour les réadmettre.

### Fichiers de cette passe (ne pas confondre avec les modifications antérieures du workspace)

- Global : `web/app/modules/jeux/hubs/app_games_hub_pregame.php`, `app_games_hub_removal.php` ; `web/tests/hub_session_removal_test.php`.
- Games : `web/includes/canvas/php/hub_pregame.php`, `hub_lifecycle.php`, `boot_lib.php` ; `web/modules/app_hub_view_helpers.php` (éligibilité seulement) ; `web/tests/hub_pregame_regressions_test.php`, `hub_pregame_removal_test.cjs`, `hub_first_launch_contract_suite.mjs`, `hub_active_resume_test.php`, `hub_suspend_test.php`.
- Quiz : `web/server/actions/hubPregame.js`, `web/server/restart_serveur.txt`.
- Blindtest : `web/server/actions/hubPregame.js`, `web/server/restart_serveur.txt`.
- Bingo : `ws/hub_pregame.js`, `ws/bingo_server.js` (event_id de reprise), `version.txt`.
- Documentation : note, README/TASKS cinq dépôts, actions/bridge/write-map/entrypoints/runbook, HANDOFF/CHANGELOG et sitemap/index générés. Markers préparés `restart 25-09-2026/01`, aucun redémarrage exécuté.

### Validation et recette suivante

Commande : `node /home/romain/Cotton/games/web/tests/hub_first_launch_contract_suite.mjs` ; résultat20/20 suites vertes. Harnais A/B/C PHP :42 087 assertions, effets SQL/lock simulés ; retrait Global239 vérifications, moteurs18 scénarios de retrait ; réutilisation E via launch170 vérifications. Suite flow Node→PHP20 scénarios :81s sur cet environnement, limite de lancement portée à240s pour ce test seul (ancienne limite60s dépassée, scénario isolé puis totalité verts). Auto-start37 scénarios inchangés, vagues10/50/200/5000 ; UI, reset, suspension/reprise, papier/démo conservés. Lint PHP/JS sur16 fichiers et git diff --check sur les six dépôts : OK. Ces chiffres ne qualifient pas un serveur réel.

Recette DEV ultérieure autorisée séparément : A sur BT avant `mainPlayerStarted`, suspendre, lancer une autre session puis reprendre même E ; B sur Bingo, vague Players pendant open/starting/après gameplay, contrôler auth/grille/hydratation et erreurs distinctes ; C depuis Master puis Remote, retirer open/starting et vérifier retour Players, slot/focus/E/membership, aucun résultat, autre session lançable. Refaire gameplay sain protégé, expiration canonique, retries et callbacks tardifs. Vérifier les erreurs persistantes et le cas moteur absent sans preuve, sans le présenter comme finalisé.

### Rollbacks indépendants

- A : retirer helper/transition `suspend`, appel release et transmission `pregame_first_start`, cache/usage event_id de reprise ; conserver B/C. Risque assumé : réintroduit le refus de release pendant starting. Ne pas supprimer les journaux déjà écrits.
- B : retirer guard structuré, read sans verrou et contrôles dispatcher avant/après, restaurer portée précédente ; conserver A/C. Risque : réintroduit contention et faux NOT_STARTED.
- C : retirer éligibilité recovery, orchestration remove/cleanup, observation moteur et refus tombstones ajoutés ; conserver A/B. Finaliser les intents `removing` avant rollback, ne jamais réactiver une membership retirée. Ne pas restaurer intégralement les fichiers partagés : les trois correctifs et des travaux antérieurs cohabitent.

Aucun changement ensure, admission collective, marqueurs de jonction, compteur binds WS, auto-start5s/10s/5s/90s, UI pregame, capacité, équipes, papier/démo.


## AA. Vérification du refus de suppression après rechargement des logs

**25/09 — Logs rechargés, suppression Blind Test27984 / Hub353 / client1018.** Games access jusqu’à09:11:47+0200 ; error jusqu’à09:11:45. Focus27984 toujours actif (error lignes504–505 notamment). POST Master HTTP400 à09:04:08/09/13 et09:10:56 (access499/500/509/678), sans body/action ni réponse JSON ; aucun événement removal/cleanup ou refus métier de retrait identifiable. Global error ne contient pas de diagnostic removal. Le handler session_remove local renvoie409 pour refus métier,403 pour autorisation ; BAD_MASTER_INSTANCE et UNKNOWN_ACTION peuvent renvoyer400 en amont. Ce sont des pistes, pas une attribution des HTTP400 à la suppression. Impossible de conclure SESSION_RUNNING, HUB_BUSY ou cleanup moteur absent avec ces seules copies ; déploiement des correctifs A/B/C non attesté par ces traces. Prochaine preuve : Payload(action/session_id/présence master_instance_id) et Response du POST exact lors du clic ; ne partager ni token ni CSRF. Audit seulement, aucun correctif applicatif/deploy/restart supplémentaire.


## AB. Retrait en attente après redémarrage moteur — cause du cas27984 (avant révision AC)

**25/09 — Retrait27984 accepté mais non finalisé, logs rechargés jusqu’à09:29.** Réponse navigateur fournie : ok=true/status=removing/session_id=27984 ; aucun refus initial d’instance/autorisation/éligibilité pour cette requête. Blindtest server-logs.log lignes19716–19718 : redémarrage CONFIG/WS_SERVER_REF_SET/WS_SERVER_LISTENING à07:09:08Z, soit09:09:08 Paris. Aucun événement WS après ce démarrage dans le fichier fourni. Games error794 : focus27984 encore actif à09:27:47 ; aucun proof_validation cleanup ni erreur de cleanup observé. Global n’ajoute aucun événement retrait. Code : resources/sessions.js initialise un dictionnaire vide ; watchRemoval est armé par restore/initialized pour chaque runtime en mémoire, pas par une réconciliation globale. app_games_hub_session_remove retourne removing tant que le slot correspondant reste actif/closing. Conclusion code+traces : slot durable à retirer sans runtime réhydraté pour émettre cleanup ; cas après restart manquant dans C. La version WS déployée n’est pas identifiable par ces logs, mais même le contrôleur local corrigé n’achève pas un retrait sans runtime. Ce n’est pas un HUB_BUSY observé ni un refus cleanup. Correctif à concevoir : réconciliation de retrait indépendante d’une session encore en mémoire, avec preuve moteur de non-possession de cette E/incarnation et protections contre callbacks tardifs ; pas un faux proof/runtime_detached ni une déduction depuis un simple heartbeat absent. Audit uniquement, aucun nouveau patch applicatif, aucune mutation DB/deploy/restart.



## AC. C révisé — retrait Hub autoritaire, cleanup non bloquant — 25/09/2026

**Contrat courant, local non déployé. Cette section remplace exclusivement C de Z et la piste de réconciliation évoquée en AB. A et B sont conservés.** Après confirmation destructive valide, le retrait Hub est durable immédiatement ; le cleanup runtime n’est plus une condition de finalisation produit. Aucun worker global ni nouvelle route publique.

### Préflight et cause

START main, SITEMAP/README/manifest/HANDOFF develop relus via API privée, puis note Open Players V2 et README/TASKS des cinq dépôts, actions/bridge/runbook. Journal AI Studio raw relu : aucun écart ciblé signalé. Les changements locaux des passes précédentes sont conservés ; aucune copie serveur ni version déployée supplémentaire supposée.

Ancien C : `removing → attendre moteur → cleanup → fermer slot → libérer focus → membership inactive`. Sur27984, redémarrage WS09:09:08 suivi d’aucune reconnexion observée : pas d’objet runtime pour observer l’intent. Nouveau C : la décision de retrait est entièrement PHP/Hub ; aucune preuve de détachement n’est inventée pour la produire.

### Finalisation dans session_remove

Sous le verrou Hub canonique, après vérification propriétaire/confirmation/éligibilité :

1. Tombstone durable `hub_execution_removed` ; l’E n’est plus une exécution ouverte admissible.
2. Membership inactive immédiatement.
3. Slot correspondant opening/open/starting/closing → **closed/removed**, par décision organisateur ; E/version/intent revalidés. Aucun champ `runtime_detached`, aucun faux started/finished/gameplay/résultat. Le slot est neutralisé avant le clear technique pour conserver le guard canonique, dans la même section critique.
4. Clear canonique du focus, autorisé pour cette ancienne membership uniquement par son tombstone. Ne touche pas un autre focus. Présentation de la session remise àNULL ; mappings left (IDs/histoire conservés), présence et commandes launch/select neutralisées, classement recalculé selon le contrat historique.
5. Réponse `ok:true,status:removed` ; retry finalisé → `already_removed`. Plus de réponse `removing` conditionnée au moteur.

Les tables MyISAM ne rendent pas toute cette séquence transactionnelle : une vraie erreur SQL reste signalée/retryable, sans réadmission ni rollback du tombstone. Les étapes sont répétables. Un ancien intent `removing`/slot `closing` est finalisé par une nouvelle demande de suppression, même sans moteur. Aucun worker de migration/réconciliation obligatoire.

### Matrice des états

| État canonique | Contrat |
| --- | --- |
| Jamais ouverte/pending | suppression physique historique inchangée |
| opening/open/starting/closing | retrait logique finalisé par PHP, runtime présent ou absent |
| Suspension durable, y compris release incomplet | retrait logique, journal conservé ; pas d’attente moteur |
| Runtime redémarré/perdu avec slot récupérable | même retrait ; aucune preuve cleanup exigée |
| Expiration canonique | retrait autorisé selon cette preuve existante |
| Terminée | retrait historique avec conservation des résultats existants et exclusion du classement Hub |
| Gameplay sain en cours | protection SESSION_RUNNING conservée |
| Simple erreur UI/absence de heartbeat après gameplay sain | pas de nouvel état error ni d’éligibilité supposée |
| Papier/démo | règles historiques conservées |

### Tombstone et callbacks

- `hub_pregame/read` renvoie `{ok:true,removed:true,slot:null}` pour la session retirée, même si le slot Hub a déjà été remplacé. Lecture sans verrou exclusif conservée.
- START/publish/started tardifs → `HUB_SESSION_REMOVED` ; aucun ACK serveur de nouveau START. Un ACK réseau déjà parti ne peut pas modifier la membership et ses writes suivants restent refusés.
- `cleanup` tardif d’une session retirée → succès sans mutation, sans toucher au nouveau slot/focus. Il ne finalise plus le produit.
- lifecycle read/validate/suspend/release/resume sur session retirée → activation refusée. Le contexte historique de membership inactive sert à constater le retrait, jamais à réadmettre.
- Le guard Canvas avant/après les opérations Player et l’admission WS canonique maintiennent le refus de retrait ; aucune modification ensure, identité, grille, capacité ou marqueurs de jonction.
- Anciennes commandes launch et URL Player ne reconstituent pas une E active ; protections membership/tombstone existantes conservées. Les tests font aussi perdre une admission en cours face au tombstone.

### Hygiène moteur

Le petit observateur existant (2s) ne lit que l’autorité de retrait pour les objets runtime encore présents. Il reste utilisable après consommation/remplacement du slot, et s’arrête si cet objet a été remplacé/détruit. Sur retrait : arrêt du timer local auto-start, broadcast `HUB_PREGAME_ABORTED` avec `reason=session_removed`, détachement canonique, fermeture sockets dans finally. Une erreur de détachement peut être retentée localement ; **aucun appel de finalisation Hub ni preuve cleanup n’est requis**.

Moteur absent/restart : aucun travail moteur requis pour retirer le produit. Une tentative de restore après retrait est refusée ; aucun faux runtime n’est créé pour obtenir une preuve. Un read ancien en vol ne détache pas un runtime de remplacement (`isCurrent` + E).

Organizer et Player traitent le retour Hub d’une E retirée même sans contexte pregame encore affiché ; vérification contexte officiel et E. Remote utilisait déjà le handler retour corrélé E. Aucun changement visuel du pregame, de l’auto-start5s/10s/5s/90s ni du compteur binds.

### Surfaces et vérifications

La membership devient inactive avant réponse : lecteurs programme Master/Remote et poll Hub Play l’excluent dès leur prochain rafraîchissement normal, sans attendre le nettoyage WS. Les lecteurs publics www/play et navigation Dashboard/Agenda continuent d’utiliser leurs filtres actifs/tombstones sans fallback legacy réintroduit. Le focus/slot libérés autorisent une nouvelle session ; Quick Add ne reste plus bloqué par l’ancienne session retirée (contrats d’occupation/navigation existants).

Validation locale : suite principale **20/20** ; tests dédiés moteurs/retour navigateur **26/26** ; retrait PHP **300 vérifications** avec service/focus canoniques et doubles SQL ; bridge/dispatch A/B/C **42 093 assertions** (dont vagues simulées50/200/5000). Compléments : admission réelle avec I/O simulées **133**, navigation publique **41** (39 SELECT SQLite), navigation Pro **49** (148 SELECT SQLite), deux suites fallback historique vertes. Les tests ciblés ont été rejoués après les derniers ajustements C ; UI20/20. Pas de qualification navigateur interactif, réseau ou concurrence MySQL réelle.

Commandes :

```sh
node /home/romain/Cotton/games/web/tests/hub_first_launch_contract_suite.mjs
php /home/romain/Cotton/games/web/tests/hub_hotfix_admission_test.php
python3 /home/romain/Cotton/global/web/tests/hub_public_navigation_test.py
python3 /home/romain/Cotton/global/web/tests/hub_pro_navigation_test.py
php /home/romain/Cotton/global/web/tests/hub_historical_membership_fallback_test.php
php /home/romain/Cotton/global/web/tests/hub_removed_session_fallback_reproduction_test.php
```

Comparaison avec la baseline locale : helper de suspension A, guard structuré B, dispatcher et algorithme auto-start inchangés. Lint PHP/JS, diff-check et sitemap/index vérifiés. Aucun déploiement/restart.

### Fichiers propres à cette révision C

- Global : `web/app/modules/jeux/hubs/app_games_hub_removal.php`, `app_games_hub_pregame.php`, `app_games_hubs_functions.php` (clear canonique d’une membership retirée) ; `web/tests/hub_session_removal_test.php`.
- Games : `web/includes/canvas/php/hub_pregame.php`, `hub_lifecycle.php` ; `web/includes/canvas/core/hub_pregame.js`, `web/includes/canvas/play/play-ws.js` (retour uniquement) ; tests `hub_pregame_regressions_test.php`, `hub_pregame_removal_test.cjs`, `hub_pregame_bridge_fixture.php`, `hub_suspend_test.php`, `hub_hotfix_admission_test.php`.
- Quiz et Blindtest : chacun `web/server/actions/hubPregame.js`, `hubSuspension.js`, `web/server/restart_serveur.txt`.
- Bingo : `ws/hub_pregame.js`, `ws/bingo_server.js` (`isCurrent`), `version.txt`.
- Markers préparés `restart 25-09-2026/02` ; ils ne constituent pas un redémarrage effectué.
- Documentation : note, HANDOFF, README/TASKS des cinq dépôts, actions/bridge/write-map/entrypoints/runbook, CHANGELOG, sitemap/index générés.

### Recette et rollback C uniquement

Après livraison opérateur ultérieure, retenter la suppression27984 : attendu `removed` ou `already_removed`, disparition programme/focus, autre session lançable **même sans reconnexion Blind Test**. Rejouer open/starting avec moteur vivant puis moteur arrêté/redémarré, vieux callbacks et Players ; vérifier cleanup différé sans incidence produit. Gameplay sain toujours protégé ; jamais ouverte garde sa suppression canonique.

Rollback sélectif C : restaurer les seuls blocs remove/read-removed/clear-tombstone, observation et retour session_removed, en conservant A/B et l’auto-start. Un retour à l’ancien C réintroduit la dépendance au runtime pour les prochains retraits : risque explicite. Ne jamais effacer les tombstones, réactiver les memberships retirées ni restaurer globalement les fichiers partagés. Aucun rollback données automatique ; nouvelle livraison/restart à autoriser séparément.


## AD. POC DEV — Hub hôte et Master session embarqué (25/09/2026)

**Statut historique de livraison : implémentation locale lors de AD ; déploiement DEV et recette manuelle des trois jeux confirmés ensuite le25/09. Voir AE pour les preuves et limites, sans nouveau patch.** Le pregame historique reste le défaut. Cette passe ne modifie ni ensure/mapping/compteur/auto-start, ni les moteurs, ni les correctifs A/B/C, ni papier/démo. Remote non migrée.

### Activation et principe

Ouvrir l’URL habituelle Hub Master, avec un seul paramètre supplémentaire :

- `?hub_embed_poc=ack` : variante A, révélation après ACK START corrélé du chemin existant ;
- `?hub_embed_poc=started` : variante B, révélation après lecture du slot durable `closed_reason=started` de la même E/session.

Ajouter `&` plutôt que `?` si l’URL possède déjà une query. Le serveur exige `conf.server=dev` ; le paramètre seul n’active rien en PROD. Le host refuse démo, reprise historique, absence de slot, autre Hub/E ou destination externe. Le Canvas vérifie de nouveau Hub officiel numérique, E et slot. Démarrer depuis le Master (commandes de lancement Remote hors POC).

Le lancement PHP existant réserve/réutilise E/slot puis retourne son URL canonique `/master/<token>?hub_execution=…&hub_transition=open_players`. Le parent la charge une seule fois dans un iframe de même origine. Le host n’ouvre aucune connexion Organizer : seul le Canvas existant porte bootstrap, primary, init, START/ACK et jeu. Aucune modification de src au départ, aucune seconde registration induite par la révélation. L’iframe garde sa taille finale, `opacity:0`, `pointer-events:none`, `inert` pendant la préparation ; pas de `display:none`. Le centre Hub affiche « La partie se prépare… ». Le QR existant reste en place ; aucun compteur supplémentaire.

### Fullscreen et affichage

Le Hub conserve `document.documentElement` comme propriétaire fullscreen. L’iframe est fixée sur le viewport, largeur100vw, hauteur100vh puis100dvh, et recouvre l’interface Hub au départ. Pas de nouvelle requête fullscreen ; contrôle Canvas masqué et handler neutralisé uniquement en mode embarqué. Permissions de frame : `autoplay; fullscreen 'none'` (le lecteur/Canvas ne doit pas prendre le fullscreen). Deux notifications resize sont envoyées lors de la révélation, sans reconstruire lecteur/store/WS. Vérifier en DEV overlays, introduction, vidéos, podiums et contrôles historiques à1280×720, laptop1024×600 et écran externe.

### Source du jalon B

Le snapshot WS `HUB_PREGAME_STATE` n’expose pas `closed_reason`. Un simple closed n’est pas une preuve de départ (abandon/suspension/retrait possibles). Nouvelle lecture **DEV opt-in, Organizer autorisé, Master courant** sur la route Hub Master : POST `action=hub_embed_poc_state`, `session_id`, `execution_id`, `master_instance_id`. Réponse limitée à ok/matched et state(session_id,E,phase,version,closed_reason). Aucun token, payload brut ou compteur PHP exposé. Contexte Hub léger. Aucune écriture, preuve inventée ou nouvel endpoint moteur. Poll séquentiel1s,500ms après ACK tant que la preuve n’est pas observée ; cet intervalle ajoute sa latence de présentation, sans effet sur START.

### Annulation et retour

La carte ciblée reçoit le bouton POC Annuler en opening/open ; si l’Organizer n’est pas prêt, l’intention attend runtime-ready avant envoi de l’abandon canonique. Starting : bouton désactivé « Démarrage… ». Le child contrôle à nouveau phase et accepted ; aucun abandon après START accepté. Une course START gagnante reprend la révélation, sans attente indéfinie d’une annulation refusée. Focus/guards demeurent côté serveur ; autres sélections/présentation bloquées visuellement pendant cette préparation.

Les retours canoniques utilisent la même URL Hub Master avec paramètres de corrélation POC. Cette navigation se produit uniquement dans l’enfant vers un petit document de retour, **sans bootstrap d’un second Hub ni takeover**. Le parent contrôle origine/chemin/E/channel, attend la clôture canonique après abandon, détruit l’iframe, actualise le Hub et garde son fullscreen. Retour naturel/suspension/résultat : délégation aux déclencheurs et délais historiques ; aucun nouveau timer de fin ni résultat. Retour Player inchangé via HUB_PREGAME_ABORTED et routage existant. Destruction de frame sur Master remplacé sans demande d’abandon ; fermeture/reload du parent ne déclenche aucun abandon.

### Sécurité / cache

Bridge postMessage limité à origine exacte, fenêtre source exacte, channel aléatoire par montage, session et E. Le parent ne consomme que des champs listés. Pas de payload brut ou token dans les traces. Le channel est une corrélation, pas un droit : autorisation serveur inchangée. Pas de sandbox sur ce Canvas de confiance même origine : ajouter allow-scripts et allow-same-origin ne créerait pas une frontière de sécurité contre ce document, et retirer ces capacités casserait ses usages existants. Aucune délégation fullscreen à l’enfant. Aucun accès DOM direct pour piloter le jeu ; seul l’inspecteur de retour lit l’URL de l’enfant de même origine. Assets nouveaux versionnés par filemtime ; hub_pregame.js déjà versionné dans l’import map. Livrer le lot complet, ne pas mélanger les fichiers POC avec une version antérieure du pregame.

### Audio / qualification

Le POC ne simule pas de clic, ne neutralise pas les règles navigateur et ne déclenche pas un second Play. Le clic Lancer précède la réponse HTTP puis la création d’un nouveau document : ne pas supposer que ses listeners de déblocage auront reçu ce geste. `allow=autoplay` est une permission déléguée, pas une preuve de déblocage. Le Canvas garde ses mécanismes AudioContext/YouTube et ses dépendances aux gestes réels. Une interaction supplémentaire nécessaire en DEV constitue un résultat négatif du critère UX, à documenter, pas à masquer par un START artificiel.

Les traces `[hub_embed_poc]` et `window.HubEmbedPOC.traces()` (300 entrées maximum) donnent montage, bootstrap, runtime-ready, registration, START request_id, ACK, state/version, started-proof, reveal, événements média reconnus, retour et état fullscreen. Aucun identifiant personnel ni token. Les événements support/started ne prouvent pas à eux seuls qu’un son était audible : écouter et observer en DEV, corréler aux logs moteur.

### Tests locaux et recette DEV

Tests automatisés locaux :

```sh
# Depuis games
node --test web/tests/hub_embed_poc_test.cjs
php web/tests/hub_embed_poc_test.php
node --test web/tests/hub_pregame_cta_test.cjs web/tests/hub_pregame_flow_test.cjs web/tests/hub_pregame_autostart_test.cjs web/tests/hub_pregame_removal_test.cjs
# Chromium local : Playwright installé séparément, aucun ajout aux dépendances applicatives
PLAYWRIGHT_MODULE=/chemin/vers/playwright node web/tests/hub_embed_poc_browser.cjs
```

Résultats :9 tests hôte,12 contrôles PHP,103 tests existants réussis. Ces tests couvrent isolation des messages, A/B, conservation frame/src, absence de révélation sur closed générique/suspended, annulation avant START, retour après cleanup et takeover. Les tests DOM simulés ne constituent pas une preuve Chrome/WS/médias réels.

Compléments :36 tests Master mobile, présence, suspension et contrôles associés réussis. Trois échecs hors POC dans les suites Remote : `hub_remote_polling_test.mjs` (harness papier, bouton résultat de recherche absent ligne1765), `remote_module_cache_test.mjs` (2 cas, extraction du premier import prenant un helper papier pour le module d’autorité). Les tests et toutes leurs sources lues sont inchangés par rapport aux empreintes avant POC ; aucune correction hors périmètre. Ne pas présenter la totalité des suites Remote comme verte.

**Chromium local153.0.8010.12 headless : deux variantes réussies, A1280×720 et B1024×600.** Fullscreen parent conservé du lancement au retour, URL parent inchangée, identité/URL/document enfant inchangés à la révélation, deux resize reçus, cadre aux dimensions du viewport. A révèle après ACK ; B reste masqué après ACK jusqu’à la preuve simulée. AudioContext atteint running sans clic enfant dans ce fixture même origine après le clic parent ; cela ne prouve ni audio audible ni déblocage YouTube réel. Aucun flag de contournement autoplay utilisé. Le fixture charge les vrais scripts host/child dans des documents séparés ; le runtime, la registration et le slot sont simulés. Il ne qualifie pas Quiz/Blind Test/Bingo ni YouTube.

Recette opérateur DEV (chaque variante sur exécutions distinctes et chaque jeu) :

1. Ouvrir Hub Master DEV avec paramètre A ou B, console Preserve log et logs moteur disponibles. Passer en fullscreen, puis Lancer.
2. Vérifier URL parent inchangée, centre préparation, iframe unique rendue mais non interactive, une registration primary côté moteur, même E/slot ; faire rejoindre un Player réel.
3. Laisser l’auto-start actuel agir, sans clic dans l’iframe. Relever request_id, ACK, preuve moteur, reveal, premier média/question. Comparer A/B : temps de transition, écran prématuré, intro audible mais cachée, premier morceau/question visible, éventuelle interruption.
4. Quiz : intro/première question. Blind Test : YouTube/audio/premier morceau. Bingo : init, reset durable puis gameplay. Vérifier superpositions, vidéos, podium et contrôles sans fullscreen enfant.
5. Sur essais distincts : Annuler en open (Players Hub, cleanup confirmé, iframe retirée), suspension après départ, fin naturelle, retour après résultats si historique. Vérifier parent fullscreen conservé.
6. Reload en pregame : le navigateur détruit l’iframe et peut quitter fullscreen. Aucun abandon émis. Le POC ne remonte pas automatiquement le runtime : Lancer doit réutiliser le slot sain/E via service existant dans la grâce ; expiration/perte d’incarnation conserve son contrat. Documenter le résultat, ne pas promettre une continuité navigateur à travers un reload.
7. Deux Masters/takeover : l’ancien hôte doit retirer son iframe à la révocation. Vérifier la grâce et l’absence de commandes tardives ; aucun mécanisme de transfert primary ajouté.

Sans accès à un Hub DEV déployé, les étapes métier restent **à effectuer**, et aucun choix de jalon média définitif n’est annoncé. B est le candidat métier prudent ; A reste la mesure de référence plus précoce. Décision provisoire : **viable avec réserves pour la mise en recette**, pas migration validée.

### Remote et limites

Remote reste historique et peut naviguer vers sa Remote session pendant open. Le POC cible le lancement direct Master. Extension future : Hub Remote hôte d’une seule Remote session secondaire, même bridge E/session/channel, révélation sur preuve de départ, retour léger sans nouveau Hub imbriqué. Réutiliser ownership/continuité existants ; ne jamais charger un deuxième Organizer primary. Aucun cycle multi-session complet, aucune restauration automatique après reload, aucun transfert media/primary n’est livré.

### Fichiers applicatifs POC à livrer en DEV — dépôt Games uniquement

Nouveaux :

- `web/modules/app_hub_embed_poc.php`
- `web/includes/canvas/core/hub_embed_host.js`
- `web/includes/canvas/core/hub_embed_child.js`
- `web/includes/canvas/css/hub_embed_poc.css`

Modifiés (ils contiennent aussi des correctifs locaux antérieurs à préserver) :

- `web/modules/app_hub_master_ajax.php`
- `web/modules/app_hub_view_helpers.php`
- `web/organizer_canvas.php`
- `web/includes/canvas/core/hub_pregame.js`
- `web/includes/canvas/core/canvas_display.js`

Tests hors livraison applicative : `web/tests/hub_embed_poc_test.cjs`, `web/tests/hub_embed_poc_test.php`, `web/tests/hub_embed_poc_browser.cjs`.

Aucun fichier Global/Quiz/Blind Test/Bingo modifié dans cette passe ; aucun marker/restart WS nécessaire pour ce POC. Aucun déploiement effectué par Codex. Rollback : finir/abandonner le test selon le contrat puis rouvrir l’URL Hub sans hub_embed_poc ; le parcours historique reste le défaut. Pour retirer le code, inverser uniquement ce delta POC, pas restaurer les fichiers entiers depuis HEAD (correctifs antérieurs non commités).


## AE. Recette DEV POC iframe — confrontation logs / navigateur (25/09/2026)

**Audit seul, aucun patch applicatif, aucun restart, aucune DB/SSH.** Déploiement DEV et essais manuels confirmés par l’opérateur après AD. Préflight privé START main → SITEMAP/README/manifest/HANDOFF develop, note V2 et canons actions/bridge consultés ; journal AI Studio raw décodé, aucun fichier ciblé signalé plus récent. Les copies locales rechargées Games/Global/Quiz/Blind Test/Bingo constituent les seules preuves serveur. Aucun accès DEV direct.

### A. Exécutions retrouvées

Client1018, Hub354. Toutes les heures ci-dessous sont **Paris, UTC+02:00 le25/09**. Les WS journalisent UTC ; conversion+2h. Les logs PHP/access ont une précision à la seconde, les WS à la milliseconde. Ne pas calculer de latence navigateur à partir de ces horloges.

| Jeu | Session | E | Variante dans GET Master session | Chargement → document retour | Preuve Games access_log |
|---|---:|---|---|---|---|
| Blind Test |27986|hubexec-f3c47372f49b513a0cad942afb1ef30e|ack|14:09:42 →14:10:38|29489 /29792|
| Blind Test |27987|hubexec-285d16241d748d5b4d22e2d6e1c76bf5|started|14:13:31 →14:16:53|30469 /31361|
| Bingo |27989|hubexec-19d6bbde0fcd3961f76c562cab534506|started|14:17:20 →14:21:27|31511 /33034|
| Bingo |27990|hubexec-7786dd643e56bb963428c3f384f6ba58|ack|14:21:40 →14:22:26|33116 /33680|
| Quiz |27991|hubexec-05a75b6cb3b9467dd4e27bf73aeeeb42|ack|14:23:09 →14:23:40|33923 /34177|
| Blind Test |27992|hubexec-653611b88b920c061689709c4be7fac1|ack|14:25:09 →14:25:49|34683 /34979|

Corrélation : URL Master session contenant E+variante → token session utilisé uniquement pour recouper sid WS → session numérique/Hub/E des proof_validation PHP. Aucun token ou identité Player repris dans cette note.

**Deux ouvertures antérieures de27992, à ne pas attribuer au reveal de l’E réussie :**

- `hubexec-03532d1232622b151c94c00d588f69c4`, GET14:24:19, sans hub_embed_poc, paramètres de commande Remote ; publish14:24:25, cleanup14:24:28.
- `hubexec-9c2e062895b48879a8a0532e596578a1`, GET14:24:40, sans hub_embed_poc ; publish14:24:45, cleanup14:24:49.

Games access34410/34531 ; error29119/29155/29223/29248. BT primary socket28016 puis32458, closes4001 « Hub pregame abandoned » (21418/21501). Ce sont deux abandons puis une nouvelle E, pas trois registrations du primary de l’E653611… . La variante POC n’est pas renseignée sur ces deux entrées, elles ne qualifient pas une annulation depuis la carte du host POC.

### B. Chronologie par moteur

Références : G=games/logs/error_log ; BT=blindtest/web/server/server-logs.log ; Q=quiz/web/server/server-logs.log ; B=bingo.game/ws/server-logs.log ; A=games/logs/access_log. Les événements runtime-ready, auto-start requested, ACK et reveal ne sont **pas directement journalisés dans ces copies** ; les étapes ci-dessous ne les remplacent pas artificiellement.

| Session | Heure Paris | Événement / preuve | Interprétation |
|---|---|---|---|
|27986|14:09:45.588 / .688|registerOrganizer primary / promotion initiale, BT20191/20194|un primary, socket28036|
|27986|14:09:45|publish ok et présence runtime, G25441/25442|open confirmé ; présence compatible avec runtime-ready, pas timestamp du Bus|
|27986|14:10:02.407 / .443|update_session_infos / firstClickDetected, BT20433/20436|effets différés après ACK selon le producteur actuel|
|27986|14:10:02.459|initializeOrUpdateSession En cours, BT20439|premier état de lancement ; ne vaut pas preuve de média|
|27986|14:10:16.096 / .101|mainPlayerStarted / countdown, BT20535/20538|premier départ de piste signalé au serveur|
|27986|14:10:16|started ok, G25565|preuve métier acceptée, même E|
|27986|14:10:36 →14:10:38|suspend demandé G25628 ; document retour A29792 ; close primary BT20720 à14:10:38.509|sortie par suspension|
|27987|14:13:34.592 / .711|registerOrganizer primary / promotion initiale, BT20754/20757|un primary, socket32864|
|27987|14:13:34|publish ok G26272 ; présence G26276|open confirmé|
|27987|14:13:59.665 / .671|options / firstClickDetected, BT21065/21068|effets après ACK selon code ; ACK non capturé|
|27987|14:13:59.868|En cours, BT21071|début du parcours runtime|
|27987|14:14:11.719|nouveau update En cours, BT21087|mise à jour du même socket, pas nouvelle registration|
|27987|14:14:13.742 / .746|mainPlayerStarted / countdown, BT21096/21099|preuve de piste et compteur moteur|
|27987|14:14:13|started ok, G26441|preuve acceptée pour E285d…|
|27987|14:14:18.007|Pause, BT21220/21222|pause après gameplay|
|27987|14:16:53 →14:16:53.985|suspend G26910 ; retour A31361 ; close primary BT21300|sortie par suspension, même socket jusqu’à la sortie|
|27989|14:17:25.198 / .260|AUTH_OK / WS_ROLE_CONNECTED organizer B24794/24796|une connexion Organizer|
|27989|14:17:25|publish ok G27042|open confirmé|
|27989|14:17:52.456|SESSION_RESET B25037|reset initial attendu, une opération|
|27989|14:17:52.583|playing_state, B25038|déclencheur canonique started Bingo|
|27989|14:17:52|started ok G27293|preuve acceptée avant la première piste|
|27989|14:18:04.819|TRACK_START B25048|première piste signalée au serveur|
|27989|14:21:27 →.494|suspend G28021 ; retour A33034 ; déconnexion B25170|retour via suspension|
|27990|14:21:43.856 / .904|AUTH_OK / WS_ROLE_CONNECTED organizer B25218/25220|une connexion Organizer|
|27990|14:21:43|publish ok G28120|open confirmé|
|27990|14:22:10.404 / .664|reset / playing B25475/25477|un reset initial puis lecture|
|27990|14:22:10|started ok G28378|preuve acceptée même E|
|27990|14:22:22.814|TRACK_START B25493|première piste|
|27990|14:22:25 →14:22:26.340|suspend G28463 ; pause reason hub_suspend B25499 ; retour A33680 ; déconnexion B25503|retour via suspension|
|27991|14:23:12.429 / .653|registerOrganizer primary / promotion Q27367/27370|un primary, socket23402|
|27991|14:23:12|publish ok G28724|open confirmé|
|27991|14:23:22.610 / .612|options / firstClickDetected Q27473/27476|effets après ACK selon code|
|27991|14:23:22.650|En cours Q27479|début du parcours runtime|
|27991|14:23:35.021 / .024|mainPlayerStarted, QUESTION_START_SIGNAL_RX, countdown Q27706–27709|première question signalée|
|27991|14:23:35|started ok G28848|preuve métier acceptée|
|27991|14:23:39 →14:23:40.634|suspend G28884 ; retour A34177 ; close Q27893|retour via suspension|
|27992 E653611…|14:25:12.902 / .994|registerOrganizer primary / promotion BT21516/21519|un primary pour cette E, socket50242|
|27992 E653611…|14:25:13|publish ok G29366|open confirmé|
|27992 E653611…|14:25:29.085 / .087|options / firstClickDetected BT21721/21724|effets après ACK selon code|
|27992 E653611…|14:25:29.132|En cours BT21727|début du parcours runtime|
|27992 E653611…|14:25:43.552 / .554|mainPlayerStarted / countdown BT21901/21904|première piste signalée|
|27992 E653611…|14:25:43|started ok G29520|même E acceptée|
|27992 E653611…|14:25:48 →14:25:50.237|suspend G29557 ; retour A34979 à14:25:49 ; close primary BT22076|retour via suspension|

Le logger proof_validation est dans le finally de canvas_api_hub_pregame **après l’appel métier**, son ok rapporte le résultat de apply et pas seulement la normalisation JSON (games/web/includes/canvas/php/hub_pregame.php). Chaque started positif constitue donc une preuve de transition acceptée dans le contrat présent.

### C. Primary / runtime

Dans chacune des six fenêtres E chargée→retour, un seul enregistrement primary pertinent est observé pour Quiz/BT ; Bingo montre un seul AUTH_OK/WS_ROLE_CONNECTED Organizer et une hydratation boot par session. Quiz/BT : même ws_client_id du bootstrap jusqu’au mainPlayerStarted et au close de sortie ; aucun remplacement primary ni nouvelle création runtime au départ. Les promotions initiales sont attendues, pas des takeovers. Aucun signal de reconstruction au reveal trouvé, mais l’instant du reveal n’est pas logué : **compatible avec continuité**, pas mesure directe du DOM.

Les registrations `isPrimary=false` sont les Remotes. BT27987 a une nouvelle registration Remote à14:16:08.767 (BT21281), bien après gameplay, sans changement du primary32864. Les deux bootstraps antérieurs27992 appartiennent aux deux E abandonnées décrites en A.

Bingo : un SESSION_RESET par E ; les deux CANVAS_WRITE_OK autour de chaque reset sont des traces de couches différentes avec le **même event_id**, pas deux resets métier. Les clés observées correspondent exactement à `hub-first-start-` +48 caractères du SHA256 de l’E :

-27989 : `hub-first-start-6817ab7eeadbc783039dfb82d36566a96b1e4880ab5ce380` ;
-27990 : `hub-first-start-920350d85956bb5c1168c4630bdf2436254e18e2a0625bbc`.

### D. START / ACK : preuves et limites

Les copies ne contiennent aucun HUB_PREGAME_AUTO_START, HUB_PREGAME_START, HUB_PREGAME_START_ACK, request_id `hub-pregame-start:…`, ni trace `[hub_embed_poc]`. Les loggers WS n’exposent pas ces échanges dans les traces présentes ; les traces POC sont console/mémoire navigateur, sans collecte serveur. L’opérateur n’a pas conservé les messages WS/console du cas27987.

Le code construit un request_id stable `hub-pregame-start:<E>` et attend l’ACK corrélé avant le chemin jeu. C’est **le contrat lu, pas une valeur extraite de la recette**. Les request_id des logs hub_launch_session_profile sont ceux de la requête PHP de lancement, pas ceux du START WS. Les request_id suspend-* ne sont pas des START non plus.

Preuves positives : même E publish→started→suspend/retour ; un started accepté par E ; reset Bingo lié à la clé canonique ; pas de second départ/reset/reconnexion au lancement dans les traces. Déduction : le parcours observé est compatible avec un START accepté puis la continuation après ACK. L’unicité SQL du premier START relève du contrat canonique ; sans journal START ni DB, ne pas annoncer une cardinalité de writes mesurée ou un ACK capturé. Aucun doublon observé, absence de doublon protocolaire exhaustivement prouvée : **non**.

Derniers binds précédant le premier état de lancement : BT27986 14:09:56.457, BT27987 14:13:54.388, Bingo27989 14:17:46.864, Bingo27990 14:22:04.827, Quiz27991 14:23:17.437, BT27992 14:25:23.804. Les événements de lancement arrivent environ5–6s plus tard, compatibles avec le calme WS5s actuel. Cela ne remplace pas la trace du signal auto-start et n’implique aucune modification de son algorithme.

### E. Comparaison des jalons

**ACK→reveal, ACK→started, started→premier événement visible : non mesurables exactement dans ces fichiers.** ACK/reveal non capturés ; un événement moteur n’est pas une mesure de visibilité sur l’écran. Voici les écarts réellement calculables sur une même horloge WS :

| Exécution | Intervalle mesuré | Écart |
|---|---|---:|
|BT27986 ack|premier En cours → mainPlayerStarted|13,637s|
|BT27987 started|premier En cours → mainPlayerStarted|13,874s|
|Quiz27991 ack|premier En cours → mainPlayerStarted|12,371s|
|BT27992 ack|premier En cours → mainPlayerStarted|14,420s|
|Bingo27989 started|SESSION_RESET → playing_state|0,127s|
|Bingo27990 ack|SESSION_RESET → playing_state|0,260s|
|Bingo27989 started|playing_state → TRACK_START|12,236s|
|Bingo27990 ack|playing_state → TRACK_START|12,150s|

Explication appuyée sur code + logs : Quiz/BT publient started au signal mainPlayerStarted ; le bootstrap a déjà lancé le parcours d’introduction après ACK (boot_organizer.js, beginPlayFlow/runIntroIfNeeded). BT27987 reste donc masqué pendant une partie de ce parcours avec reveal=started. Le poll ajoute au plus sa cadence nominale (500ms après ACK hors latence/erreur), mais les ~14s observées ne peuvent pas lui être attribuées seules. Ne pas assimiler WS_GAME_COUNTDOWN_START au compteur visuel du jingle : il est déclenché par le départ de piste.

Bingo publie started sur playing_state, juste après le reset et environ12s avant TRACK_START. Les mesures reset→playing montrent une transition courte, cohérente avec l’observation ACK≈started, **sans mesurer exactement ACK→started**. Aucun avantage visuel de started démontré par ces traces. Le constat opérateur sur Quiz ne couvre que ack ; pas de comparaison navigateur started Quiz revendiquée.

### F. Message BT27987 started

**Chaîne d’affichage démontrée par le code :** HUB_PREGAME_ERROR avec la même E → hub_embed_child.js stage=error (le code erreur n’est pas retransmis) → host stage=error après contrôle origine/source/channel/session/E → message « La préparation rencontre une difficulté. Consulte les traces du POC. » et trace runtime-error. Le catch du poll hub_embed_poc_state produit uniquement state-read-unavailable, **pas ce message**. Un closed_reason tardif ne le produit pas non plus.

**Cause métier exacte non retrouvée.** Aucun code HUB_PREGAME_ERROR, timeout ou mismatch E/version/session corrélé dans les fichiers ; message navigateur non conservé, confirmé par l’opérateur. Aucun fondement pour attribuer le cas à HUB_BUSY, NOT_STARTED, une commande précise ou un défaut du moteur. Les initialisations/started échouées qui émettraient une erreur sans execution_id ne correspondent pas directement au filtre du bridge enfant ; garder la corrélation E comme exigence.

Dans l’intervalle de l’essai27987 après son chargement, aucune erreur HTTP>=400 sur les requêtes POC recensées. Les POST Hub sont200, **sans action du body ni réponse métier enregistrées** : on ne peut pas certifier chaque poll hub_embed_poc_state individuellement. L’erreur499 de14:13:19 précède le chargement27987 à14:13:31 et ne démontre pas un échec de son poll.

Conséquence : le message ne prouve pas une panne du polling started. Son affichage est générique et ne bloque pas reveal ; la preuve started est acceptée et la piste démarre ensuite. « Sans aucun impact runtime » ne peut pas être garanti au-delà de cette progression réussie. Aucun correctif ni instrumentation ajouté.

### G. Retours Hub et fullscreen

Les six retours corrélés suivent une demande de suspension ; aucune fin naturelle de ces six E n’est démontrée. Le GET document retour contient la même E/variante/channel et répond200 avec113 octets, cohérent avec le document léger du POC, puis la socket Organizer se ferme. Pas de chargement d’un nouveau Canvas pour la même E au retour.

Les autres GET Hub racine ne prouvent pas une navigation top-level ni un Hub imbriqué : le parent effectue aussi des refresh HTML de préparation. Le document retour léger et l’absence de nouvelle registration primary sont compatibles avec le mécanisme attendu, mais ni arbre DOM ni propriétaire fullscreen ne sont exposés par ces logs. **Fullscreen conservé pendant jeu/retour, racine Hub inchangée, même iframe révélée : observations opérateur**, distinctes des preuves serveur. Les deux abandons27992 sans paramètre POC ne valident pas le CTA Annuler du host, et les traces ne qualifient pas un cycle multi-session automatique.

### H. Conclusion

Les six exécutions sont **compatibles avec ACK pour le reveal UI / started pour la preuve métier**. Les retours manuels positifs couvrent les trois jeux et les traces soutiennent la continuité runtime/E, le reset canonique Bingo et l’acceptation ultérieure de started. started n’est pas un jalon UX homogène entre moteurs : trop tard pour l’introduction BT, plus précoce chez Bingo. ACK est le candidat transversal étayé par la recette ; aucun changement de règle implémenté ici.

Limites bloquant une affirmation plus forte : pas d’ACK/reveal horodatés, pas de request_id START observé, cause exacte de HUB_PREGAME_ERROR perdue, absence de preuve de fin naturelle et de fullscreen serveur (non observable par ce canal). Une prochaine capture navigateur devra conserver les seuls type/error/request_id/E/phase/version et temps relatifs, sans tokens ni payload personnel, si une attribution précise de l’erreur est nécessaire.

### I. Anomalies effectivement observées

- Message générique POC sur BT started, rapporté par l’opérateur ; origine logique identifiée, code déclencheur non retrouvé.
- Début visuel BT masqué en started, rapport opérateur cohérent avec l’écart runtime13,874s.
- Trois réponses HTTP499 sur POST Hub POC :14:13:19 (A30424),14:21:36 (A33084),14:24:19 (A34411). Body absent ; ne pas les attribuer à hub_embed_poc_state, au START ou au message27987.
- BT : WS_SESSION_NOT_FOUND lors de closes tardifs après retrait/cleanup (notamment21333/21335/21337 et21411+ /21502+), ainsi que WS_REG_SESSION_NOT_FOUND après les deux abandons27992 (21422/21431/21437/21511). Ils suivent les nettoyages, ne constituent pas une reconstruction au reveal. Aucun refus de ce type attribué à l’E653611… réussie pendant son démarrage.

Aucun double primary, reset inattendu ou deuxième bootstrap pendant les six démarrages réussis trouvé. Aucun nouveau défaut moteur démontré. Vérification de l’audit : extraction structurée, corrélation par E/session/sid et calcul des deltas ; pas de nouvelle exécution des tests applicatifs, puisqu’aucun code n’a changé. Note/HANDOFF/TASKS et statuts documentaires mis à jour, sitemap/index régénérés ; aucun déploiement/restart.


## AF. Hub-native : audit du delta et instrumentation préalable START — 25/09/2026

**Livraison locale partielle : audit + instrumentation, non déployée. La migration Hub-native Master/Remote et le nouveau moteur de stabilité ne sont pas implémentés dans cette passe.** La demande exige une règle justifiée par les traces et prévoit une instrumentation préalable si elles sont insuffisantes. Les essais disponibles établissent le défaut de calme5s, mais ne contiennent ni population éligible historique, ni START/ACK exact. Les nouveaux signaux restent observationnels ; aucune formule candidate ne pilote le jeu.

### A. Préflight documentaire / AI Studio

START main puis SITEMAP, README, DOCS_MANIFEST, HANDOFF develop lus dans l’ordre via l’API privée authentifiée. Sections consultées : START « Parcours », « Règle preuve d’abord », « Discipline de génération » ; README « AI workflow », « Production et travaux en cours » ; manifest « Update triggers », « Post-edit required actions » ; HANDOFF entrées du25/09 ; présente note AD/AE ; canons Open Players V2 et markers. URLs exactes listées en fin de section.

Journal AI Studio général lu en brut avant patch ; aucun fichier ciblé dans ce lot signalé plus récent. Les changements externes recensés portent notamment sur WWW/communication/backoffice, hors lot. Aucun rechargement applicatif requis. Lecteur : `https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&mode=raw` ; paramètre d’authentification utilisé en mémoire, volontairement non publié. Aucun accès DB, SSH, DEV/PROD ni navigateur.

### B. Baseline réellement présente

Documentation sur develop, Games/Global/Quiz/Blind Test/Bingo sur pregame, Play sur hub_soiree. Nombreux fichiers modifiés/non suivis préexistants : ils portent Open Players V2, A/B/C et le POC et ne sont pas des changements de cette passe. Aucun reset, commit ou remplacement global. Le POC DEV ack/started existe dans Games ; auto-start commun5s minimum/10s sans bind/5s calme/90s watchdog. Les logs de la recette AE sont présents : leur recherche exige le sid runtime, pas le numéro de session métier. La demande initiale de rechargement formulée pendant l’audit a été corrigée ; aucun rechargement nécessaire pour ces six essais.

### C. Promotion POC → Hub Master natif : delta audité, non appliqué

À reprendre presque tel quel : frame same-origin montée une fois, dimensions finales/opacity/inert, fullscreen parent, source+origin+channel+session+E du bridge, resize au reveal, retour enfant léger et destruction après retour canonique. Sources : `games/web/includes/canvas/core/hub_embed_host.js`, `hub_embed_child.js`, `games/web/modules/app_hub_embed_poc.php`, `games/web/organizer_canvas.php`.

À adapter : sortir de l’opt-in expérimental sans changer le mode d’une E existante ; mémoriser le choix de présentation avec l’exécution ; rattacher reload/takeover à ce choix ; employer ACK seulement en mode natif ; texte central final ; remplacer réellement le CTA de carte. Le POC masque aujourd’hui les actions et ajoute son bouton Annuler. Le lancement direct passe par `hubMasterNavigateToLaunch`, mais le lancement reçu du Remote navigue encore directement via `command.redirect_url` dans `app_hub_view_helpers.php` : il faut un raccordement commun du résultat canonique, sans second lancement. Ne pas simplement activer le POC par défaut.

### D. Intégration Hub Remote : delta audité, non appliqué

Remote actuelle = surface session secondary et ownership existant, sans iframe hôte. `remote-ws.js` consomme HUB_PREGAME_STATE/ERROR/ABORTED ; START_ACK est envoyé uniquement au primary dans le contrôleur. Une phase starting seule n’est donc pas un ACK corrélé reçu par le Remote.

Le plus petit raccordement cohérent doit couvrir : résultat canonique de commande et routage de même E, frame `/remote/...` secondary unique, contexte retour léger Remote, conservation remoteInstanceId/remotePageId/ownership, compteur issu de la WS enfant, notification d’acceptation corrélée pour le reveal et récupération après reload. Ne jamais réutiliser le montage Master pour créer un primary Remote. Fermeture Master, takeover, deux onglets, commandes anciennes et E stale restent à tester lors de cette migration ; aucune qualification nouvelle annoncée ici.

### E. CTA Lancer / Annuler / Démarrage…

Contrat cible confirmé : Lancer avant préparation ; Annuler uniquement opening/open par abandon existant ; starting désactivé ; Reprendre seulement après départ réel puis suspension ; Résultats à la fin. Aucun bouton central séparé. Aucun changement UI dans cette livraison ; le CTA POC et le parcours historique restent tels quels.

### F. Reveal ACK

Décision produit actée : **ACK corrélé = reveal UI ; started = preuve métier interne**. La variante expérimentale started reste disponible dans le POC historique, elle n’est pas promue en règle normale. Ce lot ne modifie ni iframe, ni fullscreen, ni primary, ni registration, ni ACK transport. Il journalise `ack_sent` côté moteur : cela ne prouve ni réception navigateur ni reveal.

### G. Population Hub et correspondance identities ↔ binds

Projection diagnostique livrée dans Global `app_games_hub_pregame_population_ids(PDO, hub_id, session_id)` : SELECT des `games_hubs_players.id` actifs du Hub, exclusion d’un mapping de cette session avec status=left. Les probables non activés, dans leur table séparée, ne sont pas une population active. Un actif sans mapping reste éligible : attendre un mapping compterait l’ensure comme condition d’éligibilité. Aucun ensure, participation, capacité, stock, écriture ou verrou Hub ajouté. Aucun LIMIT métier ; parcours PDO des IDs complets. Identité identique au champ `identity` de la preuve `canvas_hub_admitted_player_check` (Games `hub_capacity.php`), pas un pseudo, une clé runtime ou un participation_id.

Transport service-only existant `hub_pregame`, `stage=read`, options `diagnostic_population=true` et `execution_id`. Seulement open, même session/E/version, numérique officiel, focus courant ; relecture du slot après le SELECT. Réponse optionnelle `population={execution_id,version,identities:[string]}` ; null/absence = inconnu, jamais zéro. SQL indisponible ou course de version ne casse pas la lecture canonique. Aucun payload d’identités transmis au navigateur.

Le moteur demande cette projection pendant open via son cycle existant de lecture retrait (délai nominal2s après chaque réponse, sans requêtes concurrentes supplémentaires). Intersection exacte des identités du snapshot avec les sockets bindées réellement vivantes ; trace `population` : eligible_identities, ready_eligible, added, removed, full_ready_observed. `0/0` n’est pas full-ready. La date de réception du snapshot est `population_sample_ms`, pas une transaction atomique distribuée. Aucun de ces signaux n’est utilisé pour START à cette étape. Coût MySQL/réseau et cohérence sous mutations concurrentes à qualifier avant usage décisionnel.

### H. Analyse des vagues réelles

Analyseur reproductible : `scripts/diagnostics/hub-pregame-waves.py --poc-root /home/romain/Cotton`. Fenêtres UTC explicites de AE, déduplication par identité PLAYER_WS_BOUND ; aucun nom/identifiant Player/token runtime dans le rapport. Paquets séparés par un intervalle ≥5s, pas des paquets réseau. Quantiles nearest-rank des29 intervalles entre30 premières identités.

| Session | Jeu | Binds avant / après jalon runtime | Médiane intervalle | P95 | Trou maximal | Tailles des paquets (séparation ≥5s) |
|---|---|---|---|---|---|---|
|27986|blindtest|24 / 6|416ms|842ms|7551ms|24 + 6|
|27987|blindtest|30 / 0|453ms|2545ms|3369ms|30|
|27989|bingo|30 / 0|532ms|1039ms|4503ms|30|
|27990|bingo|30 / 0|480ms|1321ms|3747ms|30|
|27991|quiz|9 / 21|462ms|1551ms|5651ms|9 + 21|
|27992|blindtest|15 / 15|795ms|2029ms|6788ms|15 + 15|

Le jalon est le premier WS_GAME_SESSION_UPDATED En cours pour Quiz/BT et SESSION_RESET pour Bingo. **Ce n’est pas l’instant du START/ACK.** Ces arrivées après début runtime impliquent un départ de vague anticipé sur27986/27991/27992 ; elles ne prouvent pas la population Hub éligible à cet instant. Les recettes comportent30 identités observées, pas une preuve de30 simultanément présentes/éligibles. Population historique exacte : **non trouvé**. Binds exactement post-START : **non trouvé** dans les traces historiques faute du jalon exact ; le proxy est explicitement distinct. Analyse des grandes vagues150/200/5000 réelles : **non trouvé dans ces six essais**, aucune extrapolation de qualification réseau.

Preuves de trous : BT27986 ligne20447 reprend après7,551s et6 identités suivent ; Quiz27991 ligne27489 après5,651s puis21 identités ; BT27992 ligne21742 après6,788s puis15 identités. Sources et SHA256 de la capture :

- `blindtest/web/server/server-logs.log` : `f12231bd0b157894e1009c00372a0c81b2cedb2d2780173380068d4e090e9b15`.
- `bingo.game/ws/server-logs.log` : `ff98023d3481ec5e0b425432d877d4061ef876ef4414921a8d00328e66615dde`.
- `quiz/web/server/server-logs.log` : `5a877757df15eb7a20890b8357377ffaa680437ef409c1ae5e772fd0b67def1a`.

### I. Moteur de stabilité : instrumentation livrée, formule non figée

Les trous observés dépassent5s, jusqu’à7,551s ; remplacer5 par8 ou10s ne serait pas une règle validée, surtout pour une population plus grande ou mouvante. Les six essais n’établissent pas une distribution représentative de fin de vague. Aucun quorum, plafond ni nouvelle formule imposé.

Cible future : full-ready immédiat pour une population non vide par inclusion exacte des identités, puis décision nominale fondée sur une fenêtre d’arrivées et le reste éligible ; population = signal, pas obligation100%. Zéro Hub connu et population inconnue doivent être distingués. Watchdog exceptionnel90s conservé. **Comportement livré reste5/10/5/90 ; full-ready immédiat n’est pas encore activé.**

Nouvelles traces INFO `HUB_PREGAME_WAVE` dans les server-logs habituels des trois moteurs : publish, bind/unbind, population/population_unavailable, decision, start_accepted, ack_sent, started, abandon/cleanup. E + trace_id de l’incarnation diagnostique, horloge serveur milliseconde, phase/version, taille courante et nombre d’identités observées. L’ordinal anonyme d’identité est stable seulement dans une trace ; reconnect/remplacement ne devient pas une première identité. Aucun Player token, nom, participation_id ni request_id arbitraire logué ; `canonical_request` atteste le format attendu du request_id de l’ACK. Un ACK réémis est distinct d’une seconde acceptation START. Le journal watchdog existant reste distinct. Défaut du logger neutralisé ; aucune transition métier ne dépend d’une trace. Une restauration qui retire le contrôleur pregame peut mettre fin à la trace ; ne pas réunir artificiellement des incarnations pour déduire un effectif unique.

### J. Tests et limites

Commandes principales :

```sh
# Depuis documentation
PYTHONDONTWRITEBYTECODE=1 python3 scripts/diagnostics/test_hub_pregame_waves.py
python3 scripts/diagnostics/hub-pregame-waves.py --poc-root /home/romain/Cotton
# Depuis games
php web/tests/hub_pregame_population_test.php
node --test web/tests/hub_pregame_autostart_test.cjs web/tests/hub_pregame_flow_test.cjs web/tests/hub_pregame_proof_transport_test.cjs web/tests/hub_pregame_removal_test.cjs web/tests/hub_embed_poc_test.cjs
php web/tests/hub_pregame_regressions_test.php
```

52 cas auto-start/diagnostics, dont10/50/200/5000 sockets simulées par moteur, identité différente malgré compteurs égaux, churn,0/0,inconnu, reconnect, binds après START, échec logger.38 contrôles bridge PHP dont5001 IDs sans troncature, mauvais E/focus/slot/papier/démo/retrait et course pendant SELECT.4 tests Python dont exécution du SELECT réellement extrait du code sur tables SQLite en mémoire (pas MySQL Cotton). Lints PHP/JS ; régressions A/B/C PHP42093 assertions, slot79, retrait300, expiration213, papier876, admission115 et POC PHP12 contrôles. Suite Node combinée126/126 réussie (auto-start/flow/proof/removal/POC). Aucune simulation n’est une qualification réseau/DB/navigateur ; migration Master/Remote non testée puisqu’elle n’est pas livrée.

### K. Fichiers modifiés par dépôt, delta de cette passe uniquement

- Global : `web/app/modules/jeux/hubs/app_games_hub_pregame.php` (projection diagnostique).
- Games : `web/includes/canvas/php/hub_pregame.php`, `web/tests/hub_pregame_autostart_test.cjs`, nouveau `web/tests/hub_pregame_population_test.php`.
- Quiz : `web/server/actions/hubPregame.js`, `web/server/actions/hubSuspension.js`, `web/server/restart_serveur.txt`.
- Blind Test : mêmes trois chemins que Quiz.
- Bingo : `ws/hub_pregame.js`, `ws/bingo_server.js`, `version.txt`.
- Documentation : analyseur + test Python ; présente note AF, README/TASKS cinq repos + documentation, README général, HANDOFF, manifest, interfaces actions/canvas-bridge, entrypoints, runbook DEV et pm2-ws ; index/sitemap générés.

### L. Documentation

Documentation alignée sur **audit/instrumentation seulement**, dans les blocs AUTO-UPDATE existants ; aucune nouvelle UI ni formule déclarée livrée. Pas de CHANGELOG user-facing pour ce lot sans changement d’interface/comportement de lancement. Pas de bingo-write-map modifié : aucun write nouveau. Routing diagnostics ajouté au manifest, génération `npm run docs:sitemap` exécutée avec succès.

### M. Recette DEV opérateur nécessaire pour la suite

Livraison/restart non effectués, non autorisés par ce chantier. Lors d’une recette ultérieure décidée par l’opérateur : livrer Global puis Games puis contrôleurs/hooks WS cohérents avec la baseline pregame, markers trois moteurs `restart 25-09-2026/03`. Garder les copies de journaux, y compris rotations : INFO supplémentaire par bind peut accélérer la rotation.

Sur nouvelles E Quiz/BT/Bingo : petite session, zéro réellement éligible, joueurs éligibles sans bind, vague irrégulière avec pause≥5s puis deuxième paquet, scan QR pendant préparation, départ/reconnexion, annulation, suspension/retrait. Paliers10/50/200, puis5000 uniquement si le dispositif de charge/opérateur le permet ; aucune promesse de5000 en réseau réel. Conserver `HUB_PREGAME_WAVE` sur toute la fenêtre, les logs PHP et les traces navigateur ACK/reveal. Vérifier des snapshots population disponibles avant décision, et l’absence d’identités manquantes causée par une livraison partielle.

Analyse après rechargement : `python3 scripts/diagnostics/hub-pregame-waves.py --telemetry /chemin/server-logs.log /chemin/server-logs.1.log`. Rapporte START accepté exact, binds nouveaux avant/après, ACK envoyés et évolution ready/eligible ; aucune formule candidate encore appliquée. Les données permettront un replay comparatif : aucun départ dans les trous connus, full-ready sans fenêtre supplémentaire, zéro connu distinct d’inconnu, pas d’attente obligatoire100%, watchdog hors chemin nominal. Ensuite finaliser le moteur et le lot UI natif avec recette Master/Remote complète.

### N. Rollback

Annuler uniquement ce delta de diagnostics : contrôleurs/hooks WS, extension read Games et helper Global, markers associés. **Ne pas restaurer depuis HEAD les fichiers complets**, ils contiennent A/B/C/POC antérieurs non commités. Copies exactes avant cette passe dans `/tmp/cotton-hub-audit/before/` et patches incrémentaux par dépôt dans `/tmp/cotton-hub-audit/delta/` avec SHA avant/après (temporaires, à conserver ailleurs avant toute livraison). Aucun SQL de rollback, aucun mode d’E changé. Ancien WS avec nouveau PHP inchangé ; nouveau WS avec ancien PHP voit population inconnue et conserve l’ancien START. Rollback/restart serveur restent opérateur.

### Sources documentaires API exactes utilisées

Branche main pour START ; develop pour toutes les autres. Les liens privés nécessitent l’authentification indiquée dans START. SITEMAP : entrées de chemins ; manifest : triggers/markers ; note : AD/AE ; canons des jeux : sections Open Players V2 ; documentation : blocs maintenance ; pm2 : markers. Aucun lien legacy employé pour la lecture.

- [START.md — main](https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=main).
- [SITEMAP.ndjson — develop](https://api.github.com/repos/cotton-games/documentation/contents/SITEMAP.ndjson?ref=develop).
- [README.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/README.md?ref=develop).
- [DOCS_MANIFEST.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/DOCS_MANIFEST.md?ref=develop).
- [HANDOFF.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/HANDOFF.md?ref=develop).
- [notes/hub-open-players-foundations-2026-09-24.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/notes/hub-open-players-foundations-2026-09-24.md?ref=develop).
- [canon/interfaces/actions.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/interfaces/actions.md?ref=develop).
- [canon/interfaces/canvas-bridge.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/interfaces/canvas-bridge.md?ref=develop).
- [canon/entrypoints.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/entrypoints.md?ref=develop).
- [canon/runbooks/dev.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/runbooks/dev.md?ref=develop).
- [pm2-ws.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/pm2-ws.md?ref=develop).
- [canon/repos/games/README.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/games/README.md?ref=develop).
- [canon/repos/games/TASKS.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/games/TASKS.md?ref=develop).
- [canon/repos/global/README.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/global/README.md?ref=develop).
- [canon/repos/global/TASKS.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/global/TASKS.md?ref=develop).
- [canon/repos/quiz/README.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/quiz/README.md?ref=develop).
- [canon/repos/quiz/TASKS.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/quiz/TASKS.md?ref=develop).
- [canon/repos/blindtest/README.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/blindtest/README.md?ref=develop).
- [canon/repos/blindtest/TASKS.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/blindtest/TASKS.md?ref=develop).
- [canon/repos/bingo.game/README.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/bingo.game/README.md?ref=develop).
- [canon/repos/bingo.game/TASKS.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/bingo.game/TASKS.md?ref=develop).
- [canon/repos/documentation/README.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/documentation/README.md?ref=develop).
- [canon/repos/documentation/TASKS.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/documentation/TASKS.md?ref=develop).


## AG. Hub-native Master/Remote — implémentation locale du 25/09/2026

### A–B. Préflight et baseline

Suite explicite demandée : poursuivre le Hub-native, arbitrer ultérieurement le moteur avec l’instrumentation. Préflight privé main/develop et chemins/URL exacts : section AF « Sources documentaires API exactes utilisées ». Journal AI Studio relu avant patch (`mode=raw`), conflit sur fichiers ciblés : non trouvé. Aucun secret recopié. Baseline préservée : POC AD/AE, diagnostics AF, corrections A/B/C, parcours Players, papier/démo. Aucun déploiement, restart, DB ni accès navigateur DEV.

### C–F. Surfaces natives, CTA et ACK

Nouveau E officiel numérique DEV : `pregame_ui_mode=hub_native` enregistré dans le journal d’exécution et `ui_mode` dans le slot. `hub_native=0` et POC explicite choisissent session à la création ; une E existante reste dans son mode. Production reste sur le mode historique. Master et Remote utilisent le même hôte et la même E, chacun avec son Canvas existant ; Remote reste secondary et n’émet pas de START. Commande Remote → Master → décision Global conservée.

Master : zone centrale légère « La partie va bientôt commencer », QR/liste Hub conservés, aucun compteur WS supplémentaire. Remote : préparation, nom de session et compteur provenant uniquement du snapshot WS ; inconnu distinct de zéro. Le CTA de la carte devient Annuler en opening/open, Démarrage… après acceptation, Annulation… durant abandon. Bouton central non ajouté. Contrôles concurrents interceptés pendant la préparation ; guards serveur inchangés.

Reveal uniquement sur ACK `hub-pregame-start:<E>` du même enfant/origine/channel/session/E. Une seule affectation src ; même iframe et Canvas avant/après, fullscreen parent conservé. `started` reste la preuve métier, ne déclenche pas le reveal natif. STATUS relit l’ACK accepté pour le primary ou la Remote courante, à partir du slot accepté ou du premier START durable de même E ; aucun write, nouveau START ni gameplay artificiel. Champ read-only `accepted_start` du bridge pour récupérer le slot closed/started après restart ; distinct du carrier `first_start` de reset. Copie de preuve ACK conservée en mémoire après consommation de la preuve reset ; elle n’autorise aucun reset supplémentaire. Si le slot a été remplacé, le descripteur runtime exige la preuve durable du même E dans le lifecycle ; sinon attente dans le Hub, sans bascule vers session.

Annuler délègue au Canvas puis au chemin canonique ; interdit après ACK. Remote post-ACK autorise la demande de suspension canonique même si la preuve gameplay n’est pas encore arrivée. Rechargement Hub : découverte read-only seulement après takeover courant, remontage E existante. Retour : document léger sans second Hub/takeover, retrait enfant, restauration CTA et rafraîchissement Hub. Une génération de routage supérieure autorise une reprise explicite ; les polls de l’ancienne génération ne remontent pas automatiquement la session quittée. Remplacement d’instance : démontage sans abandon métier.

### G–I. Population, vagues et moteur temporaire

Projection des identités éligibles et instrumentation AF conservées. Le moteur actuel reste **minimum5s, grâce zéro10s, silence de binds5s, watchdog90s**. Aucun full-ready décisionnel nouveau ; 0/0 ne vaut pas exhaustivité. Les trous réels observés et limites sont ceux d’AF, sans nouvelle donnée inventée. L’arbitrage de la nouvelle règle attend la collecte instrumentée, conformément au dernier message utilisateur.

### J. Tests et limites

- `node games/web/tests/hub_first_launch_contract_suite.mjs` :20/20 suites, dont A/B/C, retrait, contention, expiration, papier/démo, suspension/reprise, transport et simulations de10/50/200/5000 binds. Doubles DB/WS ; pas de qualification réseau.
- `php games/web/tests/hub_embed_native_test.php` :21 contrôles (mode figé, fallback, découverte read-only, exclusions, descripteur runtime).
- `node --test games/web/tests/hub_embed_native_ack_test.cjs` :5 tests (trois moteurs, ACK actuel/relecture/stale E/socket, vrai handler Remote et suspension après ACK).
- `node --test games/web/tests/hub_embed_poc_test.cjs` :9 tests ; `php games/web/tests/hub_embed_poc_test.php` :12 contrôles.
- `hub_embed_native_browser.cjs` sous Node22/Playwright/Chromium locaux :18 vérifications Master1280×720 et Remote390×844, vrais host/child/CSS, transport simulé. Même iframe, fullscreen, compteur Remote seul, mauvais ACK refusé, started sans reveal, CTA/restauration, retour, génération de reprise, annulation, takeover et découverte après ready. POC navigateur ack/started également réussi. Ce n’est pas une recette DEV ni une validation Safari/autoplay/médias réels.
- `hub_master_mobile_cards_test.php` réussi ; lints PHP/JS et diff-check sans erreur.
- `hub_remote_contract_test.php` conserve **trois échecs textuels préexistants**, reproduits avec les sources du snapshot avant cette passe : ordre explication QR/aide recherche, assertion resolver papier, sortie Remote historique versus about:blank. Les cinq assertions devenues obsolètes par le nouveau paramètre ou le retour léger sont adaptées ; aucune nouvelle divergence restante dans ce test. Ne pas annoncer toute la batterie historique verte.

Commande navigateur locale : `PLAYWRIGHT_MODULE=/tmp/cotton-embed-browser/node_modules/playwright PLAYWRIGHT_BROWSERS_PATH=/tmp/cotton-embed-browsers /tmp/cotton-embed-browser/node_modules/node/bin/node games/web/tests/hub_embed_native_browser.cjs` (chemins locaux temporaires ; Node20+ et Chromium requis ailleurs).

### K–L. Fichiers et documentation

- Global : `web/app/modules/jeux/hubs/app_games_hubs_functions.php`, `app_games_hub_pregame.php` (mode E/slot, transport préférence).
- Games : `web/modules/app_hub_embed_native.php` nouveau ; `app_hub_view_helpers.php`, `app_hub_master_ajax.php`, `app_hub_remote_ajax.php` ; `web/organizer_canvas.php`, `web/remote_canvas.php` ; `web/includes/canvas/core/hub_embed_host.js`, `hub_embed_child.js`, `web/includes/canvas/remote/remote-ws.js`, `web/includes/canvas/css/hub_embed_poc.css`, `web/includes/canvas/php/hub_pregame.php` (preuve ACK de récupération distincte du reset) ; trois nouveaux tests `hub_embed_native_test.php`, `hub_embed_native_ack_test.cjs`, `hub_embed_native_browser.cjs` et assertions `hub_remote_contract_test.php` adaptées.
- Quiz/Blindtest : `web/server/actions/hubPregame.js`, `web/server/restart_serveur.txt` ; Bingo : `ws/hub_pregame.js`, `version.txt`. Contrôleurs identiques, markers25-09-2026/04.
- Documentation : présente section, README/TASKS cinq repos+documentation, README général, HANDOFF/CHANGELOG, manifest, actions/bridge, entrypoints/runbook DEV/pm2-ws ; sitemap/index générés. AF reste l’historique d’audit, cette section décrit le nouveau delta.

### M. Recette DEV opérateur

Après livraison autorisée et coordonnée des fichiers, créer un nouvel E numérique dans chacun des trois jeux. Vérifier lancement depuis Master puis Remote, compteur Remote réel, Master sans compteur dupliqué, QR Hub conservé, carte Annuler opening/open puis Démarrage…, même iframe/src/E au reveal ACK. Vérifier Remote secondaire tardive, reload avant/après ACK, takeover Master/Remote, annulation, suspension pendant starting puis reprise du même E, fin naturelle, retrait et callbacks tardifs. Vérifier papier/démo/hors Hub inchangés et fallback `hub_native=0` uniquement sur nouveaux E. Capturer E, request_id, phase/version, ACK/reveal et traces `hub_pregame_wave` ; ne pas déduire la population de simples lignes bind ou la preuve gameplay du reveal. Cette recette n’a pas été exécutée ici.

### N. Rollback

Préférer `hub_native=0` pour créer de nouveaux E en session ; ne change pas les E natives en cours. Pas de bascule silencieuse à chaud. Pour retrait du code, terminer/abandonner/suspendre proprement les E en cours puis enlever uniquement ce delta, sans restaurer les fichiers entiers sales. Snapshot pré-passe dans `/tmp/cotton-hub-native/before`, patchs incrémentaux dans `/tmp/cotton-hub-native/delta` (temporaires, non versionnés). Préserver POC, instrumentation AF et A/B/C. Tout déploiement/restart éventuel reste une action opérateur distincte et explicitement autorisée.


## AH. Correctif ciblé Remote et reprise après recette DEV — 25/09/2026

### A. Préflight et statut

Hub-native livré en DEV et première recette Blind Test globalement positive côté Master **selon l’opérateur**. Deux régressions rapportées : Remote bloquée dans la préparation et préparation réaffichée à Reprendre. Ce correctif est local, non déployé ; aucune qualification Quiz/Bingo réelle déduite.

Prélecture authentifiée dans l’ordre START main → SITEMAP/README/DOCS_MANIFEST/HANDOFF develop, puis chemins résolus par sitemap. START : « Statut actuel », « Parcours », « Règle preuve d’abord » ; README : « Doc discipline », « Sécurité » ; manifest : « Update triggers », Open Players V2 ; HANDOFF : « Suite Hub-native ». Note V2 : AG, AF et A/B/C. Journal général AI Studio raw (`documentation/general/0_ROADMAP.md`, mode=raw) consulté avant patch ; fichier ciblé potentiellement plus récent : **non trouvé**. Aucun secret reproduit.

Sources API effectivement consultées :
- [START.md — main](https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=main).
- [SITEMAP.ndjson — develop](https://api.github.com/repos/cotton-games/documentation/contents/SITEMAP.ndjson?ref=develop).
- [README.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/README.md?ref=develop).
- [DOCS_MANIFEST.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/DOCS_MANIFEST.md?ref=develop).
- [HANDOFF.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/HANDOFF.md?ref=develop).
- [notes/hub-open-players-foundations-2026-09-24.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/notes/hub-open-players-foundations-2026-09-24.md?ref=develop).
- [notes/hub-remote-master-ux-audit-2026-09-07.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/notes/hub-remote-master-ux-audit-2026-09-07.md?ref=develop).
- [notes/remote-ownership-transversal-2026-09-18.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/notes/remote-ownership-transversal-2026-09-18.md?ref=develop).
- [notes/hub-session-readiness-2026-09-23.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/notes/hub-session-readiness-2026-09-23.md?ref=develop).
- [canon/interfaces/actions.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/interfaces/actions.md?ref=develop).
- [canon/interfaces/canvas-bridge.md — develop](https://api.github.com/repos/cotton-games/documentation/contents/canon/interfaces/canvas-bridge.md?ref=develop).

### B. Remote historique retrouvée

Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php` :
- `app_games_hub_remote_client_routing_policy_resolve` : `resume_existing_runtime` → `runtime_kind=existing`, pas de nouvelle readiness ; `new/recreated` exigent la readiness. Raisons réelles `launch_ready`, `resume_ready`, `runtime_readiness_waiting`.
- `app_games_hub_remote_client_routing_state_get` : relit le Hub durable ; vérifie focus/membership, exécution non expirée/non suspendue, contexte publié, génération, URL, readiness et présence runtime Master exacte. Retourne `target`, `client_joinable`, `joinable`, `remote_url`, `execution_id`, `session_id`, `routing_generation`, `master_context_available`. Sans présence : `runtime_master_absent`.
- Games `app_hub_remote_ajax.php::routeFromControlState` historique ne navigue que sur ce `control_poll.client_routing`. `boot_organizer.js::markHubRemoteLaunchReadiness` et `postHubRemoteRuntimePresence` alimentent ce contrat. Readiness peut déjà être publiée à open : elle ne remplace pas le premier START durable.

`launch_waiting_runtime` et `active_execution_ready` dans ces fonctions actuelles : **non trouvé** ; aucun usage de noms supposés. Documentation : note Remote UX « Sources raw et preuve locale », ownership « Contrat final », interface Canvas « Hub → Remote ». La note readiness Player du23/09 concerne un chantier distinct, non importé dans ce correctif.

### C–D. Divergence et correctif Remote

Avant patch, `routeFromControlState` traitait `payload.native_embed`, appelait launch puis retournait **avant** l’examen de client_routing ; l’autre garde `HubEmbedPOC.active()` interrompait également le suivi. `hub_embed_host.js` révélait Master et Remote sur le même stage ack ; `remote-ws.js` possédait le consommateur START_ACK. Une route valide ne pouvait donc pas révéler la Remote sans cette nouvelle dépendance ACK. ACK réellement reçu pendant la recette : **non trouvé** (aucune capture fournie) ; le court-circuit est prouvé statiquement, indépendamment de ce détail réseau.

La branche native transmet maintenant client_routing à l’hôte, y compris pendant la vie de l’iframe. Le poll natif lit la même fonction Global canonique, sans nouveau writer ni protocole de START. Corrélation session/E/génération, URL same-origin/path/E et présence Master exacte ; first_start durable accepté requis pour ne pas quitter opening/open sur une readiness précoce.

L’iframe Remote reste masquée jusqu’à ce que le flux UI existant `remote/state` affiche `En cours`, `Pause` ou `Partie terminée`. `remote-ui.js::applyScreenVisibility` réserve le lobby à `En attente`. Le callback de rendu suivant ferme la vue de préparation via Bus et signale `remote-operational` au parent déjà autorisé par client_routing. C’est une protection de rendu, pas un ACK métier : aucune écriture, aucun START, aucun primary et aucune dépendance mainPlayerStarted/started. En l’absence de route ou d’écran opérationnel, le Hub demeure visible. La même iframe secondary est conservée.

Le front Remote ignore désormais START_ACK ; les émissions secondaires existantes des contrôleurs WS restent inchangées et ne sont plus requises. Master premier lancement conserve ACK corrélé → reveal.

### E–F. Divergence et correctif reprise

La preuve n’était pas perdue dans le code audité : le slot conserve `first_start` et le lifecycle de suspension/reprise transporte `pregame_first_start`. Le host acceptait `resume_existing_runtime`, `closed` et `runtime`, mais ajoutait toujours `hub-embed-preparing`, montait le panneau/compteur/CTA et attendait l’ACK. De plus, il préférait `payload.pregame` au descripteur enrichi. Cela explique la réentrée **visuelle**. Recréation durable opening/open dans la recette : **non trouvé**, faute de logs/DB ; aucun changement du lanceur Global justifié.

`games_hub_native_descriptor` projette `preparation=false` uniquement sur une preuve first_start avec event_id et execution_id du même E, issue du slot correspondant ou du lifecycle déjà utilisé pour un slot remplacé. Nouvelle E sans preuve : préparation conservée. Ce booléen n’est pas persisté et ne devient pas une preuve métier ; le mode hub_native reste figé par E.

L’hôte préfère le descripteur enrichi. Reprise : aucun panneau, compteur ou CTA de préparation ; même iframe Master, révélation à sa readiness runtime existante. Récupération du premier START déjà accepté mais encore starting : ACK primary conservé pour finir la transition existante. Remote attend dans le Hub la joinabilité et le rendu opérationnel, sans nouveau pregame. Le code Global conserve la branche resume_existing_runtime et E ; aucun ensure/premier START/reset initial n’est ajouté par ce patch.

### G. Invariants

Mêmes E/session/génération ; ownership/takeover et secondary existants ; Master iframe/fullscreen inchangés. Aucun second primary/START/E/reset créé par l’hôte. Abandon opening/open maintenu et refus après preuve acceptée. `started` reste la preuve métier. Population, binds,5/10/5/90, admission, late joins, A/B/C, tombstones, papier/démo, algorithmes et contrôleurs WS inchangés. Aucun marker modifié, aucun restart requis par ce delta front/PHP.

### H. Tests exécutés et limites

- `php games/web/tests/hub_embed_native_test.php` :27 contrôles, dont slot/lifecycle même E, first_start étranger refusé, reprise sans préparation, découverte read-only et exclusion suspension/retrait/papier/démo.
- `node --test games/web/tests/hub_embed_routing_test.cjs` :3 tests du vrai routeFromControlState extrait ; native ne masque plus le routage, iframe active reçoit la route, fallback historique préservé.
- `node --test games/web/tests/hub_embed_native_ack_test.cjs games/web/tests/hub_embed_poc_test.cjs` :14 tests, consommateurs UI natifs et contrat primaire/bridge existants. Tests serveur ACK secondaires sont de compatibilité de baseline ; le front corrigé n’en dépend pas.
- `hub_embed_native_browser.cjs` sous Chromium local :35 contrôles des vrais host/child/CSS avec frontières PHP/WS et écran Remote simulés. Première préparation, route précoce sans first_start, ACK Remote ignoré, mauvais E/session/génération, Master absent/non-joinable, lobby masqué, transition avant started, même iframe/fullscreen, annulation, takeover, reload open puis transition, reprise sans préparation/START, reload suspendu sans enfant/E nouveau.
- `node games/web/tests/hub_first_launch_contract_suite.mjs` :20/20 suites réussies ; A/B/C, retrait, reset, suspension/reprise, papier/démo et temporisations inchangées.
- Global `hub_client_routing_canonical_test.php`, `hub_remote_control_contract_test.php` :OK ; fonctions de routing non modifiées.
- Lints PHP/JS et diff-check ; aucun test DB/live, aucune recette DEV exécutée par Codex. Les fixtures navigateur ne prouvent pas la fonctionnalité réelle des médias ni tous les contrôles de la Remote sur les trois jeux.

### I–J. Fichiers et documentation

Games seulement pour le code : `web/modules/app_hub_embed_native.php`, `app_hub_remote_ajax.php`, `web/includes/canvas/core/hub_embed_host.js`, `hub_embed_child.js`, `web/includes/canvas/remote/remote-ws.js`. Tests : `hub_embed_native_test.php`, `hub_embed_native_ack_test.cjs`, `hub_embed_native_browser.cjs`, nouveau `hub_embed_routing_test.cjs`. Aucun fichier Global/Quiz/Blindtest/Bingo modifié dans cette passe.

Documentation : présente section AH ; HANDOFF/CHANGELOG, README/TASKS actuels (statut DEV opérateur et contrat corrigé), interfaces actions/Canvas et runbook DEV. AG reste le rapport historique de la livraison initiale. Sitemap/index générés via npm run docs:sitemap.

### K. Recette DEV opérateur courte

Après livraison autorisée des cinq fichiers applicatifs Games :
1. Nouveau Blind Test : Lancer → Master préparation puis ACK/reveal ; Remote compteur puis route canonique et écran opérationnel, aucun lobby ni attente started/ACK Remote. Relever même E et secondary unique.
2. Gameplay puis suspendre → Reprendre : même E ; aucun pregame/compteur/nouveau premier START/reset initial sur Master ou Remote. Remote attend éventuellement le runtime dans le Hub.
3. Reload Remote en open, runtime actif, puis suspendu : retrouve respectivement la préparation du même E puis transition, le runtime sans pregame, ou Hub en attente de Reprendre. Tester Annuler sur une autre vraie nouvelle E opening/open.

Reprendre ensuite la qualification Quiz/Bingo ; ne pas interpréter ces tests locaux comme leur recette DEV.

### L. Logs complémentaires

Aucun rechargement global demandé : les divergences de code sont reproductibles. Si la recette corrigée bloque encore, relever l’heure et l’E, puis fournir uniquement la réponse navigateur `control_poll.client_routing` et les traces console `[hub_embed_native]` du Hub Remote et `remote/state` de son enfant, de Lancer/Reprendre au blocage. Pour vérifier une éventuelle recréation durable non prouvée ici, joindre la réponse launch_session et l’E avant/après. Ces captures sont plus discriminantes que des logs WS sans visibilité sur le navigateur. Aucun chemin de log navigateur persistant n’a été trouvé.

### M. Rollback

Snapshots pré-correctif et delta Games dans `/tmp/cotton-native-fix/before` et `/tmp/cotton-native-fix/delta/games.patch` ; reverse-check effectué, sans appliquer le rollback. Ne pas restaurer les fichiers entiers comportant les travaux antérieurs. Revenir sur ce seul delta réintroduirait les deux défauts ; aucune migration/persistance nouvelle. Aucun déploiement ni restart effectué.

## AI. Reprise Master après suspension — 25/09/2026

**25/09 — Reprise Master après suspension : correctif local, non déployé.** Recette Blindtest Hub354/session27995 : la Remote reprend, le Master refuse. Le garde expected_execution_id exigeait à tort le focus actif, pourtant libéré par suspension. Une suspension canonique terminée du même E officiel numérique réutilisable autorise maintenant ce paramètre ; le chemin historique restaure le focus et le grant, sans nouvel E ni Open Players/START. Exécution discordante/absente et suspension inachevée restent refusées. Régression reproduite avant patch puis corrigée (288 vérifications PHP, effets externes simulés). Recette DEV à refaire ; moteur de décision et instrumentation inchangés.

### Preuves et diagnostic

Préflight privé : `START.md` sur main puis `SITEMAP.ndjson`, `README.md`, `DOCS_MANIFEST.md`, `HANDOFF.md` et cette note sur develop, via `https://api.github.com/repos/cotton-games/documentation/contents/<path>?ref=<branch>`. Journal AI Studio raw consulté : conflit ciblé non trouvé.

Logs rechargés `games/logs/error_log` : suspension Remote à17:04:47 puis reprise historique à17:04:52 ; suspension Master à17:05:08, focus libéré (ligne71780). Tentative Master à17:05:12, profil ligne71800 : runtime_created=false, runtime_already_existed=false, focus_changed=false, redirect_ready=false, Hub354/session27995. Le corps POST et le code erreur de cette réponse sont non trouvés dans ces traces ; l’erreur rapportée correspond au garde reproduit en test.

Le Master envoie expected_execution_id pour Reprendre ; la commande Remote appelle le même service sans ce paramètre. Le garde refusait systématiquement l’attente d’E sans focus actif. Il accepte désormais aussi une suspension `suspended && released` corrélée au même E officiel numérique réutilisable. Cette exception ne transforme pas la suspension en simple rattachement actif : restauration historique du focus, grant et routage maintenus. Aucun nouveau stockage ni changement frontend/moteur.

### Validation et recette

`php games/web/tests/hub_active_resume_test.php` (depuis Cotton) : échec avant correctif sur reprise Master à E concordante, puis288 vérifications réussies. Matrice Quiz/Blindtest/Bingo avant/après première preuve gameplay, Master avec E et Remote sans E, retry, même E, focus restauré, grant conservé, slot/first_start inchangés. Cas négatifs : suspension inachevée, preuve d’un autre E, E absent, attente périmée, absence de preuve canonique. Stockage/runtime simulés ; aucune qualification navigateur DEV revendiquée.

Régressions : `node games/web/tests/hub_first_launch_contract_suite.mjs` →20/20 suites hors ligne ; expiration213 vérifications, routage canonique Remote et contrat Remote verts. Syntaxe PHP valide ; patchs applicatif/test vérifiés réversibles.

Recette : sur Blindtest démarré, suspendre et attendre le retour Hub ; cliquer Reprendre sur Master. Attendu : même E, retour au jeu, aucun nouveau pregame ni START. Répéter via Remote puis Master ; étendre Quiz/Bingo. Aucun log supplémentaire nécessaire avant cette recette.

### Fichiers et rollback

Applicatif : `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php` uniquement. Test : `games/web/tests/hub_active_resume_test.php`. Snapshots avant correction et patchs incrémentaux dans `/tmp/cotton-master-resume` ; ne pas restaurer des fichiers entiers contenant les travaux précédents. Risque ciblé : garde partagé trois jeux, à qualifier en DEV ; retour arrière du seul delta réintroduit le refus Master. Aucun déploiement/restart.

## AJ. Reveal Remote : joinabilité et sortie canonique du pregame — 25/09/2026

**25/09 — Reveal Remote Hub-native : complément local, non déployé.** Premier lancement : joinabilité canonique + sortie explicite du pregame (`starting`, ou closed/started) + Remote secondary courante ; open reste masqué même avec readiness/ancien marqueur accepté. Reprise avec first_start : joinabilité historique, sans nouveau START. L’UI affiche la surface session sans attendre le statut métier ni laisser apparaître le lobby historique. Transport WS/poll existant, traces DEV horodatées, aucune autorité Remote ajoutée. Correctif Master de la section AI conservé ; moteur5/10/5/90 inchangé.

### Audit et causes démontrées

Préflight privé effectué : START main, SITEMAP/README/DOCS_MANIFEST/HANDOFF et cette note develop via GitHub API Contents (`https://api.github.com/repos/cotton-games/documentation/contents/<path>?ref=<branch>`). Journal AI Studio raw consulté : conflit ciblé non trouvé.

1. `boot_organizer.js` écoute `hub/pregame-open`, attend le runtime Organizer prêt puis marque la readiness (`markHubRemoteLaunchReadiness` accepte explicitement phase=open). `app_games_hub_remote_client_routing_policy_resolve` utilise cette readiness pour un runtime neuf ; le routing ajoute la présence/contexte Master. La préparation anticipée peut donc devenir techniquement joignable avant START. C’est une propriété attendue, pas une autorité de départ.
2. Logs rechargés : `games/logs/error_log` lignes71474/71477–71479, Hub354/session27995, présence source=ready et readiness confirmée à17:04:00 Paris ; confirmations ultérieures jusqu’à17:04:15. L’instant navigateur client_joinable/reveal et un START/ACK corrélable à ces lignes sont non trouvés. La chronologie exacte du défaut DEV ne peut donc pas être affirmée à partir de ces seuls logs.
3. Le code local avant complément ne révélait pas sur joinabilité seule : `authorizeRemote` exigeait ready + joinable + firstStartAccepted, puis le child envoyait remote-operational après `remote/state` En cours/Pause/Partie terminée et une frame. Mais aucune phase explicite n’était exigée ; un marqueur accepté mémorisé pouvait autoriser un contexte encore open. Surtout `remote-ui.js` peut conserver son écran d’attente après réception En cours : son handler fait `setAwaitingStart(true); return` avant `setStateDom`, jusqu’au démarrage média. Le statut reçu ne prouvait donc pas que le lobby avait disparu. Ces deux divergences sont corrigées ; ne pas présenter la readiness seule comme cause DEV démontrée.
4. La phase canonique existe déjà : `HUB_PREGAME_STATE` émis par le contrôleur WS, relayé par `remote-ws.js` → `hub/embed-state` → child → host. Le read PHP `hub_embed_state` retourne aussi la phase/version du slot lié à E/session. Aucune nouvelle route ni transport.

### Avant / après et autorité

Avant : joinable + marqueur first_start mémorisé → attente d’un statut métier jugé opérationnel → reveal. Après : contexte natif du même Hub à la création, E/session/génération et URL de routing concordantes, iframe/channel/source/origin courants, registration secondary, joinable, puis phase starting ou closed/started prouvée. Closing/closed removed/retour/abandon restent bloquants. Une reprise explicite avec first_start et descripteur runtime/closed suspended utilise la joinabilité sans attendre START. Les messages WS réévaluent immédiatement la garde ; le poll applique d’abord la phase puis le routing, pour éviter un tour supplémentaire.

Le child déclenche uniquement `hub/embed-joinable`, événement de présentation local existant, puis remote-operational après requestAnimationFrame. `remote-ui.js` sélectionne la surface session et masque le lobby même si le statut métier est encore En attente. Il ne change ni wsState, ni everStarted, ni preuve started ; il n’émet aucun remote/state synthétique, START, commande réseau ou écriture lifecycle. Pas d’ACK Remote ajouté. Le Master reste inchangé : ACK corrélé → reveal.

### Délai théorique et instrumentation

Dans `blindtest/web/server/actions/hubPregame.js`, mutate(start) persiste starting puis publie l’état ; le handler envoie ensuite l’ACK. La transition peut donc être observée avant l’ACK Master. Avec readiness déjà connue : WS + postMessage + une frame de rendu ; aucune attente métier. Sans notification WS : poll natif toutes les1000ms après réponse, donc environ0–1s d’attente de minuterie + requête/traitement + frame, sans borne garantie en cas de réseau lent ou throttling navigateur. Le control_poll parallèle reste1s avec commande en cours,2s sinon,15s caché/erreurs ; il n’est pas le seul canal de readiness puisque hub_embed_state lit également client_routing.

Un ordre strict « Remote après reveal Master » n’est pas garanti par le protocole existant : publication starting précède ACK et ce sont deux navigateurs. Aucun signal supplémentaire n’est introduit. Les traces DEV `[hub_embed_native]` contiennent maintenant timestamp Unix ms, temps performance local, Hub/E/session/génération, `client-joinable`, `pregame-left`, `ack` Master et `revealed` par surface. Aucun token, nom ou payload personnel. Comparer timestamp entre navigateurs avec horloges synchronisées ; performance.at n’est comparable que dans un document. Accès local : `HubEmbedPOC.traces()`.

### Tests et recette

- `node --test games/web/tests/hub_embed_remote_reveal_test.cjs` :10/10. Trois scénarios échouent avec le host avant correction (snapshot via HUB_REVEAL_HOST_SOURCE), puis passent : open même avec marqueur accepté, starting sans attente d’un poll first_start, ordre inverse. Fermeture/retrait, rôle absent, retour, abandon et reprise couverts.
- `hub_embed_native_browser.cjs` :51 vérifications Chromium, host/child/CSS réels et fonction réelle de visibilité Remote (backend/WS simulés). Readiness/open sans reveal ; starting avec révélation sans statut métier ; ordre inverse ; mauvais E/session/génération ; ancien WindowProxy/channel d’iframe après retour puis nouvelle génération ; Master ACK ; reprise ; pas de START Remote. Les fixtures ne chargent pas toute l’application Remote ni un moteur réel.
- 8 tests routing/ACK,27 vérifications PHP natif et288 vérifications reprise passent. Le correctif Master de la section AI est préservé. Aucun changement des moteurs Quiz/BT/Bingo, de l’admission Player ou du moteur START.

Commande navigateur : `PLAYWRIGHT_MODULE=/tmp/cotton-embed-browser/node_modules/playwright PLAYWRIGHT_BROWSERS_PATH=/tmp/cotton-embed-browsers /tmp/cotton-embed-browser/node_modules/node/bin/node games/web/tests/hub_embed_native_browser.cjs` depuis Cotton. Ces chemins sont locaux temporaires.

Recette DEV : nouvelle E Blindtest avec Remote ouverte ; vérifier client-joinable pendant open sans apparition du lobby. Au démarrage canonique, vérifier ACK/revealed Master et pregame-left/revealed Remote, même E/session/génération, rôle secondary. Répéter avec Remote lente (starting avant joinabilité), puis reload/retour et reprise depuis Master et Remote. Reprise : aucun nouveau pregame/START. Relever les quatre timestamps uniquement si le décalage reste visible.

### Fichiers, limites et rollback

Games applicatif : `web/includes/canvas/core/hub_embed_host.js`, `hub_embed_child.js`, `web/includes/canvas/remote/remote-ui.js`. Tests : `web/tests/hub_embed_remote_reveal_test.cjs`, `hub_embed_native_browser.cjs`. README/TASKS canon Games/documentation, note, HANDOFF/CHANGELOG et sitemap mis à jour. Risque : comportement visuel partagé trois jeux, recette DEV réelle restant à effectuer. Le flag visuel natif n’altère pas les surfaces historiques ni papier/démo. Snapshots et delta incrémental sous `/tmp/cotton-remote-reveal` ; rollback du seul patch Games, sans restaurer les fichiers entiers et sans toucher au correctif Global de reprise Master. Aucun déploiement/restart.

## AK. Reprise Master : identifiant E perdu par le rendu des cartes — 25/09/2026

**25/09 — Reprise Master : transmission de E corrigée localement, non déployée.** Le correctif serveur AI était incomplet : les cartes desktop/mobile ne renseignaient data-hub-resume-execution que pour running avec focus, donc une suspension envoyait expected_execution_id=unavailable. Le rendu transmet maintenant la même E pour running actif ou suspendu ; garde serveur AI conservé. Test du vrai rendu PHP en échec avant patch, puis33 vérifications de rendu et18 parcours rendu → action → POST passent ;288 vérifications serveur vertes. Correctif reveal Remote AJ conservé. Aucun déploiement/restart.

### Preuves et correction du diagnostic précédent

Préflight privé START main → SITEMAP/README/DOCS_MANIFEST/HANDOFF develop et cette note via GitHub API Contents (`https://api.github.com/repos/cotton-games/documentation/contents/<path>?ref=<branch>`). Journal AI Studio raw consulté : mention du fichier ciblé non trouvée.

Nouveaux logs Games : `games/logs/error_log` ligne75917 à17:29:29 Paris, HUB_SUSPEND_REQUESTED depuis remote_button, Hub354/E hubexec-e1d9ae684631e1a7c5383a8563d1cafa ; ligne75920, focus libéré session27999. Ligne75954 à17:29:42 : hub_launch_session_profile même Hub/session, runtime_created=false, runtime_already_existed=false, focus_changed=false, redirect_ready=false. Plusieurs messages PHP partagent une même ligne Nginx : lecture de chaque marqueur, sans diffuser les URL/tokens. `global/logs/error_log` consulté (576 lignes, dernière entrée17:29:06) : diagnostic du refus correspondant non trouvé. Les logs d’accès ont été localisés ; ils ne sont pas nécessaires à la reproduction du défaut de rendu. Corps POST de la recette non capturé ; ne pas prétendre l’avoir lu.

Le diagnostic précédent avait corrigé la condition serveur mais manqué la définition du booléen de vue : `$is_running = ($runtime_status === 'running' && $is_focus_active)`. Une session suspendue a runtime_status=running et focus=false : `$is_suspended=true`, `$is_running=false`. Les attributs desktop et mobile ne retenaient que `$is_running` ; l’E connue dans `$open_execution` était donc remplacée par une chaîne vide. Le handler commun traduit cette chaîne vide en `expected_execution_id=unavailable` pour Reprendre, d’où le même refus même avec le garde serveur corrigé.

La nouvelle variable de rendu `$resume_execution_id` accepte running actif **ou suspendu** et conserve les exclusions papier/démo. Elle alimente les deux surfaces. `setAction` desktop et le handler commun restent inchangés. Aucun fallback permissif : E absente → unavailable → refus serveur ; E périmée reste refusée. Aucun changement Global, lifecycle, focus, runtime, moteur START ou reveal Remote sur ce complément.

### Tests et recette

- `php games/web/tests/hub_master_resume_cards_test.php` : vrai `games_hub_render_program`, stockage d’exécution simulé ; échec avant patch «4 suspended: rendered resume E must be hubexec-resume-4», puis33 vérifications vertes. Blindtest/Quiz/Bingo, actif/suspendu/E absent/papier/démo/terminé.
- `node games/web/tests/hub_master_mobile_actions_test.mjs` :18 nouveaux parcours sur HTML réellement produit, fonction `setAction` desktop réelle puis handler POST réel pour desktop/mobile. Aucune injection artificielle de l’E dans les boutons testés ; guards responsive existants conservés.
- `php games/web/tests/hub_active_resume_test.php` :288 vérifications serveur, dont le correctif de suspension AI. Syntaxe PHP valide. Les tests restent hors ligne ; aucune validation runtime DEV revendiquée.

Recette DEV après livraison du fichier Games : actualiser le Master pour remplacer les anciens attributs HTML ; suspendre Blindtest depuis Remote, attendre retour Hub, reprendre depuis Master desktop puis mobile. Attendu : E identique transmise et reprise du runtime existant sans nouvelle préparation/START. Dans DevTools, le POST launch_session doit contenir expected_execution_id=E affichée dans data-hub-resume-execution, jamais unavailable lorsque l’exécution est disponible. Ne pas partager les tokens/URL complets des captures.

### Fichiers et rollback

Games applicatif : `web/modules/app_hub_view_helpers.php` uniquement. Tests : nouveau `web/tests/hub_master_resume_cards_test.php`, extension `web/tests/hub_master_mobile_actions_test.mjs`. Documentation : README/TASKS canon Games/documentation, README racine, note, HANDOFF/CHANGELOG et sitemap. Risque : anciennes pages ouvertes conservent les attributs vides jusqu’à leur rafraîchissement. Snapshots et delta incrémental sous `/tmp/cotton-master-resume-ui` ; reverse-check du patch avant livraison, sans appliquer le rollback. Ne pas annuler le correctif Global AI ni le reveal Remote AJ. Aucun deploy/restart.

## AL. Bingo Hub Remote : authentification native et compteur — 25/09/2026

**25/09 — Hub Remote Bingo : authentification et compteur corrigés localement, non déployés.** Bingo confirme auth_remote par son premier state (ws/registered du connecteur), pas par registrationSuccess. L’adaptateur Games traduit maintenant cet acquittement technique existant en remote/registered secondary ; le pont natif peut devenir prêt. Un unique HUB_PREGAME_STATUS par socket authentifiée récupère le compteur WS même si le bootstrap PHP fournit déjà le pregame ; requête renouvelée au reconnect, pas sur chaque state. Reveal toujours soumis à joinabilité + départ canonique. Moteurs inchangés, aucun START/ACK Remote ajouté. Correctifs reprise Master et reveal précédents conservés.

### Audit et preuves

Préflight privé START main, SITEMAP/README/DOCS_MANIFEST/HANDOFF et cette note develop, via GitHub API Contents. Journal AI Studio raw consulté : conflit ciblé non trouvé. Logs disponibles `bingo.game/ws/server-logs.log` : AUTH_OK Remote client10/game17121 ligne33907 à15:55:46.943Z, puis ligne34079 à15:56:46.436Z (17:55/17:56 Paris). Ces traces prouvent l’authentification moteur ; elles ne prouvent pas le reveal navigateur ni la réception du compteur.

`bingo_server.js` branche auth_remote authentifie, restaure le contexte, installe la socket Remote puis envoie state ; aucun registrationSuccess. `ws_connector.js` reconnaît ce premier state comme confirmation d’authentification de la socket courante et émet déjà ws/registered. L’adaptateur `remote-ws.js` n’écoutait pas ce signal : seul registrationSuccess Quiz/Blindtest produisait remote/registered. Le child natif restait sans runtime-ready ni preuve de rôle secondary, et le host refusait correctement son reveal.

Compteur : le bootstrap PHP fournit le slot pregame sans le nombre de binds WS. La précédente requête Bingo HUB_PREGAME_STATUS était conditionnée à !hubPregame dans le handler state : elle était donc supprimée si le bootstrap avait déjà initialisé le slot. Les broadcasts ultérieurs pouvaient encore fournir le compteur, mais aucun snapshot n’était garanti à la connexion. Le changement demande ce snapshot à chaque authentification réussie, même avec un slot préchargé. Le contrôleur Bingo existant répond à la Remote courante en lecture seule avec count = identités dont la socket est ouverte. On conserve cette définition (binds effectifs), sans lui substituer un nombre d’inscriptions SQL.

### Implémentation et invariants

`remote-ws.js` consomme ws/registered uniquement pour Bingo, ack.ok=true et ack.meta.type=state. Cet événement provient du connecteur qui filtre la socket remplacée ; le document Remote utilise auth_remote. Il le normalise en remote/registered avec rôle secondary, puis demande HUB_PREGAME_STATUS pour l’E courante. Le compteur est reçu via HUB_PREGAME_STATE et le pont existant. La requête répétée dans chaque state est supprimée : un read par authentification/reconnexion, aucun timer ni probe parallèle ajouté.

Aucun changement moteur/serveur/Global, aucune nouvelle autorité : Remote secondaire, pas de START, ACK de départ ou écriture lifecycle. Le signal traité est l’authentification technique déjà existante, pas un nouvel ACK Remote. `open` reste masqué ; `starting` + joinabilité + contexte courant révèle la même iframe. Reprise Master AK et reveal AJ conservés.

### Validation et recette

`node --test games/web/tests/hub_bingo_native_registration_test.cjs games/web/tests/hub_embed_remote_reveal_test.cjs games/web/tests/hub_embed_routing_test.cjs` :16/16. La première régression échoue avant patch faute de remote/registered. Tests du code réel du connecteur et de l’adaptateur, avec transport simulé : bootstrap pregame présent, un read unique, reconnect, aucun START/ABANDON, protocole tiers et mauvais ACK refusés. Contrôleur Bingo réel isolé : snapshot deux binds ouverts sur trois entrées, ancienne Remote refusée, aucune écriture.

Fixture navigateur `hub_embed_native_browser.cjs` :57 vérifications Chromium réussies. Extension : authentification Bingo par premier state réel du connecteur (pas de registrationSuccess fabriqué), normalisation réelle Games, réponse STATUS simulée count17, compteur affiché pendant open et iframe masquée, reveal à starting, même document, aucune commande START. Backend/WS simulés : ce n’est pas une recette DEV.

Recette client10 : après livraison Games, recharger Hub Remote puis lancer une nouvelle session Bingo ; vérifier le compteur dès connexion puis son évolution aux binds, Hub visible pendant open. Au démarrage canonique, vérifier la bascule session sans lobby intermédiaire. Répéter reload Remote pendant pregame, puis reprise. En cas d’échec, relever uniquement les traces HubEmbedPOC.traces() et les types d’événements/phase/count, sans tokens ni données joueurs.

### Fichiers et rollback

Games applicatif : `web/includes/canvas/remote/remote-ws.js` uniquement. Tests : nouveau `web/tests/hub_bingo_native_registration_test.cjs` et modification `web/tests/hub_embed_native_browser.cjs`. Documentation README/TASKS Games/documentation, note, HANDOFF/CHANGELOG et sitemap. Risque : branche d’authentification Bingo différente de Quiz/Blindtest, couverte hors ligne mais à qualifier sur client10. Snapshots/delta dans `/tmp/cotton-bingo-native` ; retour arrière du seul patch Games réintroduit les deux lacunes, sans restaurer les travaux précédents. Aucun déploiement/restart.

## AM. Trois jeux : retour prématuré du child Remote pendant le pregame — 25/09/2026

**25/09 — Hub-native, trois jeux : retour prématuré de l’iframe Remote corrigé localement, non déployé.** Traces navigateur Hub355/session28005 : return-document avant registration/runtime-ready, puis joinabilité et starting arrivent sur une iframe déjà repartie au Hub. Le poll historique de présence Master interprétait son absence pendant la préparation anticipée comme un départ. Il attend désormais l’autorisation native d’affichage avant de contrôler cette présence ; après reveal, absence réelle/terminal/quit conservent leurs traitements. Compteur et reveal continuent sur la même iframe. Adaptateur Bingo AL conservé ; aucun changement moteur/Global/START.

### Preuves : logs et traces navigateur

Préflight privé START main → SITEMAP/README/DOCS_MANIFEST/HANDOFF et cette note develop, via GitHub API Contents ; journal AI Studio raw consulté avant modification (conflit ciblé non trouvé). Jeux audités en lecture seule, aucun patch moteur.

Logs rechargés Bingo : Remote client10/game17123 authentifiée à16:07:56.212Z ;13 PLAYER_WS_BOUND de16:08:01.160Z à16:08:15.906Z. Logs Games : Hub355/session28003, publish accepté à18:07:56 Paris (ligne81111), started accepté à18:08:23 (ligne81324), E hubexec-fc9af8be0b1038bb6c62bb322a61302f. Quiz et Blindtest rechargés montrent également des connexions joueurs ultérieures. Les binds moteur seuls ne prouvent pas la réception des messages par le navigateur ; l’absence de traces de vague dans ces fichiers ne suffit pas à conclure à une absence de binds pregame.

À la demande de diagnostic, l’opérateur fournit les40 dernières traces HubEmbedPOC. Cas session28005/E hubexec-dfb3fdc382e3b7cebb83c520871bdd3e/génération7 :

| Temps relatif du document (ms) | Trace |
| --- | --- |
|297520|mounted|
|298464–298465|bootstrap puis state opening/version17|
|300695|return-document, aucune registration/runtime-ready préalable|
|302552|client-joinable, phase open, après le retour du child|
|320969|pregame-left, starting/version19|
|335382|started-proof/version20 puis returned/canonical_navigation|

La reprise précédente de la session28004/génération6 avait bien produit registration/runtime-ready puis revealed à282763ms. Les gardes de départ et de joinabilité fonctionnent donc dans ce cas ; c’est le child du nouveau lancement qui est déjà parti. Le compteur figé s’explique par l’absence de document Remote vivant pour recevoir les nouveaux états WS. Le contrôleur hôte refuse correctement de révéler un contexte `returned`.

### Cause et correction ciblée

`remote-ui.js::startHubRemotePresencePolling()` appelle check dès le bootstrap ; une réponse runtime_present=false corrélée déclenche HubTransition.redirectRemoteForPresence. Ce contrat historique supposait que la Remote session était ouverte après le Master. Hub-native prépare maintenant le child en amont ; l’absence du Master est alors transitoire et normale. La navigation précoce observée est certaine ; le motif de cette réponse HTTP n’est pas dans les traces fournies, mais cette branche reproduit le défaut avec le code réel de présence et son transport simulé.

Le prédicat busy du poll inclut maintenant `hubEmbedPOC.native && !hubNativeSessionVisible`. Ce dernier flag est fixé par l’événement local existant hub/embed-joinable, après autorisation canonique du host (joinabilité + départ pregame ou reprise + contexte/secondary courants). Aucun read de présence ni navigation par absence pendant l’attente native ; l’observateur redevient actif à son prochain tick existant après autorisation. Aucun timer/transport ajouté. L’authentification, les messages de compteur et le document restent vivants. Absence après reveal, quit, remplacement, suspension et terminal explicites restent sous leurs gardes précédentes. Hors natif (historique, papier, démo), comportement inchangé.

Le correctif Bingo AL normalisait une authentification réellement différente mais ne pouvait pas corriger ce retour commun. Les tests précédents du host/child/visibilité ne chargeaient pas le poll de présence, d’où ce défaut non détecté. Ce complément ne contourne pas la garde returned et ne remonte pas une iframe déjà partie.

### Tests et recette

`node games/web/tests/hub_remote_presence_test.mjs` : échec avant patch (une requête partait malgré iframe native cachée), puis12 combinaisons historiques jeu/mode/papier et3 scénarios natifs verts, avec races erreur/reprise/quit/terminal. Chaque scénario natif vérifie aucune requête avant autorisation, registration insuffisante, reprise du contrôle après autorisation, vraie absence tardive renvoyant toujours au Hub.

Validation complémentaire :59 vérifications Chromium,13 tests admission Remote Bingo/garde de reveal, lecture PHP de présence (TTL/contexte exact/absence/erreur SQL) et syntaxe JS réussis.

La fixture Chromium `hub_embed_native_browser.cjs` charge désormais le vrai poll de présence et reçoit runtime_present=false durant open. Elle maintient la même iframe au-delà d’un tick2s, vérifie l’absence de return-document, fait évoluer le compteur17→21, puis révèle la session au départ canonique. Les transports PHP/WS restent simulés ; ne pas assimiler ces vérifications à la recette DEV.

Recette : après livraison du fichier Games, recharger Hub Remote et lancer successivement une nouvelle E Quiz, Blindtest, Bingo. Vérifier compteur0 puis incréments, aucune return-document pendant opening/open, registration/runtime-ready conservés, bascule à starting + joinabilité. Vérifier aussi reprise et retour au Hub lors d’une vraie absence Master après affichage. Pour comparer, `HubEmbedPOC.traces()` ne doit montrer return-document qu’après un retour réel, jamais avant l’authentification d’un premier lancement.

### Fichiers et rollback

Games applicatif : `web/includes/canvas/remote/remote-ui.js` uniquement. Tests : `web/tests/hub_remote_presence_test.mjs`, `web/tests/hub_embed_native_browser.cjs`. Documentation README/TASKS Games/documentation, README racine, note, HANDOFF/CHANGELOG et sitemap. Pas de modification des moteurs, du compteur serveur, de START5/10/5/90, du routage, des reprises Master ou des permissions. Risque restant : recette DEV des trois jeux ; un child déjà retourné nécessite de recharger la surface après livraison. Snapshots et delta ciblé `/tmp/cotton-bingo-bind` ; rollback du seul patch Games, sans revenir sur les corrections antérieures. Aucun déploiement/restart.

<!-- AUTO-UPDATE:END id="hub-open-players-foundations-20260924" -->
