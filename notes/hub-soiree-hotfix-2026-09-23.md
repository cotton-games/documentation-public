# Hotfix minimal depuis hub_soiree — 23/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-soiree-hotfix-20260923" owner="codex" -->

**Préparation locale puis recette DEV signalée par l’opérateur sur le compte 442 ; audit des copies de logs ci-dessous. Complément PROD : livraison/essai signalés par l’opérateur, incident Player cloclo en cours d’audit (K) ; parité exacte des versions exécutées non attestée. Aucun restart, commit, merge, cherry-pick, accès SSH/DB/DEV/PROD ou navigateur effectué par Codex.** Deux correctifs seulement : admission WS ciblée et continuation tardive de l’intention officielle numérique. Ce document ne livre pas le sas `hub_session_readiness`.

## Préflight et sources

Worktrees propres avant patch. `.git` explicitement en lecture seule dans les permissions de la session : modifications sur les worktrees déjà issus de `hub_soiree`, aucune tentative de contournement. Branche dédiée souhaitée pour une promotion opérateur : `hotfix/hub-soiree-admission-runtime-ready`.

| Dépôt | Branche/HEAD de départ | Intervention |
|---|---|---|
| Games | hub_soiree / 38190ce | PHP, Master/Remote et tests |
| Bingo | hub_soiree / 9788e31 | auth WS, marker |
| Blind Test | hub_soiree / ef1c180 | register WS, marker |
| Quiz | hub_soiree / 69192a2 | register WS, marker |
| Global | hub_soiree / d1f9f15 | audit des helpers, aucune modification |
| Play | hub_soiree / 28b01a5 | aucune modification |
| Pro | hub_soiree / 02e7467 | aucune modification |
| Documentation | develop / c46bae1f | contrat, tâches, rapport et index |

Lectures avant patch : [START RAW, Statut actuel et Discipline de génération](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), [SITEMAP texte RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), [SITEMAP RAW, How to use](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md), [README RAW, Doc discipline](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), [manifest RAW, routing et markers](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), [HANDOFF RAW, Hub E1/readiness](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md). Le journal AI Studio public demandé a été téléchargé et son Markdown extrait de `const raw` : aucun fichier de ce hotfix signalé comme modifié hors workspace. Aucun rechargement serveur ciblé nécessaire d’après ce journal ; cela ne prouve pas la parité des serveurs.

## A. Fichiers modifiés

Games, applicatifs :

- `web/includes/canvas/php/hub_capacity.php` : `canvas_hub_admitted_player_check`, branche `stage=admit` de `canvas_api_hub_capacity_get`.
- `web/includes/canvas/core/hub_runtime_wait.js` (nouveau) : attente persistante et garde par onglet.
- `web/includes/canvas/core/boot_organizer.js` : attente officielle numérique, validation fraîche, continuation unique.
- `web/includes/canvas/core/ws_effects.js` : identité Hub/E1 dans le ready local existant.
- `web/modules/app_hub_view_helpers.php` : `games_hub_autostart_validate`, branche de lecture dans le handler de présence existant.
- `web/modules/app_hub_remote_ajax.php` : ne pas abandonner définitivement l’observation du même routage officiel numérique après son délai technique.

Games, tests :

- `web/tests/hub_hotfix_admission_test.php` (nouveau).
- `web/tests/hub_runtime_wait_test.mjs` (nouveau).
- `web/tests/hub_capacity_runtime_test.cjs` (étendu).
- `web/tests/hub_remote_access_expiry_test.mjs` (étendu).
- `web/tests/hub_active_resume_test.mjs` (fixture enrichie pour le guard officiel).

Bingo : `ws/bingo_server.js`, `version.txt` (`restart 23-09-2026/011`, base `/010`).

Blind Test et Quiz : chacun `web/server/actions/registration.js`, `web/server/restart_serveur.txt` (`restart 23-09-2026/01`). Les markers sont préparés conformément au manifest ; aucun processus relancé.

Documentation : voir G. Aucun fichier applicatif Global, Play, Pro, WWW ; aucune configuration, dépendance npm, migration, grille ou allocation modifiée.

## B. Admission ciblée

Avant : register Quiz/BT ou auth_player Bingo → `hub_capacity_get` → `canvas_hub_capacity_context(..., true)` → synchronisation commerciale/jauge → `app_games_hub_bingo_capacity_ensure` → lecture roster ; stock et verrou global Bingo possibles.

Après, seulement si le runtime WS possède le contexte officiel fiable : même transport service-only `hub_capacity_get`, avec `stage=admit`, Hub/E1/session/Player → validation fraîche lifecycle et exécution courante → SELECT Player/mapping actifs du même Hub, jeu et session → SELECT participation réelle. Aucune entrée dans `canvas_hub_capacity_context`, aucun roster complet, recalcul offre/jauge, allocation/complément stock ou GET_LOCK pour cette validation.

La preuve retourne Hub, session numérique, E1, clé et identité Player, ID participation. Les WS contrôlent sa concordance et leur lifecycle après l’attente réseau ; remplacement/disparition du runtime ou suspension pendant l’appel refusent le bind. Bingo compare aussi la participation au Player réellement authentifié par grille/secret. La lecture de l’état individuel et les protections reset/génération restent inchangées.

Mapping absent, `left`, terminé, mauvaise session/Hub/clé/participation, ancienne E1, Hub inactif/deleting, expiration, retrait ou suspension : refus. Pas de repli permissif sur une preuve négative. Contexte WS officiel incomplet ou absent : capacité historique. Papier exclu du bind numérique ; réponse serveur papier/démo `targeted:false` renvoie au contrôle historique. Aucun nouveau parcours de première admission.

## C. Runtime-ready tardif

Avant : le timer10 s retirait le listener et rejetait la continuation. Un ready à15 s pouvait laisser le WS sain sans aucun autostart ; la Remote pouvait en plus mémoriser un abandon après15 s.

Après : l’attente commune de l’organisateur officiel numérique signale le délai technique sans rejeter la promesse ni retirer le listener. Elle consomme le premier ready du même token/Hub/E1, ou le snapshot déjà publié, et se termine à la fermeture de page. Aucun polling Player, ACK UI ou protocole moteur nouveau.

Avant `beginPlayFlow`, un POST à l’action Master existante `remote_runtime_presence`, `source=autostart_validate`, vérifie côté serveur session/Hub/E1 courants, provenance officielle, activité, fenêtre, expiration, retrait, suspension, terminal et instance/routing. Cette branche ne crée pas de présence et ne déclenche pas de gameplay. Runtime déjà commencé : pas d’autostart. Guards locaux après await et `__playLock` existant conservés.

Une clé sessionStorage `hub_autostart:<hub>:<token>:<E1>` est réservée avant l’unique continuation. Elle empêche le replay automatique de mutations incertaines après reload de cet onglet ; elle n’est pas une autorité serveur. Les guards de reprise déjà commencée et le reset Bingo versionné restent intacts. Une erreur après réservation demande une action explicite de l’organisateur plutôt qu’une nouvelle tentative automatique aveugle.

Master publie la présence et readiness existantes quand le runtime devient disponible, même tard. Remote conserve l’observation du même routage officiel numérique connu du programme serveur ; aucune logique de démarrage distincte. Le routage serveur `joinable` demeure obligatoire, une génération ancienne reste ignorée. Papier, démo et format inconnu gardent leur abandon historique. Pas de sas Remote ajouté.

| Cas | hub_soiree de départ | Hotfix |
|---|---|---|
| Player Hub déjà admis au register/auth | Contrôle global | Preuve serveur ciblée |
| Recalcul capacité global pour ce bind | Oui | Aucun sur le chemin nominal ciblé |
| Stock Bingo atteint pour cette validation | Possible via capacity ensure/GET_LOCK | Non ; auth/grille individuelle conservées |
| Ready <10 s | Départ normal | Départ après fence fraîche |
| Ready >10 s | Continuation perdue | Même E1 reprend si toujours valide |
| Double ready/reconnexion | Promesse initiale unique | Promesse unique et garde reload |
| E1 remplacée | Protections existantes | Ready ancien ignoré/fence refusée ; mismatch conservé |

## D. Extraction de hub_session_readiness

Inventaire effectué avant portage : Games `php/hub_readiness.php` (`canvas_hub_readiness_scope`, `canvas_hub_readiness_admit`), `boot_organizer.js` (abonnement permanent), `hub_preparation.js` (couplé au sas), `ws_effects.js`, `app_hub_remote_ajax.php` ; WS `registration.js` Quiz/BT et `bingo_server.js`. Tests de référence : `hub_readiness_test.php`, `hub_preparation_test.mjs`, `hub_preparation_remote_test.cjs`, `hub_capacity_runtime_test.cjs`, tests hub-readiness moteurs. Leurs fixtures de sas ne sont pas importées.

- **Repris tels quels :** aucun fichier/commit entier. Helpers existants `hub_soiree` de provenance, exécution, expiration, suspension, reset et routage réutilisés sans modification.
- **Adaptés :** vérifications scope/admit et branche WS, découplées de `preparation.version`; ID Hub et participation réelle vérifiés explicitement. Abonnement ready conservé après timeout, isolé du coordinateur composite. Suppression de l’abandon Remote limitée au format officiel numérique déjà connu.
- **Exclus :** module Global preparation et journal/deadline, sas/roster attendu/compteurs/UI, HUB_PLAYER_READY et challenges, ACK/requestAnimationFrame nouveaux, gate composite, incarnation/consume/started, reset pré-sas, runner/instrumentation, cohortes capacité/index publication BT, optimisations auth/state Bingo, correction de la course Quiz, réutilisation générale d’E1 `pending` à la création d’exécution.

Dépendances indispensables : les helpers Global déjà présents sur la base, le transport Canvas service-only existant, le nouveau petit helper d’attente livré avec son import. Aucun module de `hub_session_readiness` nécessaire à l’exécution du hotfix.

## E. Vérifications locales

Depuis `/home/romain/Cotton/games` :

```sh
php web/tests/hub_hotfix_admission_test.php
node web/tests/hub_capacity_runtime_test.cjs
node web/tests/hub_runtime_wait_test.mjs
node web/tests/hub_remote_access_expiry_test.mjs
php web/tests/bingo_reset_test.php
php web/tests/hub_demo_readiness_flow_test.php
node --test web/tests/hub_runtime_wait_test.mjs web/tests/hub_capacity_runtime_test.cjs web/tests/hub_active_resume_test.mjs web/tests/bingo_reset_generation_test.mjs web/tests/hub_runtime_suspension_time_test.cjs web/tests/paper_resume_runtime_test.cjs web/tests/hub_launch_confirmation_test.mjs web/tests/hub_demo_reentry_runtime_test.mjs web/tests/hub_demo_lifecycle_test.mjs
```

Résultats : **133 assertions PHP dédiées**, handlers d’admission réels avec E/S simulées verts ; reprise à3/9/15 s, E1→E2, terminal/expiration/retrait/suspension, répétitions/reconnect/reload, un seul appel au flow (donc aucune seconde demande reset par cette continuation), visibilité/routage Remote tardifs verts. Suite groupée Games **20/20**, incluant72 cas temporels +3 annulations de grâce +3 cutoff ; reset PHP et démo verts. Les tests reset existants couvrent séparément ACK, générations, conservation des grilles, double clic et retry versionné. Aucun résultat ne mesure une charge réelle.

Depuis `/home/romain/Cotton/bingo.game/ws` :

```sh
node --test tests/bingo_reset.test.js tests/hub_suspend.test.js tests/runtime_expiry.test.js tests/remote_continuity.test.js
```

**31/31.** `npm test -- --runInBand` indisponible : `jest: not found`. Pas d’installation de dépendances ; les tests ciblés ci-dessus utilisent `node:test`.

Depuis Quiz et Blind Test :

```sh
# quiz
node --test tests/primary-grace.test.cjs tests/remote-continuity.test.cjs
# blindtest
node --test tests/primary-grace.test.cjs tests/remote-continuity.test.cjs tests/teams-disabled.test.cjs
```

Quiz **25 passent /52 échouent**, BT **26 passent /66 échouent** : fixtures historiques incomplètes (`Unmocked dependency: ./hubCapacity`, `./paperScore`, notamment). Même bilan et erreurs reproduits depuis `git archive hub_soiree tests web/server` dans `/tmp/cotton-hotfix-baseline/{quiz,blindtest}`. Aucun correctif hors périmètre appliqué à ces fixtures. Les tests ciblés Games exécutent les vrais handlers Quiz/BT ; les suites suspension/reprise et Remote complètent cette couverture, sans déclarer les suites historiques entièrement vertes.

`php web/tests/hub_remote_contract_test.php` : trois assertions statiques historiques en échec (placement QR, ordre du resolver papier, sortie Remote) ; mêmes trois échecs sur une copie `hub_soiree` intacte. Les tests comportementaux Remote ciblés passent. Suite finale admission/attente/reprise/Remote : **5/5** via `node --test web/tests/hub_runtime_wait_test.mjs web/tests/hub_capacity_runtime_test.cjs web/tests/hub_active_resume_test.mjs web/tests/hub_remote_access_expiry_test.mjs web/tests/hub_remote_return_execution_test.mjs`. Le remplacement E1→E2 pendant la validation asynchrone et le replay du snapshot ready déjà publié sont également couverts.

Lints PHP/JS sur tous les applicatifs modifiés ; `git diff --check` par dépôt. Documentation : `npm run docs:sitemap`, liens/blocs AUTO-UPDATE et index générés vérifiés. Pas d’accès DB indispensable à la préparation ; aucune requête SQL opérateur nécessaire à ce stade.

## F. Non-régressions et recette restante

- Papier : pas de bind/register Player requis ; tests de reprise papier réels des trois moteurs, conservation grilles/scores, timer Remote historique.
- Démo : limite2 via capacité historique, tests lifecycle/réentrée/readiness ; aucun sas ni nouvelle attente de roster. Game Master automatique non modifié.
- Officiel numérique : admission ciblée, refus frais, fallback incomplet/non-Hub ; ready tardif borné à la même E1 valide.
- Master : une continuation, fence et garde reload ; contrôles historique lancement/reprise préservés.
- Remote : présence readiness tardive et navigation unique après délai ; anciennes générations, absence, retour, suspension et démo testés.
- Bingo/BT/Quiz : auth/register réels simulés ; reset et lifecycle existants inchangés. `HUB_EXECUTION_MISMATCH` strictement intact dans les trois fichiers lifecycle.

Recette opérateur avant promotion : session officielle numérique fraîche par moteur ; retarder le ready organisateur à3/9/15 s, vérifier un seul départ et un reset initial Bingo ; reconnect/reload ; remplacer E1 ou suspendre/terminer avant ready et constater zéro départ ; Remote ouverte avant délai ; Player admis avec grille correcte et compteur d’appels capacité lourde nul pour son auth/register. Puis papier et démo, dont GM automatique. Tests manuels non réalisés ici.

## G. Documentation

HANDOFF, README général, CHANGELOG, DOCS_MANIFEST, état de livraison ; README/TASKS Games/Bingo/BT/Quiz ; bridge/actions, write-map Bingo, entrypoints, runbook DEV et pm2-ws. Ajouts dans les blocs AUTO-UPDATE existants, IDs conservés. Le rapport est séparé de celui du chantier complet ; sitemap/index générés par `npm run docs:sitemap`.

## H. Limites, livraison et rollback

`hub_capacity_get` **sans stage** reste utilisé aux probes, hydratations, auth organisateur et autres contrôles ; les preloads/inscriptions PHP et événements stock restent historiques. Le hotfix élimine le détour lourd du bind WS officiel prouvé, pas toute contention du système. Les SELECT lifecycle peuvent eux-mêmes être ralentis par la DB ; ni TTL, ni cache d’admission, ni optimisation de charge introduits.

Le sas Player complet n’est pas livré ; aucune attente de tous les Players. Course Quiz du chantier complet non traitée. Contrat E1/E2 général non refondu : un autre lancement explicite remplaçant E1 rend le ready ancien invalide. `HUB_EXECUTION_MISMATCH` conservé.

Le garde reload est par onglet ; l’autorité entre surfaces reste l’instance Master/routing et les protections serveur historiques. Pas de nouveau verrou distribué de gameplay. Stockage navigateur indisponible ou validation fraîche inaccessible : refus conservateur d’autostart, pas de replay de mutations incertaines. Une erreur après la réservation de la continuation peut demander une action manuelle ; ce lot ne résout pas les échecs arbitraires au milieu du gameplay. Aucun changement de schéma ni write durable d’intention supplémentaire.

Livraison future à coordonner : Games PHP (`stage=admit` et fence Master) avant activation des WS modifiés ; JS Master et son helper dans le même lot, avec WS-effects et Remote. Ne copier que les fichiers applicatifs listés en A, jamais les versions complètes de la branche readiness. Un ancien Games ne sait pas produire de preuve targeted ; les WS hotfix refusent cette réponse au lieu d’autoriser silencieusement. Recette/restart restent des opérations opérateur distinctes.

Rollback futur : revenir aux fichiers de base de A, en remettant les WS historiques avant ou avec Games. Les tests/docs peuvent être retirés avec ce lot ; régénérer sitemap/index. Aucune donnée DB à restaurer. Les clés sessionStorage ne sont plus lues par la base ; aucune purge DB ni reset supplémentaire.

## I. Recette DEV compte 442 / Hub 349 — audit des logs du 23/09

**Validation fonctionnelle partielle : les quatre sessions atteignent le gameplay, mais ni le parcours tardif >10 s ni le gain de l’admission ciblée ne sont démontrés par ces traces. Lenteur du second Bingo observée ; régression par rapport à avant le hotfix non établie.** Audit en lecture seule des copies locales, sans modification applicative ni lancement de charge.

### Sources et méthode

`games/logs/{access_log,error_log}`, `global/logs/{access_log,error_log}`, `bingo.game/ws/server-logs.log`, `quiz/web/server/server-logs.log`, `blindtest/web/server/server-logs.log` et rotations disponibles. Les fichiers portent le nom `server-logs.log` (sans second « s »). Fenêtre examinée : 17:17–17:22 le 23/09, Europe/Paris ; WS en UTC, conversion +02:00. Les dernières traces sont à 17:22:32 pour Games,17:22:03 pour Global,17:22:36.446 pour Bingo,17:20:41.690 pour Quiz et17:22:25.088 pour BT.

Games associe les sessions 27967–27970 au client 442 et au Hub 349 ; Global confirme notamment le branding de ce compte pour les deux Bingo (`global/logs/error_log:82` et`:102`). Les hôtes et la base nommés dans les logs sont DEV. Pas d’empreinte de version serveur disponible. Les heures PHP/access ont une précision à la seconde, sans `request_time` : les écarts entre surfaces sont approximatifs et ne mesurent pas directement le clic utilisateur. Certaines lignes FastCGI sont tronquées ; une absence de diagnostic n’est pas une preuve d’absence d’appel.

### Résultats par session

| Session | Commande / lancement Games | Organisateur WS | Preuve de gameplay | Players uniques liés au WS |
|---|---|---|---|---|
| Bingo 27967 / playlist 17111 | Remote 725 à 17:17:42, traitement17:17:44 |17:17:51.408 | reset17:17:54.603 ; playing index0 à 17:17:56.289 |30 : 27 bots  + 3 autres |
| Quiz 27968 | Remote 726 à 17:19:39, traitement17:19:40 |17:19:44.808 | première question/countdown17:19:59.403 ;27 réponses traitées et 24 persistances de score OK |30 : 27 bots  + 3 autres |
| Bingo 27969 / playlist 17112 | lancement Master17:20:45 |17:20:56.528 | reset17:21:06.476 ; playing index0 à 17:21:11.557 ; premier TRACK_START index1 à 17:21:19.153 |30 : 27 bots  + 3 autres |
| Blind Test 27970 | Remote 727 à 17:21:51, traitement17:21:52 |17:21:58.256 | premier extrait/countdown17:22:13.175 ;10 réponses traitées et 1 persistance de score OK |29 : 26 bots  + 3 autres |

Les comptes uniques dédupliquent les reconnexions par `player_id`, sans assimilation à un nombre de Players simultanés. HubBot-001 n’a pas de bind BT dans cette capture ;30/30 BT n’est donc pas validé. Le nombre de scores persistés n’est pas censé égaler le nombre de réponses : seuls les événements observés sont rapportés.

Sources WS : Bingo`:17038,17079,17107,17799,17841,17897,17986` ; Quiz`:25538,25858,25865` ; BT`:16763,17025,17028`. Les trois commandes Remote reçoivent `hub_remote_game_readiness_confirmed` (Games error`:5749,6480,7139`). Bingo et Quiz réutilisent leur exécution lors des reprises17:18:50 et17:20:18 (Games error`:6131,6637`). Un seul `SESSION_RESET` réussi par session Bingo est journalisé. Cela ne démontre pas à lui seul l’unicité de tous les appels front `beginPlayFlow`.

### Où se situe la lenteur Bingo ?

**Précision opérateur : le symptôme concerne l’affichage effectif du Master et le début du compte à rebours/jingle, pas l’arrivée du premier morceau.** Les jalons de lecture ci-dessous servent uniquement à la chronologie ; ce ne sont pas des mesures du premier affichage.

La réponse HTML Master est journalisée environ 3 s après le traitement du lancement Bingo27969 (`games/logs/access_log:13687`), contre 2 s pour Quiz (`:13334`) et 3 s pour BT (`:14228`). Ces écarts grossiers ne sont pas des durées HTTP, mais n’indiquent pas un délai de 20 s pour servir le HTML Bingo.

**Différence concrète du parcours d’affichage, vérifiée dans le code local :**

1. `games/web/organizer_canvas.php:670–678` applique `data-hub-transition-pending="master_launch"` et `visibility: hidden` à tout le body lors du lancement Hub.
2. Après runtime-ready et validation Master fraîche, `boot_organizer.js:1750–1756` attend spécifiquement `ensureBingoStartReset()` pour Bingo. Quiz/BT n’ont pas cette attente de reset.
3. `session_sync.js:119–146` n’accepte le reset que sur réception du `reset_ack` correspondant ; il possède un timeout d’erreur de 15 s, pas une temporisation nominale de 15 s.
4. Le compteur d’introduction est déclenché après cette attente (`boot_organizer.js:1766`), puis la levée normale du masque après acceptation du handler (`:1786`, helper`:859`, `hub_transition.js:145–160`). Les chemins d’erreur/timeout peuvent lever le masque plus tôt.

Sur27969, **environ 18,5 s séparent le HTML servi (17:20:48) du reset accepté côté serveur (17:21:06.476)**. Sur le chemin nominal, l’interface reste donc masquée pendant les attentes qui précèdent cet ack ; c’est une explication cohérente du contraste visuel rapporté avec Quiz/BT. L’instant réel où le navigateur reçoit l’ack et retire le masque n’est pas enregistré dans cette capture : ne pas annoncer 18,5/21,5/26,6 s comme une mesure exacte du premier affichage.

Le masque, son helper et `session_sync.js` sont identiques à la base `hub_soiree` ; la base de `boot_organizer.js` attendait déjà le reset avant l’introduction et la levée du masque. Cette asymétrie n’est donc pas créée par le hotfix. En revanche, toute attente supplémentaire avant/pendant le reset prolonge son effet visible. Pour qualifier la régression ressentie, la mesure prioritaire devient **navigation→HTML→runtime-ready→validation→envoi reset→ack→retrait du masque/paint**, en distinguant l’attente front de la file WS. Une éventuelle dissociation entre affichage du Master et autorisation du gameplay serait un changement de comportement séparé, non appliqué dans cet audit.

Pour27969, depuis le lancement journalisé à 17:20:45 :

| Étape | Heure Paris | Écart approximatif depuis le lancement |
|---|---|---|
| Page Master servie HTTP200 |17:20:48 |3 s |
| Hydratation serveur des 5 Players déjà présents |17:20:54.420 →56.527 |durée2,107 s |
| Auth organisateur terminée |17:20:56.528 |11,5 s |
| Présence runtime `source=ready` reçue par Games |17:20:59 |14 s |
| Reset accepté |17:21:06.476 |21,5 s |
| État lecture index0 |17:21:11.557 |26,6 s |
| Premier morceau index1 journalisé |17:21:19.153 |34,2 s |

Le profil interne du lancement PHP ne prend que 73 ms (`games/logs/error_log:6767`) ; cela n’inclut pas tout le chargement de page. Le reset Canvas ne prend que 404 ms, 407 ms mesurés par son appelant (`bingo.game/ws/server-logs.log:17839`). Une lecture lifecycle prend 1,211 s juste avant l’hydratation (`:17785`). Le premier Bingo avait une hydratation de 116 ms et un reset Canvas de 596 ms : le second reset API lui-même n’est pas plus lent. Auth→reset passe de 3,195 s à 9,948 s ; reset→playing de 1,686 s à 5,081 s. Les délais intermédiaires ne sont pas instrumentés assez finement pour désigner une cause unique.

Le code local conserve une file par partie qui sérialise authentifications/commandes avec lectures `reset_state` avant et après (`bingo.game/ws/bingo_reset.js:48`, appels dans `bingo_server.js:748,849`). Cette file est identique à `hub_soiree` ; les authentifications des bots s’intercalent avant le reset. **Contention des chemins historiques sous arrivée des Players : hypothèse à mesurer**, pas preuve d’un temps de queue précis. La validation HTTP fraîche ajoutée avant autostart n’a pas de durée dédiée dans la capture ; sa contribution reste également inconnue.

Le helper local `hub_runtime_wait.js:15` résout dès réception d’un ready concordant : le seuil 10 s est un diagnostic, pas une pause imposée de 10 s. Les logs ne contiennent pas les événements front `HUB_MASTER_RUNTIME_WAIT_DELAYED`/`HUB_MASTER_AUTOSTART_*`, ni le début exact de cette attente. Le délai total >10 s ne valide donc pas automatiquement le scénario de ready tardif. Le gameplay conserve également son introduction historique ; `playing index0` et premier morceau sont deux jalons distincts.

Un redémarrage WS Bingo est journalisé à 17:18:06.444 (`:17225`, deux événements pour un même démarrage), suivi de réauthentifications et réhydratation des 30 Players. Cause du redémarrage inconnue dans ces fichiers. Il survient après le premier autostart, ne peut expliquer le retard initial de 27969 et rend le premier essai impropre à une comparaison avant/après contrôlée.

### Anomalies et portée de la recette

- **59 HTTP409 `grid_cells_sync / bingo_reset_stale`**, tous avec referer `test_bots.php` : 15 sur 27967 entre 17:19:08–10 et 44 sur 27969 entre 17:21:20–31 (`games/logs/error_log:6285–6302,6960–7026`). Le code local du harnais ne mémorise pas `bingo_reset_generation` sur `state/reset_game` et ne l’envoie pas dans ses deux écritures de cases (`games/web/test_bots.php:637,1786,1914,2018`). Ce fichier est strictement identique à la base `hub_soiree`. Les observations concordent avec cette incompatibilité préexistante du harnais ; les payloads déployés ne sont pas capturés. Les grilles des bots ne sont pas validées comme persistées ; aucun de ces 59 refus n’a un referer Player humain. Ils surviennent après le reset et ne sont pas l’explication de son attente initiale. Ne pas désactiver la protection de génération.
- À la suspension Bingo17:19:15–16 :3 `AUTH_FAIL / HUB_SESSION_SUSPENDED` côté WS et 3 HTTP409 `grid_hydrate / hub_session_suspended` côté Games, cohérents avec la protection attendue. Quatre messages WS `mainPlayerStarted` inconnus apparaissent aussi pendant les lectures/reprises ; ils n’empêchent pas les transitions `playing` constatées.
- Quiz :8 `WS_REG_SESSION_NOT_FOUND` avant création runtime 17:19:44.555, puis inscriptions réussies ; BT :2 avant création17:21:57.054. Bruit de démarrage/retry présent. Quiz présente aussi 2 `WS_PLAYER_NOT_FOUND` lors de sa reprise. Aucun de ces événements ne permet de conclure à un rejet de la preuve ciblée.
- Dans toute la fenêtre access Games : 2419 HTTP200, 62 HTTP409 (59 stale  + 3 suspension), 23 HTTP499. Les 499 correspondent à des requêtes abandonnées par le client ; sans durée/payload, leur contribution n’est pas quantifiable. Global : 30 HTTP200. Aucun HTTP 5xx, PHP fatal/warning, SQLSTATE ou timeout upstream trouvé dans cette fenêtre des copies Games/Global. Les nombreuses lignes nginx `[error] ... PHP message` sont surtout des diagnostics applicatifs.
- Aucun payload `stage=admit` ni compteur d’appels stock/capacité ne figure dans ces captures. Les binds réussis ne suffisent pas à certifier le contournement du calcul global en DEV. Retrait/expiration/E1 remplacé, vrai ready retardé volontairement, reload après timeout, papier/démo et absence de double continuation restent des scénarios dédiés à exercer ; conserver les résultats unitaires de E comme preuves locales distinctes.

Suite de qualification : capture front Master horodatée et réseau sur nouvelle session Bingo, avec versions servies identifiées, d’abord sans bots puis avec la même cohorte ; mesurer ready→validation fraîche→envoi reset→réception/queue WS→ack→lecture. Vérifier le Player humain séparément du harnais qui nécessite une correction de génération hors présent audit. Aucun élargissement du hotfix effectué.

Documentation actualisée : cette note, HANDOFF, TASKS Games/Global/Bingo/Quiz/BT, README général et statut de livraison ; `npm run docs:sitemap` et `git diff --check`. Aucun test applicatif relancé pour cet audit de logs seul ; aucun rollback applicatif nécessaire. Pour annuler l’audit, retirer seulement ses ajouts documentaires puis régénérer les index.

## J. Procédure opérateur pour fermer les réserves

Procédure préparée, **non exécutée dans le navigateur ni déployée par Codex**. Réaliser en DEV avec le compte442, des sessions officielles numériques neuves et un Player humain déjà admis ; garder le Master visible et une Remote sur un autre appareil. Commencer sans bots pour isoler le hotfix de l’incompatibilité du harnais. Vérifier que les fichiers de A, dont le helper nouveau, sont effectivement servis/exécutés. Relever jeu, session, E1, heure Paris et résultat pour chaque essai.

### Retard contrôlé du vrai ready

Sur une page Master DEV de préparation, ouvrir Chrome DevTools, Network, trouver `ws_effects.js`, clic droit **Override content**, choisir un dossier local dédié et autoriser son accès, puis enregistrer la modification suivante. Cette substitution reste dans le navigateur et persiste aux navigations tant que DevTools et les overrides sont actifs ; [procédure officielle Chrome](https://developer.chrome.com/docs/devtools/overrides). Ne pas modifier le fichier serveur pour ce test.

Dans `publishOrganizerRuntimeReady`, remplacer uniquement les trois lignes finales qui publient le snapshot, le Bus et le log par :

```js
console.info('[RECETTE] ready réel retenu', new Date().toISOString());
window.setTimeout(() => {
  console.info('[RECETTE] ready délivré', new Date().toISOString());
  try { window.__CANVAS_ORGANIZER_RUNTIME_READY__ = detail; } catch {}
  Bus.emit('organizer/runtime-ready', detail);
  emitWsEffects('organizer_runtime_ready', detail);
}, 15000);
```

Le snapshot **et** l’événement doivent être retardés ensemble, sinon la relecture du snapshot contourne le test. Le payload est celui du vrai runtime, sans fabrication d’E1 ou de preuve. Ce test retarde la disponibilité du ready pour l’autostart, pas le transport WS lui-même. Ne pas utiliser de pause debugger de15 s : elle suspend aussi le timer que l’on cherche à dépasser.

Pour rendre la preuve du timeout visible même si Logger n’exporte pas ces événements, créer également un override de `boot_organizer.js` et ajouter `console.warn('[RECETTE] timeout 10 s franchi', new Date().toISOString());` au début du callback `onTimeout` du helper `waitForRuntimeReady`. Ne changer aucune condition ni durée de ce callback. Activer Preserve log dans la Console et Network.

Revenir au Hub puis lancer **une nouvelle session**. Ne pas réutiliser la session de préparation déjà démarrée : le garde de continuation est conservé en sessionStorage. Faire un premier essai via Master, puis un essai neuf via Remote, pour chacun des trois jeux. À chaque navigation, vérifier que l’override de `ws_effects.js` est appliqué et que les deux messages RECETTE apparaissent.

Critères de réussite :

- Le message de timeout apparaît **avant** le message de ready délivré ; sinon le dépassement de10 s n’a pas été exercé et l’essai n’est pas concluant.
- Ne cliquer ni sur Play, ni sur Relancer, ni sur Recharger pendant l’attente. Le jeu démarre automatiquement après livraison du ready, sans intervention et sans nouvelle E1. Ne pas exiger15 s pile depuis le clic : le retard commence lorsque le runtime réel est prêt.
- Le POST Master `remote_runtime_presence` avec `source=autostart_validate` réussit pour la même session/E1. Observer les événements `HUB_MASTER_AUTOSTART_ACTION_COMMITTED`/`ACTION_ACCEPTED` si exportés ; sinon conserver la trace Network/WS et les marqueurs locaux.
- Un seul départ initial et un seul jingle ; Bingo : un seul `SESSION_RESET` réussi. Remote finit par accéder à cette même exécution malgré le délai, sans nouvelle commande de lancement.
- Une fois le jeu démarré, réémettre deux fois le **même** événement local avec le snippet ci-dessous : aucune seconde introduction/reset. Recharger ensuite ce même onglet : la reprise historique peut afficher Pause ; elle ne doit pas rejouer l’initialisation.

```js
const { Bus } = await import('@canvas/core/bus');
const ready = window.__CANVAS_ORGANIZER_RUNTIME_READY__;
if (!ready?.ready) throw new Error('Aucun ready réel à rejouer');
Bus.emit('organizer/runtime-ready', ready);
Bus.emit('organizer/runtime-ready', ready);
```

Sur un autre essai neuf, suspendre la session depuis la Remote pendant le retard, puis laisser arriver le ready : **zéro départ tardif pour cette exécution suspendue**. Tester séparément le remplacement par une autre session/E1 : l’ancien ready ne doit jamais démarrer l’ancienne exécution. Si la navigation détruit l’ancien document, cela prouve l’annulation par navigation, pas à elle seule le rejet d’un événement périmé dans un document survivant ; les tests automatisés couvrent cette garde.

### Preuve d’admission ciblée

L’appel `hub_capacity_get(stage=admit)` est serveur WS→Games, invisible dans Network navigateur. Une reconnexion Player réussie seule ne prouve pas le chemin employé. Sur les versions DEV identifiées, prévoir une trace temporaire du résultat de cette branche dans `games/web/includes/canvas/php/hub_capacity.php`, à la place de son `return canvas_hub_admitted_player_check(...)` direct :

```php
$result = canvas_hub_admitted_player_check($pdo, $payload);
error_log('[HOTFIX_RECIPE_ADMIT] '.json_encode([
    'game' => $payload['game'] ?? null,
    'session_id' => $result['session_id'] ?? null,
    'execution_id' => $payload['execution_id'] ?? null,
    'player_ref' => substr(hash('sha256', (string) ($payload['player_id'] ?? '')), 0, 12),
    'ok' => $result['ok'] ?? false,
    'targeted' => $result['targeted'] ?? null,
    'error' => $result['error'] ?? null,
]));
return $result;
```

Cette instrumentation est décrite ici seulement, **non ajoutée à l’applicatif**. Garder le contexte `if (($payload['stage'] ?? '') === 'admit')` inchangé. Elle ne nécessite pas de modifier Global ni de journaliser cookies/secrets/service-token.

Avec l’organisateur prêt, recharger uniquement l’onglet du Player déjà admis, puis corréler sa trace `ok=true,targeted=true` et le bind WS réussi sur la même session/E1, dans chacun des trois jeux. Vérifier grille/état/score conservés selon le jeu et absence de participation supplémentaire. Si la trace est absente ou `targeted=false`, le chemin voulu n’est pas prouvé. Vérifier aussi le refus d’une identité retirée ou d’une session suspendue via les contrôles opérateur existants.

La preuve d’absence de recalcul associe cette trace DEV à la vérification des versions exécutées et aux tests ciblés : le retour de la branche `stage=admit` précède `canvas_hub_capacity_context`, et les handlers WS validant `targeted=true` sautent le fallback lourd. **Ne pas exiger zéro appel capacité sur toute la page** : probes, organisateur et hydratations peuvent encore utiliser le chemin historique. Pour une mesure dynamique exhaustive, ajouter une corrélation par requête/handler et des compteurs aux helpers lourds ; leur simple total global mélange les flux.

Depuis le dépôt Games, les vérifications locales reproductibles sont :

```sh
php web/tests/hub_hotfix_admission_test.php
node --test web/tests/hub_capacity_runtime_test.cjs web/tests/hub_runtime_wait_test.mjs
```

Attendu :133 assertions PHP et2 fichiers Node verts ; les stubs font échouer tout appel stock/capacité lourd sur l’admission ciblée et vérifient les vrais handlers WS. Ces tests étaient verts lors de la préparation ; ils ne remplacent pas l’essai DEV.

### Fin de recette et retrait

Conserver les logs front, les traces serveur corrélées et le tableau des essais (jeu/session/E1, mode Master ou Remote, timeout vu, départ unique, refus périmé, preuve targeted). Retirer la trace PHP temporaire après collecte, désactiver les deux Local Overrides puis recharger le Master. Vérifier un lancement neuf sans retard, puis les contrôles papier/démo de F. Aucun reset de DB ni effacement global de sessionStorage nécessaire.

## K. PROD client10 — Player cloclo bloqué le 23/09 vers18:00

**L’opérateur confirme un essai en PROD après livraison du hotfix : Master fonctionnel, mais cloclo seul reste sur « La partie démarre… ». Incident Player non résolu ; ne pas extrapoler la validation Master aux Players.** Audit des copies locales uniquement, aucun correctif applicatif, restart ou accès serveur réalisé par Codex.

Sources rechargées : `bingo.game/ws/server-logs.log` jusqu’à18:03:08.174, `bingo.game/logs/access_log` jusqu’à18:06:26 après second rechargement et `error_log` inchangé. **Les deux fichiers `games/logs/{access_log,error_log}` font0 octet lors de cet audit.** Les erreurs PHP des inscriptions/grilles ne sont donc pas disponibles. Les archives rechargées ensuite ont été décompressées en lecture seule : `error_log-20260923.gz` contient18936 lignes du22/09 à12:28:32 au23/09 à03:10:26 ; `access_log-20260923.gz` contient60128 lignes jusqu’au23/09 à03:12:06. Elles ne couvrent donc pas les essais de18 h. L’opérateur indique ne pas disposer de logs plus frais. Heures ci-dessous en Europe/Paris, WS converti depuis UTC+00.

| Partie Bingo (ID playlist, pas ID session Games) | Organisateur connecté | Reset / lecture index0 | Binds Players observés |
|---|---|---|---|
|18008 |18:01:05.122 |18:01:05.758 /05.963 |froufou18:00:39.793 ; Remo18:00:41.350 ; aucun bind cloclo |
|18009, premier lancement |18:01:45.894 |18:01:46.450 /46.635 |froufou18:01:45.558 ; Remo18:01:46.968 ; aucun bind cloclo |
|18009, reprise après suspension |18:02:41.009 |pas de nouveau reset ; lecture index1 à18:02:55.004 |froufou18:02:47.726 et Remo18:02:48.198 reconnectés ; **premier bind cloclo18:02:49.348**, participation21936 |

Sources : WS`:24320,24333,24339–24345,24359–24376,24380,24393–24404`. Le runtime hydrate3 participations à chaque premier lancement (`:24338,24362`), mais cela ne prouve pas3 sockets Players : seuls2 binds sont présents avant les suspensions. Le compteur3 ne vaut donc pas preuve de connexion de cloclo. Un restart WS apparaît à17:57:08 avant les essais ; aucun restart pendant ces deux lancements.

Aucun `AUTH_FAIL`, `AUTH_MAX_PLAYERS`, `HUB_ADMISSION_UNAVAILABLE` ou `HUB_EXECUTION_MISMATCH` journalisé dans cette fenêtre du WS. Les trois erreurs `mainPlayerStarted` inconnu concernent le Master et surviennent après le début de lecture ; elles n’expliquent pas à elles seules l’absence du bind cloclo. Les connexions courtes inconnues peuvent inclure les sondes normales `checkSession` : ne pas les attribuer individuellement au Player sans corrélation. Les logs HTTP Bingo ne montrent pour ces essais que des upgrades `/ws/` HTTP101 ; ses erreurs nginx sont des accès racine/config interdits antérieurs, sans rapport démontré.

### Mécanisme d’affichage et limite du diagnostic

Le parcours Bingo local réalise `player_register` puis `grid_assign` et, pour l’auto-inscription Hub, `grid_hydrate` avant de publier `player/ready` qui ouvre l’auth Player WS (`games/web/includes/canvas/play/register.js:2598,2699,2760,2807`). L’hydratation peut échouer après5 tentatives (`:1866–1943`). L’absence initiale de bind oriente donc vers ce parcours préalable ou son démarrage côté navigateur ; elle ne prouve pas laquelle de ces étapes a échoué.

**Défaut d’exposition des erreurs confirmé dans le code :** le catch d’inscription écrit dans `#error-message` (`register.js:2976–2986`), qui appartient à `#register-screen` (`player_canvas.php:863`). Or le contexte Hub masque ce parent avec `display:none !important` (`player_canvas.php:693–697`), tandis que « La partie démarre… » est l’écran d’attente (`:907–912`). `releaseHubAutoRestore` retire seulement l’attribut de transition ; il ne retire pas le contexte Hub qui masque le formulaire. Le changement de gate peut aussi effacer le texte d’erreur (`register.js:857`). Ainsi une erreur de préparation/inscription peut rester invisible et laisser un écran d’attente trompeur. C’est un mécanisme compatible avec le symptôme, **pas la preuve d’une erreur PHP précise pour cloclo**.

La cause initiale reste indéterminée sans les copies Games non vides ou les réponses Network/front de cloclo. Ne pas conclure à un manque de grilles, un rejet d’admission du hotfix ou une régression du reset à partir de cette seule capture. Faute de journaux Games plus frais disponibles selon l’opérateur, prochaine preuve utile : lors d’une reproduction sur le Player cloclo, conserver Console et Network, relever les réponses `player_register`, `grid_assign`, `grid_hydrate`, ainsi que les messages WS avant le blocage. Cela permettra de distinguer échec API, absence de démarrage du bootstrap et problème d’application du state sans attribuer arbitrairement la panne au hotfix.

Documentation : note/HANDOFF/TASKS Games et Bingo, statut de livraison/README général ; index/sitemap régénérés et `git diff --check`. Audit seul, aucun test applicatif ni rollback applicatif nécessaire.

## L. Exploration des courses du bootstrap Player Bingo

**Deux défauts reproduits dans le code actuel, sans modifier l’applicatif.** Ils rendent crédible un blocage initial suivi d’une reprise réussie. Leur présence est démontrée par exécution isolée du code ; leur déclenchement exact pour cloclo reste non prouvé faute des traces PHP/front de18 h.

### L1. L’échec transitoire peut devenir une attente sans nouvelle tentative

L’auto-inscription Hub lance `form.requestSubmit()` puis retourne aussitôt : sa promesse indique le démarrage de la soumission, pas la fin des appels API (`register.js:1227,1309,3007–3020`). Le polling peut donc observer la session OPEN pendant que `player_register`/`grid_assign`/`grid_hydrate` sont encore en cours.

Ordre reproduit avec un échec transitoire simulé :

1. Une soumission Bingo est en cours ; les gardes Hub sont positionnées.
2. Le polling reçoit OPEN, mémorise cette clé et positionne l’UI sur OPEN. L’auto-inscription est déjà en cours, donc aucun doublon n’est lancé.
3. La soumission échoue ensuite. Le catch remet les gardes Hub àfalse et relit le statut : il obtient encore OPEN (`:2980–2995`).
4. `setUiState(OPEN)` retourne immédiatement puisque l’UI est déjà OPEN (`:825–830`). Il n’atteint donc pas le mécanisme `bootHubAutoRegister('gate_open_restore_guard')` (`:896–907`).
5. Les contrôles périodiques continuent de réussir, mais le polling ne traite que les **changements** de clé active/full (`:3075–3084`). Aucun nouveau submit n’est lancé tant que le statut reste identique.

Le Player peut ainsi rester non inscrit au WS bien que le serveur soit désormais disponible. Même erreur injectée **avant** la première observation OPEN : nouvelle tentative immédiate. Un changement de clé réarme également une tentative ; sa réussite reste soumise à la disponibilité et aux protections serveur. Une navigation de reprise recrée le bootstrap. Ce comportement est compatible avec le contraste lancement/reprise, sans nécessiter une identité invalide.

Le scénario exige ici un premier échec transitoire : le diagnostic ne prétend pas avoir reproduit un blocage sans événement déclencheur. L’opération initialement en échec peut être réseau ou API ; elle n’a pas été identifiée dans les logs PROD. L’erreur peut ensuite être masquée par le défaut d’affichage décrit en K.

### L2. Deux sondes WS simultanées : le second appel ne se termine jamais

`tryConnectWebSocket()` raccorde les appels concurrents à `_wsProbePromise` (`register.js:1719–1723`), mais crée cette promesse avec un exécuteur vide (`:1750`). `finish()` résout seulement la promesse du premier appel, puis efface la référence partagée. Aucun chemin ne résout la promesse sur laquelle attend le second appel.

Reproduction : lancer deux sondes simultanément ; une seule socket est créée. Envoyer un `sessionStatus` valide : première sonde résolue, seconde toujours pending. Refaire avec le timeout de5 s de la première : même résultat. Le second appel n’a pas son propre timeout, puisqu’il retourne depuis la branche concurrente. Le polling et le catch d’inscription sont notamment deux appelants susceptibles de se chevaucher. Ce défaut peut donc bloquer une continuation même quand le serveur répond normalement.

### Vérifications, limites et correction envisagée

L’ordre des modules écarte la piste simple d’un listener `player/ready` chargé trop tard : `player_canvas.php:770–774` charge `play-ws`, puis `play-ui`, puis `register`, et le listener WS est installé au niveau du module (`play-ws.js:1624`). L’absence initiale de bind ne démontre donc pas à elle seule un événement Bus perdu. Aucun refus d’auth WS n’a été reproduit par les deux scénarios ci-dessus : ils se situent dans le bootstrap et la récupération côté navigateur.

`register.js` et `player_canvas.php` sont **identiques octet pour octet à38190ce**, la base Games avant le hotfix. Ces défauts ne sont pas introduits par les modifications d’admission WS/attente Master ; leur manifestation peut varier avec l’ordre des réponses.

Reproduction conservée dans [scripts/diagnostics/bingo-player-init-race.mjs](../scripts/diagnostics/bingo-player-init-race.mjs). Elle extrait les fonctions et branches du fichier réel, simule DOM/WS/API/timers, et exécute six cas. Ce diagnostic caractérise des défauts connus : son succès signifie « défaut reproduit », **pas « applicatif corrigé »**. Il ne remplace pas un essai navigateur et ne teste ni SQL ni le vrai réseau.

```sh
node scripts/diagnostics/bingo-player-init-race.mjs
```

Résultat observé : sondes concurrentes bloquées après réponse et après timeout ; une seule soumission lorsque la première est encore en cours ; échec tardif sans retry après trois polls OPEN réussis ; nouvelle tentative après changement de gate ; même échec précoce relancé immédiatement. Assertions toutes satisfaites, sortie0.

Correction ciblée à préparer séparément : partager la vraie promesse de résultat entre les sondes ; donner à la reprise après échec transitoire un déclenchement explicite qui ne dépend pas du changement d’UI/gate, avec une seule tentative active et conservation des identités/idempotences ; rendre l’erreur visible dans la scène Hub. Ne pas relancer aveuglément les erreurs métier définitives ni contourner suspension, retrait ou changement d’exécution. La correction devra transformer ces reproductions en tests du comportement attendu et conserver les témoins sans double soumission.

Fichiers de cette exploration : script de diagnostic dans documentation, cette note, HANDOFF, TASKS Games/Bingo et règle de routing correspondante ; index/sitemap régénérés. Aucun fichier applicatif, marker, DB, processus ou serveur modifié ; retrait du script/doc seulement pour annuler cette exploration.

## M. Incident PROD Hub 298 du 24/09 — audit sans patch du 25/09/2026

**Verdict global : non concluable avec les données disponibles pour la cause initiale des trois échecs.** Le mismatch explique très probablement les échecs Organizer tardifs de 30996 et 30993, mais leur attribution reste indirecte. Il ne démontre pas la cause des premiers lancements. Aucune proposition de correctif tant que cette distinction n’est pas résolue.

### Périmètre et preuves

- Code lu exclusivement par `git archive hub_soiree` dans `/tmp/hub298-audit/code`, sans checkout ni modification applicative : Games `eaf053953234da42ef4bac578aa38d7b8ccceb2f`, Bingo `a62ebad9dfa4504fdfca8674e5fcd51b80a61974`, Global `d1f9f15b26d57f35675b325385544087329777fa`. Les copies de travail `pregame`, modifiées, ne sont pas les sources de cet audit. `hub_session_readiness` non utilisé comme comportement PROD.
- Archive `logs_2026_09_24.zip`, SHA256 `781c556c7c240f129d85d600c6646af0f55caddef888908a0744742db75cd84d`. Elle contient `server-logs.2.log`, et non un fichier littéralement nommé `server-logs.2(1).log`. Couverture WS : rotation2 du16/09 au23/09 21:32Z ; rotation1 du23/09 21:32Z au24/09 23:29Z ; courant jusqu’au25/09 12:01Z. Les références ci-dessous portent sur les fichiers extraits ; `.gz:L` signifie ligne L après décompression, sans retrait de lignes.
- Navigation privée authentifiée effectuée sur `main` puis `develop`, START → SITEMAP → manifest → README/HANDOFF et pages ciblées. [START main](https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=main), [SITEMAP main](https://api.github.com/repos/cotton-games/documentation/contents/SITEMAP.ndjson?ref=main), [SITEMAP develop](https://api.github.com/repos/cotton-games/documentation/contents/SITEMAP.ndjson?ref=develop), [manifest develop](https://api.github.com/repos/cotton-games/documentation/contents/DOCS_MANIFEST.md?ref=develop), sections « Update triggers » hotfix23/09 et « Historical analysis ». Le sitemap main ancien utilise `title`/URL legacy ; lecture des pages effectuée sur l’API privée, pas sur le miroir.
- [État de livraison main](https://api.github.com/repos/cotton-games/documentation/contents/canon/deployment-status.md?ref=main), sections « Référence au22/09 » et « Hotfix23/09 » : livraison déclarée par l’opérateur ; parité exacte des serveurs non attestée. Cette page et les notes hotfix23/09, reprise09/09 et robustesse18/09 sont identiques entre les lectures main/develop. Les README Games/Bingo/Global diffèrent avec les travaux DEV exclus ; aucun de ces écarts n’est assimilé à la PROD. Les stacks du24/09 correspondent aux lignes882/1102/3721 du snapshot Bingo.
- Journal AI Studio `documentation/general/0_ROADMAP.md` lu via le lecteur indiqué dans START ; Markdown extrait de `const raw`, HTML non exécuté. Mention de modification hors workspace des fichiers du parcours audité : **non trouvé**. Les modifications externes listées concernent WWW, marketing/AI Studio et d’autres bibliothèques ; aucune copie serveur n’a été prétendue rechargée.

### Chronologie Hub 298

Toutes les heures ci-dessous sont **Europe/Paris, UTC+2** ; les JSON WS sont en UTC. `GE` = Games `error_log-20260925.gz`, `GA` = Games `access_log-20260925.gz`, `BA` = Bingo `access_log-20260925.gz`, `W` = Bingo `server-logs.1.log`. Les E sont désignées par leur préfixe distinctif, présent en entier dans les URL de GA.

| Heure du24/09 | Session / playlist | Preuve et portée |
|---|---|---|
| 19:01:20 → 19:01:25 | 30993 / 18022 | Création exécution, profil `runtime_created=true`, `runtime_already_existed=false`, `redirect_ready=true` (GE1072). GET Organizer200 avec `hub_execution=hubexec-58f35f9a…` (GA6213). Contrôle accès `offer_ok=1`, `can_launch=1`, `preparation=0` (GE1084). |
| 19:01:28.540 → 19:06:31.213 | 30993 / 18022 | 48 `PLAYER_WS_BOUND`, 8 identités distinctes. Premier bind W14186. Six `WS_SEND_NO_PRIMARY_ORGANIZER`, tous `organizer_open_count=0`, `remote_present=false` (W14192,14232,14248,14261,14317,14723). Aucun AUTH_OK Organizer/reset/gameplay identifié pour cette session. |
| 19:02:29 → 19:05:06 | 30993 / 18022 | Reload avec E initiale :499 (GA6505). Plusieurs URL `/master/<token>` sans contexte :302 (GA6533,6592,6605,6715,6803,6827,6930,7059). Un302 n’est pas une tentative `auth_client`. |
| 19:06:33 → 19:06:35 | 30996 / 18025 | Nouvelle exécution (GE1827), GET Organizer200, E `hubexec-5abf0663…` (GA7747), accès autorisé (GE1843). |
| 19:06:37.046 → 19:06:40.872 | 30996 / 18025 | Trois binds / trois identités (W14832,14845,14856). Aucun Organizer ouvert à19:06:37.997 (W14838). |
| 19:07:07 → 19:07:10 | 30994 / 18023 | Nouvelle exécution (GE1898), GET Organizer200, E `hubexec-794e220d…` (GA7880), accès autorisé (GE1912). Reload même E à19:07:39 :200 (GA7983). |
| 19:07:12.773 → 19:08:24.213 | 30994 / 18023 | Sept binds / quatre identités. Premier W14900 ; absence Organizer W14902 et14952. |
| 19:08:27 → 19:08:32 | 30996 / 18025 | Autre exécution créée (GE2046), GET200 avec E différente `hubexec-d6fd57d8…` (GA8174). À19:08:34.077, premier mismatch de cette séquence : **Player**, pas Organizer (W14995). Attribution de ce Player à18025 non portée par l’erreur. |
| 19:09:17 → 19:09:21 | 30994 / 18023 | Autre exécution créée (GE2154), GET200, E `hubexec-6fb64dcc…` (GA8394). Aucune erreur **Client authentication failed** identifiable dans cette fenêtre. |
| 19:18:46 → 19:18:52 | 30996 / 18025 | Troisième exécution visible (GE3020), GET200, E `hubexec-bc3ffd89…` (GA10695), IP193.252.191.125 / Chrome154. |
| 19:18:54.856 → 19:19:31.800 | Organizer non identifié dans W ; 30996 fortement corrélé | Sept `Client authentication failed / HUB_EXECUTION_MISMATCH`, W15944,15950,15957,15962,15970,15976,15981. BA769–775 : sept upgrades101, même IP/Chrome, mêmes secondes de fin que les fermetures1008. Reconnexions espacées d’environ5–8s. |
| 19:54:11 → 19:54:14 | 30993 / 18022 | Autre exécution créée (GE5436), GET200, E `hubexec-7d9e3020…` (GA16304), même IP / Firefox156. |
| 19:54:16.777 → 19:54:54.123 | Organizer non identifié dans W ; 30993 fortement corrélé | Huit erreurs Client mismatch (W16522,16530,16536,16541,16548,16553,16559,16566). BA802–809 : même IP/Firefox et mêmes secondes que les fermetures1008. GA16312–16425 : requêtes Canvas périodiques dont le referer désigne cette nouvelle E de30993. |

Sur le24/09 complet : **184 AUTH_FAIL avec ce mismatch, dont169 Player et15 Client**. Les15 Client sont exactement les deux séries tardives ci-dessus. Entre19:00 et19:08, cinq AUTH_FAIL Player portent `HTTP_409 / hub_execution_invalid`, erreur différente, et aucun AUTH_FAIL Client. Les événements `SESSION_PLAYER_COUNT` étiquetés `role=organizer` ne prouvent pas une socket Organizer : ce sont des publications à destination de ce rôle.

Les sept profils de lancement montrent l’acceptation et la préparation HTTP du Hub, avec `game_api_called=false` ; `runtime_created` décrit ici la création de contexte d’exécution, **pas l’authentification d’un Organizer WS**. Aucun reset ni gameplay retrouvé pour les trois game_id ou leurs sid dans l’ensemble des rotations. Les timestamps des access logs WS peuvent correspondre à la fin de connexion ; ils sont comparés aux fermetures, pas pris pour l’heure de début du handshake.

Les premières requêtes Player `GET /play/bingo/<sid>` correspondantes sont des200 : 18022 à19:01:22 (GA6195), 18025 à19:06:35 (GA7745), 18023 à19:07:10 (GA7884). Elles précèdent bien les premiers binds WS de chaque playlist.

### Parcours exact du code `hub_soiree`

Références de lignes des snapshots Git cités ci-dessus, chemins relatifs à chaque dépôt :

1. **Master / Remote → lancement** : Games `web/modules/app_hub_view_helpers.php:2951–2978` traite `action=launch_session` et appelle `app_games_hub_session_launch_from_master(...)`. Remote `web/modules/app_hub_remote_ajax.php:1236` soumet la commande ; `games_hub_handle_master_remote_launch_command()` (`app_hub_view_helpers.php:3753–3800`) la claim, passe en processing et appelle le même service avec `remote-command-<id>`. Les traces de cet incident ne permettent pas d’inventer un command_id Remote pour chaque clic.
2. **Création E1** : Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php:10195` sérialise le lancement ; fonction `_locked`, décision de réutilisation à10313, commit focus à10420, `execution_context_create(..., !$can_reuse_runtime_execution, ...)` à10449. La création (`:4423–4472`) génère `hubexec-…` et insère `game_events.action='hub_execution_started'` avec Hub, source/runtime, mode officiel et transition. Officiel : source_session_id=runtime_session_id, le token et la playlist de la session sont conservés.
3. **URL / bootstrap** : Games `web/organizer_canvas.php:100–156,753` expose `AppConfig.hubOrganizer` : Hub, executionId, sourceSessionId/runtimeSessionId, runtimeMode, routingGeneration et resumeToken. La reprise explicite est validée ; l’URL fraîche porte `hub_launch=1&hub_execution=…`. `boot_organizer.js:1344` émet `session/init`. `core/ws_effects.js:204–283`, `ensureWSBoot()`, récupère le token du DOM, la playlist et `AppConfig.idClient`, puis appelle `bootWS`.
4. **Payload Organizer Bingo exact construit** (`ws_effects.js:251–263`) :

```js
{
  type: 'auth_client',
  hubLifecycle: {
    execution_id: AppConfig.hubOrganizer?.executionId,
    source_session_id: AppConfig.hubOrganizer?.sourceSessionId
      ?? AppConfig.hubOrganizer?.currentSessionId,
    runtime_session_id: AppConfig.hubOrganizer?.runtimeSessionId,
    resume_token: AppConfig.hubOrganizer?.resumeToken || ''
  },
  id_client: AppConfig.idClient,
  token,                           // organizer-root.dataset.token
  is_demo: String(!!session.isDemo),
  ...(playlistId ? { id_playlist_client: playlistId } : {}),
  date: Date.now(),
  max_players: meta?.maxPlayers ?? 200
}
```

`hub_runtime_authority.js:14–17` construit le sous-objet ; les propriétés undefined disparaissent à la sérialisation. `ws_connector.js:155–198,442–455` crée la WebSocket puis envoie ce JSON à l’ouverture. Ce payload est retrouvé dans le code, **pas capturé dans les logs fournis**.

5. **Identification WS** : Bingo `ws/bingo_server.js:1098–1102` → `BingoService.authenticateClient(id_client, token, repository)` → `ws/repository/db/db_client_repository.js:15–35`. La playlist vient du JOIN `championnats_sessions.id_produit` / playlists, filtré par `s.id_securite=token` ; le champ `id_playlist_client` du message ne choisit pas ici le runtime. Puis `restoreHubRuntime(playlist, token, ws, message.hubLifecycle || {})`.
6. **Mémoire et lecture attendue** : `bingo_server.js:3715–3723` réutilise l’objet de `hubRuntimes[gameID]` si `current.id === sessionId`. Si autre sid et suspension conservée : `HUB_RUNTIME_COLLISION`, erreur distincte. Le lifecycle (`ws/hub_lifecycle.js:8–33`) appelle `stage:'read'`. Le callback (`bingo_server.js:206–207`) envoie `canvasWrite('hub_lifecycle', {stage:'read', game:'bingo', sessionId:runtime.id}, runtime.origin)`.
7. **DB attendue** : Games `web/includes/canvas/php/hub_lifecycle.php:4–25`, `canvas_api_hub_lifecycle()`, retrouve la session par token, son Hub, puis `app_games_hub_execution_context_get_open($hub,$session,false)`. Global `:4370–4421` lit les événements started/completed/removed par id décroissant ; le dernier started autoritaire non clôturé est retenu. Le `false` désactive le filtre de focus. Provenance officielle vérifiée (`:4342`), expiration/fenêtre contrôlées ; retour de l’identité officielle.
8. **Bind seulement après restore réussi** : `bingo_server.js:1156–1190` journalise AUTH_OK et installe `clients.set(ws, client)` ; le contexte de socket n’est attaché qu’ensuite (`:1208`). Le catch (`:1267–1280`) journalise AUTH_FAIL sans sid/game_id/socket_id et ferme1008. Aucun bind Organizer ni état initial n’est envoyé après ce mismatch. L’attente runtime-ready et `ensureBingoStartReset()` (`boot_organizer.js:1009,1753`) sont en aval ; le hotfix d’attente ne répare pas une authentification refusée.

### Ce que signifie exactement le mismatch

Un seul générateur littéral de `HUB_EXECUTION_MISMATCH` retrouvé dans Games/Bingo/Global audités : `bingo.game/ws/hub_lifecycle.js:15–17` :

```js
result.execution?.runtime_mode === 'official'
&& result.execution.execution_id
&& runtime.hubExecution?.execution_id
&& runtime.hubExecution.execution_id !== result.execution.execution_id
```

La valeur « présentée » au garde est **l’E du runtime en mémoire Node**, installée par une restauration antérieure — éventuellement une authentification Player (`bingo_server.js:882`), Paper (`:1052`) ou Remote (`:1292`). La valeur attendue est **l’E officielle relue via le bridge et les game_events**. L’E `message.hubLifecycle.execution_id` du navigateur n’est pas comparée dans ce garde ; elle sert notamment à la reprise suspendue, plus bas dans le lifecycle. Aucun autre générateur de ce libellé trouvé côté PHP ; ses refus d’identité sont notamment `HUB_EXECUTION_INVALID`, distincts. Le libellé est propagé par restoreHubRuntime vers le catch Organizer ; la file d’auth/reset visible dans la stack ne prouve pas qu’un reset a eu lieu.

Après le throw : ancienne E conservée, `hubLifecycleFailed=true`, loading remis àfalse, mutations gelées par `frozen()`. La nouvelle auth n’efface pas cet objet. Le connecteur tente de nouveau (base5s, compteur remis àzéro à chaque ouverture réseau : `ws_connector.js:60,131–168,296–315`) avec son objet auth ; reload du navigateur n’efface pas la mémoire Node. Le reset normal n’est pas une récupération accessible avant auth. Une autre identité de runtime ou son éviction peut changer le résultat ; aucun effacement/restart n’est prescrit ni effectué.

**Reproduction isolée**, module lifecycle réel du snapshot, bridge simulé en mémoire : restauration initiale E1 réussie malgré contexte navigateur ancien ; lecture E2 sur même runtime avec contexte navigateur E2 → mismatch ; retry → même erreur, E1 conservée ; nouvel objet runtime → E2 acceptée. Cela démontre le mécanisme, pas les valeurs mémoire de PROD.

| Variante demandée | Résultat de l’audit |
|---|---|
| E navigateur périmée seule | Ne déclenche pas ce garde ; d’autres fences/bootstrap/reprise peuvent refuser le contexte. |
| E1 mémoire ancienne, E officielle remplacée | Déclenche exactement le garde, même avec navigateur frais. Les URL prouvent plusieurs E pour chacune des trois sessions. Valeurs mémoire PROD non journalisées. |
| Focus changé seul | Ne suffit pas : lecture lifecycle avec filtre focus désactivé, Maps par game_id. Les playlists18022/18025/18023 sont distinctes. |
| Retour à une session déjà initialisée par Players | Peut retrouver sa vieille E en mémoire. Nouveau lancement peut produire une autre E si la session n’est pas réutilisable côté métier. |
| Reprise officielle déjà running | Protection de réutilisation existante ; autre chemin que le premier démarrage resté pending. |
| Reload/navigation Master | Peut réexécuter le bootstrap ; ne purge pas le runtime WS. Les URL nues302 observées ne prouvent aucun auth. |
| Séquence30993→30996→30994 | Ne suffit pas à produire un mismatch entre ces trois Maps. Les retours30996 puis30994 puis30996 puis30993 remplacent effectivement les E persistées visibles dans les URL. Pas besoin d’une course simultanée pour le scénario mémoire/DB. |
| Course de restauration | `serial()` sérialise le lifecycle par objet ; la DB peut néanmoins changer entre deux appels. Aucune course simultanée démontrée ici. |

### Corrélation : forte, mais pas une clé de jointure

Pour les15 erreurs Client, la stack pointe explicitement `performBingoAuthentication:1102` : **des Organizer ont bien envoyé auth_client**. La coïncidence répétée sur sept puis huit connexions, l’IP réelle, le user-agent distinct Chrome/Firefox, les URL Master avec E et les appels Canvas depuis ces pages rendent leur attribution à30996/30993 très probable.

Mais AUTH_FAIL n’a ni session, ni Hub, ni game_id, ni ws client id, ni IP/UA ; les lignes WS voisines exposent seulement les adresses du proxy `::1`/`::ffff:127.0.0.1` et l’origine commune Games. L’access log Bingo donne l’IP/UA, mais `/ws/` n’identifie pas la session et aucun identifiant partagé ne joint ces fichiers. Même IP/UA ne prouve pas le même onglet. **L’attribution certaine des AUTH_FAIL aux trois game_id n’est donc pas acquise.** Les169 erreurs Player ne doivent surtout pas être reclassées Organizer.

Réponses aux six questions clés :

1. **Auth Organizer pour chacune des trois sessions ?** Pages Organizer200 pour les trois, mais auth_client non prouvé individuellement. Très probable tardivement pour30996 et30993 ; non établi pour30994, ni pour les premiers essais.
2. **Auth rejetée en mismatch ?** Oui pour15 Organizer anonymes dans W ; très forte corrélation pour les deux reprises tardives, aucune preuve directe par session.
3. **Où disparaît l’Organizer initial ?** Dernière étape prouvée : accès PHP autorisé et réponse200 du document ; première étape manquante : auth_client/bind WS. Les logs ne localisent pas davantage entre exécution JavaScript, ouverture réseau et authentification. Ne pas inventer une erreur JS, un blocage de popup ou une CSP.
4. **Origine ?** Pour les erreurs portant ce libellé, divergence mémoire WS / lecture officielle démontrée par le code et les stacks. Remplacement serveur après runtime initialisé par Players très probable pour les reprises concernées ; navigateur périmé direct et focus seul ne sont pas les comparaisons de ce garde. Origine des échecs initiaux non résolue.
5. **Déjà couvert ?** Non pour la variante candidate « E mémorisée par Players, runtime métier pas encore running, relancement avec nouvelle E » ; les protections historiques ci-dessous ont d’autres conditions.
6. **Pourquoi possible malgré les correctifs ?** Réutilisation Global conditionnée à `runtime === 'running'`, tandis qu’un Player peut déjà installer `runtime.hubExecution` avant Organizer/reset/gameplay. Le nouveau lancement force une E lorsqu’elle n’est pas réutilisable ; restore garde l’ancienne E du même couple playlist/token et refuse la nouvelle. Le runtime métier pending exact lors des clics reste à confirmer en DB/historique.

### Historique utile, sans assimiler les scénarios

| Date / commit présent dans hub_soiree | Surface, intention et limite |
|---|---|
| 04/09 Global `d31032d8` | `app_games_hubs_functions.php`, `app_games_hub_official_execution_is_reusable` (:1606–1625) : exécution ouverte et runtime **running**, indépendante du court TTL de présence ; reprise hors focus conservant l’E. Ne couvre pas un runtime métier pending seulement initialisé dans le WS par Players. |
| 09/09 Global `c2ea04c` + Games, [note reprise active](https://api.github.com/repos/cotton-games/documentation/contents/notes/hub-active-master-resume-2026-09-09.md?ref=main), « Chaîne auditée et corrigée » | Master numérique actif/running : véritable commande de reprise, expected_execution_id, aucune création de secours en cas de contexte incohérent ; correction du lien nu302. Fichiers Global fonctions Hub ; Games helpers/Organizer/boot et tests cités dans la note. Ne garantit pas le premier auth d’un nouveau lancement pending. |
| 11/09 Global `40f73ff` / Bingo `dc574b2` | Suspension/reprise persistée, resume_token ; Global requalifie en running une session pending avec lifecycle de suspension établi (:3099–3107). Les simples binds Players sans suspension ne satisfont pas ce cas. |
| 18/09 Bingo `591bc17` / Global `0fbb78c` | Le diff Bingo **introduit** le garde exact dans `ws/hub_lifecycle.js` ; identité officielle et protection contre changement d’exécution, pas récupération d’un runtime orphelin. [Note robustesse18/09](https://api.github.com/repos/cotton-games/documentation/contents/notes/bingo-hub-resume-robustness-2026-09-18.md?ref=main), sections B/D : correction de génération de présence après reprise et continuité/takeover Remote. Une génération de routage ancienne n’est pas une E ancienne. |
| 23/09 Games `eaf0539` / Bingo `a62ebad` | Hotfix admission **Player** ciblée et attente **Organizer** runtime-ready tardive ; Games hub_capacity, hub_runtime_wait, boot/ws_effects, helpers/Remote ; Bingo auth Player dans bingo_server. Garde lifecycle inchangé. Cette note, sections C/H, dit explicitement que le remplacement E conserve le mismatch. Aucun recovery de l’auth Organizer ajouté. |

Correctif historique qui capturerait précisément `HUB_EXECUTION_MISMATCH` pour recréer/rebinder automatiquement le runtime Organizer : **non trouvé** dans les branches/historiques audités. Les messages de commits génériques « hub_soiree » ne prouvent ni l’intention fine ni le déploiement ; conclusions tirées des diffs et notes, livraison seulement déclarée dans l’état de livraison.

### Données manquantes et SQL de lecture

La DB est nécessaire pour préciser les transitions persistées et l’état métier ; elle ne restituera pas à elle seule la mémoire WS ni le contenu auth_client. Exécuter dans phpMyAdmin, sur la base applicative concernée, uniquement ces lectures :

```sql
SELECT id, id_client, id_type_produit, id_produit, flag_controle_numerique,
       flag_session_demo, date, heure_debut, heure_fin
FROM championnats_sessions
WHERE id IN (30993,30994,30996)
ORDER BY id;

SELECT s.id AS games_session_id, e.id, e.event_id, e.game,
       e.action, e.created_at, e.payload_json
FROM championnats_sessions AS s
JOIN game_events AS e ON e.session_id = s.id_securite
WHERE s.id IN (30993,30994,30996)
ORDER BY e.id;

SELECT * FROM jeux_bingo_musical_playlists_clients
WHERE id IN (18022,18023,18025)
ORDER BY id;
```

La deuxième lecture conserve les événements antérieurs à l’incident pour ne pas masquer une E initiale, une clôture ou une suspension. La troisième donne l’état courant, pas une preuve de l’état historique. Conserver les résultats dans le périmètre privé ; les payloads peuvent porter des identités.

**Conclusion DB suspendue en attendant ces résultats.** Il manque aussi la console/HAR des premiers lancements, et une corrélation WS incluant session/game_id et valeurs E mémoire/DB au refus, si elle a été capturée ailleurs. Les copies exactes des fichiers exécutés permettraient d’attester la parité PROD ; aucune dérive hors workspace spécifique détectée dans le journal AI Studio.

Validation effectuée : inventaire et décodage des rotations, extraction chronologique JSON/HTTP, comparaison des sources Git, lecture des diffs historiques, reproduction lifecycle isolée décrite plus haut. Aucun test applicatif connecté, accès DB, patch, bump marker, commit, restart ou déploiement. Consignation documentaire seulement ; aucun contrat canonique d’application changé. Périmètre d’un futur correctif **non proposé**, cause initiale non démontrée.

<!-- AUTO-UPDATE:END id="hub-soiree-hotfix-20260923" -->
