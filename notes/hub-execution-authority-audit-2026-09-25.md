<!-- AUTO-UPDATE:BEGIN id="hub-execution-authority-audit-20260925" owner="codex" -->
# Autorité d’exécution Hub — audit Bingo / Quiz / Blind Test, 25/09/2026

**Conclusion : les trois moteurs sont non conformes au contrat cible strict demandé, pour des chemins différents.** La création persistée d’E reste dans l’orchestration Master commune. En revanche, Bingo permet à Player/Paper/Remote d’installer l’E locale avant Organizer ; Quiz/BT ne le font pas dans `registerPlayer`, mais une Remote peut initialiser l’E d’une session mémoire laissée par un enregistrement primaire échoué. Quiz/BT ne verrouillent pas non plus le passage d’une socket Player au rôle primaire ni toutes les mutations de l’état runtime au propriétaire primaire.

Ce classement porte sur le **contrat cible de la demande**, pas sur une nouvelle règle canonique déjà livrée. Aucun classement qualitatif entre moteurs. Mécanismes démontrés sur les snapshots ; aucune nouvelle attribution certaine des AUTH_FAIL du Hub298. Aucun patch applicatif ou test ajouté aux applications, aucun marker, commit, restart ou déploiement.

## Sources et méthode

Navigation privée START → SITEMAP → DOCS_MANIFEST déjà effectuée dans cette session ; README/HANDOFF et pages ciblées consultés. Références exactes : [START main](https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=main), [SITEMAP develop](https://api.github.com/repos/cotton-games/documentation/contents/SITEMAP.ndjson?ref=develop), [manifest develop](https://api.github.com/repos/cotton-games/documentation/contents/DOCS_MANIFEST.md?ref=develop), « Update triggers » et « Historical analysis ». [État de livraison main](https://api.github.com/repos/cotton-games/documentation/contents/canon/deployment-status.md?ref=main), « Référence au22/09 » et « Hotfix23/09 » : livraison déclarée, parité serveur non attestée. Les README [Quiz main](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/quiz/README.md?ref=main) et [BT main](https://api.github.com/repos/cotton-games/documentation/contents/canon/repos/blindtest/README.md?ref=main), « Hotfix hub_soiree », ont été relus ainsi que les mêmes chemins `?ref=develop` : les sections readiness DEV ne sont pas utilisées comme PROD. Compléments : [audit Hub298, section M](hub-soiree-hotfix-2026-09-23.md#m-incident-prod-hub-298-du-2409--audit-sans-patch-du-25092026).

Journal AI Studio raw relu via l’URL START, `documentation/general/0_ROADMAP.md`, Markdown extrait de `const raw` : identique à la lecture précédente ; modification hors workspace des fichiers d’autorité concernés **non trouvée**. Aucun rechargement serveur prétendu. Les modifications de travail locales en cours, y compris les évolutions documentaires parallèles, sont conservées et ne servent pas de source applicative.

Snapshots `git archive hub_soiree` dans `/tmp/hub298-audit/code` ; toutes les lignes applicatives ci-dessous se rapportent à ces versions :

| Dépôt | SHA |
|---|---|
| Games | `eaf053953234da42ef4bac578aa38d7b8ccceb2f` |
| Global | `d1f9f15b26d57f35675b325385544087329777fa` |
| Bingo | `a62ebad9dfa4504fdfca8674e5fcd51b80a61974` |
| Quiz | `b3d1419dd3cc830ed15d9f728e5cc5a4d142fbd8` |
| Blind Test | `9b898ae6b7522b1f1113cca6a170bc3cf51612b2` |

`hub_session_readiness` n’a pas été utilisé. Vérifications : recherche des writers/créations, lecture dispatch et lifecycle, blame/diffs Git, exécution des modules registration et lifecycle réels dans un harnais Node isolé avec bridge/stockage/sockets/timers simulés. Aucun réseau applicatif ni DB. Commande locale rejouable tant que les artefacts temporaires existent : `node /tmp/hub298-audit/authority-probe.cjs`. Les simulations démontrent les transitions de code, pas les conditions réseau de PROD.

## A. Cinq opérations à ne pas confondre

| Opération | Autorité / effet actuel |
|---|---|
| Créer une E persistée | Service Global de lancement sollicité par Master ou orchestration de commande Remote claimée par Master ; insertion `game_events.hub_execution_started`. |
| Sélectionner l’E officielle | Lecture Global de la dernière E ouverte pour Hub/session, clôtures/retraits pris en compte ; pas l’E choisie librement dans un message Player. |
| Restaurer un runtime WS | Créer/réutiliser un objet Node et y fixer `hubExecution` depuis cette lecture. Peut installer une autorité locale opposable au futur Master, sans créer d’événement DB. |
| Binder un Player | Associer une identité et une socket au runtime, mettre à jour roster/compteurs. Bingo restaure le lifecycle avant ce bind ; Quiz/BT recherchent seulement un runtime existant. |
| Auth/register Organizer et reprise | Valider/restaurer le lifecycle, publier le propriétaire primaire, envoyer l’ACK/état ; reprise d’une E existante distincte du lancement forcé d’une autre E et du démarrage gameplay. |

**Modèle persistant commun aux trois jeux.** Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php`, `app_games_hub_session_launch_from_master`/`_locked` (:10195–10528) : service sérialisé, focus officiel puis E et génération de routage. `app_games_hub_execution_context_create` (:4423–4472) écrit l’événement ; seuls ses appels de lancement officiel (:10449) et préparation démo (:10161, hors scénario officiel) sont retrouvés dans le code de production de ces cinq snapshots. `get_open` (:4370–4421) relit les started/completed/removed ; une E ancienne ne remonte pas derrière la dernière clôturée. `official_execution_is_reusable` (:1606–1625) exige notamment runtime métier `running` et E non expirée. Sinon, la branche de lancement peut forcer une nouvelle E. Une simple ligne E ouverte ou un bind WS Player n’équivaut pas à `running`.

**Remote Hub.** Games `web/modules/app_hub_remote_ajax.php:1236–1254` crée une commande `launch_session`, pas une E ; Global `app_games_hub_remote_command_create:1702–1730` refuse `MASTER_UNAVAILABLE` sans présence Master. Claim lié à l’instance Master (:1903–1905). Games `games_hub_handle_master_remote_launch_command`, `app_hub_view_helpers.php:3753–3800`, appelle ensuite le service commun avec `remote-command-<id>`. Master direct : même fichier :2951–2978. La Remote peut sélectionner directement la **présentation** (:1279–1305 du remote_ajax), mais cela ne remplace ni l’E ni le focus runtime. Génération officielle publiée par Global :1053,10471 ; les clients en transportent les références, ils n’en sont pas les writers.

**Player HTTP.** Global `app_hub_player_resolve_session_access:9257`, `app_games_hub_session_participation_ensure:8919` et son wrapper :9243 peuvent créer/réconcilier une participation, un mapping et les données moteur nécessaires ; aucune création d’E, publication de génération ou écriture de focus officielle trouvée dans ce chemin. Games `php/hub_capacity.php:44–95` relit l’E officielle pour l’admission ciblée et vérifie sa provenance, le focus et la participation. La capacité/roster et la participation persistée sont des données différentes de l’autorité d’exécution.

## B. Parcours rôle par rôle et écarts précis

### Bingo

- **Organizer** : Games `core/ws_effects.js:251–263` envoie `auth_client` avec token, id_client, hubLifecycle (E/source/runtime/resume), limite et mode. Bingo `ws/bingo_server.js:1098–1102` authentifie via repository, déduit la playlist depuis le token DB, puis `restoreHubRuntime`. Le bind primaire n’arrive qu’après (:1156–1190), puis l’état authentifié. Games attend cet état/runtime-ready avant `ensureBingoStartReset()` (`boot_organizer.js:1753`) ; les commandes gameplay sont traitées par le handler Client.
- **Player numérique** : `performBingoAuthentication:856–1019`, identité/grille authentifiées, session retrouvée, puis `restoreHubRuntime` **avant admission et bind**, à882. Paper : même effet à1052. `restoreHubRuntime:3715–3723` crée si nécessaire `hubRuntimes[playlist]`, appelle restore et pose `hubHasLiveState=true`. `ws/hub_lifecycle.js:8–33` peut poser `hubExecution=Object.freeze(result.execution)` sans connaître le rôle appelant. Aucun Organizer ouvert requis à cet endroit. Écart au contrat : la requête Player fixe le premier E local, ensuite opposable à l’auth Organizer.
- **Remote runtime** : `auth_remote:1284–1292` authentifie le token puis appelle le même restore sans vérifier d’abord l’existence d’un Organizer ; elle peut donc créer l’objet et fixer son E. Ses commandes usuelles `remote_action` sont bien relayées au Client (`handleRemoteMessage:2223–2260`) ; l’échec du relais ne confère pas de pouvoir de lancement, mais l’autorité locale a déjà pu être installée par l’auth.
- **Divergence** : la même restauration Player/Remote peut modifier `hubLifecycleLoading`, `hubLifecycleFailed`, l’état de suspension et le gel du runtime partagé avant un refus. Ce n’est pas une simple lecture sans effets. `HUB_EXECUTION_MISMATCH` ferme1008 et ne purge pas la Map. Les Players authentifiés passent ensuite par leur handler dédié (`handleMessage:713–773`) ; le changement de rôle par le message primaire Quiz/BT n’est pas le mécanisme identifié ici.

### Quiz et Blind Test — vérifiés séparément

Les chemins d’autorité sont équivalents dans les deux snapshots ; les différences quiz/séries et BT/équipes ne changent pas les décisions ci-dessous.

- **Organizer** : Games `core/ws_effects.js:375–389` transmet `registerOrganizer`, `isPrimary:true`, sessionId et hubLifecycle, puis attend `registrationSuccess role=primary`. Quiz `web/server/actions/registration.js:62–115`, BT :69–125 : création immédiate de `sessions[sessionId]` **avec primarySocket=null**, avant restore ; puis `hubSuspension.restore`, puis `hubLifecycleLoaded=true`. Publication primaire Quiz :190–207, BT :201 et suivantes. Après ACK, le Master synchronise `initializeOrUpdateSession` et pilote le gameplay.
- **Player nominal** : `registerPlayer:450–518` dans les deux moteurs : session absente → registrationError, aucun objet créé ; session existante → lecture de `session.hubExecution`, preuve ciblée et revalidation après await. Aucun appel restore ni écriture `hubExecution`. `checkSessionStatus` ne crée pas la session et ne fixe pas E ; il actualise la capacité. `wsHandler` rejette les mutations pendant loading/failed/suspension. Un objet mémoire existant ne prouve donc pas que le Player en soit le créateur.
- **Remote froide** : `registerOrganizer` avec `isPrimary:false`, session inexistante → refus explicite, aucun objet créé. **Remote sur objet incomplet** : la condition `(isPrimary || !session.hubLifecycleLoaded)` déclenche aussi restore pour une Remote si la première tentative primaire a laissé un objet non chargé. Le catch primaire ne supprime pas cet objet. Une nouvelle lecture réussie depuis la Remote peut y installer E1, remettre failed=false et enregistrer la Remote **sans primarySocket**. Écart reproduit dans les deux moteurs.
- **Commandes Remote normales** : `audioControl.js:16–70,151–170` relaie play/pause/navigation/quit au primaire ; absence de primaire ne lui donne pas une E persistée. Toutefois l’autorisation du dispatch n’est pas une liste stricte de commandes Remote : voir l’écart suivant.
- **Frontière de rôle insuffisante** : `remoteOwnership.js:19–25` laisse passer une socket non Remote ; `wsHandler` filtre les anciens primaires et le lifecycle mais ne refuse pas `registerOrganizer isPrimary:true` à une socket Player (Quiz :390–434 ; BT :423–468). `registration.js` ne vérifie pas le rôle Player déjà établi avant de publier le primaire. Simulation : un Player réellement bindé sur S envoie ce registre pour T, et devient primary de T, avec E relue côté service. Il ne fabrique pas une E DB, mais crée/promouvoit un runtime WS. Les clients Player ordinaires n’émettent pas ce message : c’est une violation de l’invariant serveur, distincte du parcours nominal et de l’incident298.
- **État officiel modifiable hors primaire** : Quiz `wsHandler.js:545–546`, BT :580–581 dispatchent `initializeOrUpdateSession` sans test général `socket === session.primarySocket` (le test du bloc `hubPreserveLive` n’est actif que dans ce cas particulier). `remoteOwnership.allows` autorise cette action à un Player et à une Remote propriétaire. Quiz `gameplay.js:208–253`, BT :202–226 modifient gameStatus/index/playlist depuis ce payload. Cela ne choisit pas un execution_id DB, mais viole « Master seul autorité runtime ». Preuve par lecture du dispatch et des writers ; aucune assertion que ces messages aient été envoyés lors de l’incident.

**Absence d’E officielle** : le lifecycle commun accepte une lecture sans `result.execution` si `ok/state` sont valides ; le branchement d’admission ciblée est conditionné à la présence d’une E officielle, sinon fallback capacité/roster historique. Ces fallbacks nécessaires aux parties autonomes ne constituent pas à eux seuls une preuve d’E Hub ouverte. Le futur contrat doit distinguer explicitement Hub officiel et autonome, sans considérer une simple appartenance ou l’objet mémoire comme preuve d’autorité.

## C. Scénario E1 → Players → aucun Organizer réussi → relancement E2

**Décision DB commune** : E2 n’est pas systématique. Même E1 réutilisée si session métier running + E ouverte valide ; E2 possible si non réutilisable, notamment pending sans suspension persistée requalifiant le runtime. Le focus seul et le TTL de présence ne suffisent pas à remplacer E. Une navigation/reload ne vide pas Node.

| Étape / question | Bingo | Quiz | Blind Test |
|---|---|---|---|
| E1 créée par Master, aucun registre Organizer arrivé | Players peuvent créer le runtime et y restaurer E1 | Aucun runtime créé par Player ; refus/retry | Même refus/retry vérifié |
| Players ont-ils fixé E1 dans leur parcours normal ? | Oui, numérique et Paper | Non | Non |
| Si une tentative Organizer échoue | L’objet et l’E déjà restaurée restent possibles | Objet créé avant restore ; peut rester après refus, sans primary | Même comportement |
| Quel rôle peut ensuite fixer E sur l’objet incomplet ? | Player, Paper, Remote, Organizer | Organizer ou Remote si lifecycle non chargé ; pas registerPlayer | Même règle |
| E2 officielle et auth Organizer suivante, avec E1 en mémoire | Mismatch ; E1 conservée, auth1008 | Mismatch ; registrationError, E1 conservée, pas de promotion | Même résultat |
| Si aucun runtime/E1 n’a jamais été créé | Organizer crée et adopte E2 | Organizer crée et adopte E2 ; scénario Player-only ne bloque pas | Même résultat |
| Ancien runtime purgé automatiquement à ce refus ? | Non | Non | Non |
| Qui gagne ? | DB reste E2 ; mémoire E1 oppose un veto et gèle le runtime | Même veto s’il existe un objet E1 ; sinon E2 acceptée | Même règle |

Le garde commun ne choisit pas E1 comme nouvelle autorité DB : il bloque la convergence. La comparaison ne porte pas directement sur l’E du navigateur ; celui-ci peut présenter E2 fraîche et être refusé. En Quiz/BT, **ne jamais présenter le cas Player-only de Bingo comme reproduit à l’identique**. Leurs variantes orphelines exigent un objet créé par une tentative primaire, une Remote sur objet incomplet, ou une violation de rôle.

Recovery existant : nouvelle tentative peut récupérer après une simple erreur transitoire de lecture si aucune E incompatible n’est fixée ; reprise suspendue exige le grant ; même E et nouveau primaire peuvent reprendre normalement. En mismatch persistant, retry/reload seul ne modifie pas le couple mémoire/DB. Des chemins de disposal existent (expiration suspension ; cleanup/grâce après un primaire effectivement enregistré), mais pas de récupération dédiée de l’objet créé avant un registre primaire échoué. Quiz `connection.js:20–72,256,338,354–358`, BT mêmes branches :275,357,373–377 ; Bingo `disposeHubSuspension:3732–3745`. Aucun purge/restart conseillé pendant l’audit.

## D. Matrice de conformité

« Player » désigne ici le handler Player nominal ; les franchissements de rôle sont signalés séparément.

| Point | Bingo | Quiz | Blind Test |
|---|---|---|---|
| Master/orchestration seule crée l’E persistée officielle | Oui, writers audités | Oui, service commun | Oui, service commun |
| Player peut créer runtime WS | Oui | Non dans registerPlayer ; oui en se déclarant primaire | Identique, vérifié |
| Player peut poser execution_id mémoire | Oui via restore | Non nominalement ; oui après promotion de rôle non refusée | Identique, vérifié |
| Remote peut créer runtime sans Master | Oui, objet et E | Pas à froid ; E sur objet incomplet préexistant | Identique, vérifié |
| Runtime initialisé par Player survit au relaunch | Oui | Pas de tel runtime nominal ; objet orphelin d’autre provenance peut survivre | Identique |
| E2 Organizer remplace proprement E1 Player | Non | Sans objet E1 : oui ; E1 injectée/orpheline : refus | Identique |
| Mismatch/freeze possible | Oui, parcours Player/Remote normal inclus | Oui, E1 retenue ; pas créée par registerPlayer nominal | Identique |
| Recovery prévu | Reprise même E/disposal, pas transition dédiée E1 orpheline→E2 | Reprise même E/cleanup, pas rollback du registre échoué | Identique |
| Verdict contrat strict | **Non conforme** | **Non conforme** | **Non conforme** |

## E. Cause structurelle et historique

Trois notions ne sont pas séparées : existence d’un objet WS, identité officielle relue, et publication d’un propriétaire Organizer valide. Le restore partagé peut rendre une identité locale opposable au Master avant cette publication. Son garde d’immuabilité ne distingue pas runtime légitime à préserver et objet provisoire/orphelin. Le service Global, lui, décide la réutilisation à partir de l’état métier durable ; il peut donc produire E2 alors que Node garde E1. Quiz/BT ajoutent une frontière de rôle basée sur le message, insuffisante pour le contrat strict.

| Historique identifié | Effet / limite |
|---|---|
| Quiz `f523d355`, BT `65ec2c7f`, 26/09/2025 | Création session par registerOrganizer primaire ; Player/secondary refusés à froid ; dispatch initializeOrUpdateSession déjà présent. Ces structures sont anciennes dans l’historique disponible, pas introduites par le hotfix23/09. Ce commit est la première attribution visible, pas une preuve d’origine antérieure hors dépôt. |
| Global `d31032d8`, 04/09/2026 | Réutilisation E ouverte indépendante du TTL, mais exige running. Ne couvre pas un objet Node pending initialisé avant gameplay. |
| Global `c2ea04c`, 09/09 | Reprise numérique active liée à expected_execution_id, pas de création de secours ; périmètre running, pas premier boot orphelin. |
| Bingo `dc574b26`, Quiz `4fad7368`, BT `5bddb11`, 11/09 | Lifecycle suspension/reprise. Bingo ajoute restore dans Player/Paper/Organizer/Remote ; Quiz/BT dans registerOrganizer avec branche secondary si non chargé. Global `40f73ff` requalifie pending avec preuve de suspension en running ; simple bind Player exclu. |
| Bingo `591bc17`, Quiz `557f5a20`, BT `34614075`, 18/09 | Ajout de `hubExecution` officiel immuable et du throw HUB_EXECUTION_MISMATCH dans les trois lifecycle ; le risque de restauration hors Organizer devient un veto explicite à une nouvelle E. Protections Remote/takeover renforcées, sans fermer la conversion Player→primary ni réserver tout restore au Master. |
| 23/09 : Bingo `a62ebad`, Quiz `b3d1419`, BT `9b898ae`, Games `eaf0539` | Admission ciblée depuis l’E déjà mémorisée, contrôles après await ; attente Organizer runtime-ready. Le garde et ses appelants d’autorité ne sont pas corrigés. Quiz/BT registerPlayer ne se mettent pas à créer une E à cette occasion. |

Aucun correctif de récupération E1 orpheline→E2 officielle trouvé dans `hub_soiree`. Aucun constat de ce rapport n’est transféré au chantier non livré `hub_session_readiness`.

## F. Vérifications exécutées et tests contractuels à ajouter après validation

Résultats obtenus avec les vrais modules registration/lifecycle, dépendances externes simulées :

- Quiz **et** BT : Player froid → aucun objet ; Remote froide → aucun objet.
- Quiz **et** BT : lecture primaire échoue → objet sans primary/E ; Remote relit avec succès → E1 installée, toujours sans primary ; source officielle E2 → registre primaire refusé mismatch, E1 conservée et failed=true.
- Quiz **et** BT : Player réellement bindé sur S, puis registre primaire pour T → objet T créé et socket promue. `remoteOwnership.allows` accepte ce registre ; le test appelle ensuite le handler réel. Transport réseau complet non exécuté.
- Bingo : lifecycle réel sans contexte Organizer fixe E1 ; lecture E2 avec contexte navigateur frais E2 refuse. Les appels Player/Paper/Remote et l’allocation de Map sont attestés par lecture des lignes citées et complètent cette reproduction lifecycle.

Suite commune future, sans implémentation dans cette passe :

| Test demandé | Assertions indispensables |
|---|---|
| 1. Player avant Organizer | Aucun writer d’E/propriétaire ni changement de focus/génération ; sans ouverture officielle → refus/attente ; E ouverte par orchestration Master → admission possible sans promotion par Player. |
| 2. Remote sans Master | Aucun runtime/autorité créé à froid **ou sur objet primaire incomplet** ; commande Hub sans présence refusée ; aucune mutation du gameplay quand relais impossible. |
| 3. E1 mémoire + E2 officielle | Candidat primaire frais revalidé côté serveur gagne sur objet provisoire ; snapshot, sockets et timers E1 ne contaminent pas E2 ; E1 active légitime ne doit pas être évincée sans décision Master. |
| 4. Player ne bloque pas Organizer | Échecs/retries Player pendant auth Master ne fixent pas E et ne modifient pas les flags de gel du propriétaire ; rejeu après await sans effet tardif sur E2. |
| 5. Orphelin | Échec SQL/lifecycle, socket fermée pendant restore, échec après fixation E et avant ACK ; rollback/retirement borné ; aucun veto indéfini à une exécution officielle suivante. |
| 6. Parallélisme | Players autorisés dès l’ouverture officielle côté serveur, pendant démarrage ; aucune dépendance au retrait d’overlay, countdown ou transition UI ; limites/admission conservées. |

Compléments nécessaires : Player→registerOrganizer et messages gameplay primaire refusés sans mutation ; Remote propriétaire→initializeOrUpdateSession refusé ; E absente/invalide/terminée/suspendue, DB read vide/erreur, reprise même E, double Master, E1→E2→E3 et réponses hors ordre, papier/démo/autonome, absence de socket Organizer distincte de l’absence d’ouverture officielle. Vérifier l’absence de writes, pas seulement le message d’erreur.

## G. Périmètre minimal proposé, à valider — aucun patch appliqué

1. **Commun lifecycle + intégration WS** : séparer lecture/admission d’une E officielle et installation/remplacement de l’autorité locale ; publier celle-ci uniquement sur une preuve Organizer/orchestration validée. Player/Remote ne doivent pas modifier l’autorité ou le gel global en vérifiant leur accès. Conserver les protections suspension/expiration et éviter tout remplacement automatique d’une vraie partie active.
2. **Bingo spécifique** : retirer les effets d’installation d’autorité des chemins auth Player/Paper/Remote ; conserver leur admission concurrente sur une E officiellement ouverte. Ne pas remplacer le problème par l’obligation d’attendre une UI ou une première frame gameplay.
3. **Quiz/BT spécifiques** : objets avant succès primaire explicitement provisoires avec rollback/retirement ; aucune restauration autoritaire par secondary ; clôture serveur des changements de rôle Player→Organizer et contrôle du propriétaire primaire sur les messages qui publient le runtime.
4. **Global/Games communs** : expliciter le statut d’ouverture et la politique Master de réutilisation/remplacement d’une E pending ; transmettre/valider cette preuve jusqu’au WS, et coordonner le retrait de l’ancienne E quand le Master en choisit une nouvelle. Étendre la réutilisation à toute E pending sans vérifier sa provenance ne serait pas un correctif sûr. Aucun nouveau sas/readiness complet requis par ce périmètre.
5. **Tests et preuve** : même matrice contractuelle dans les trois moteurs, logs de refus avec rôle/session et E attendue/mémorisée pour vérifier les transitions. Recette réelle ensuite, séparée de ces simulations.

L’analyse structurelle ne nécessite pas de lecture DB supplémentaire pour établir ces écarts de code. L’attribution de l’incident298 reste au verdict et aux données manquantes du rapport précédent. Validation de ce rapport requise avant tout patch applicatif, conformément à la demande.
## H. Suite autorisée — patch local et analyse main, 25/09/2026

L’opérateur a validé le périmètre de robustesse après recette DEV du pregame. Le rapport ci-dessus conserve ses constats historiques hub_soiree ; ils ne décrivent pas le nouveau delta local. [Audit ciblé du code pregame, correctifs implémentés, tests et comparaison main/develop/pregame](hub-execution-robustness-backport-2026-09-25.md). Aucun patch main ni déploiement ; origine exacte de l’incident du 24/09 toujours non réattribuée par ces simulations.

<!-- AUTO-UPDATE:END id="hub-execution-authority-audit-20260925" -->
