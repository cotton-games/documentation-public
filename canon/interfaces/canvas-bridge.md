<!-- AUTO-UPDATE:BEGIN id="hub-suspend-20260910-bridge" owner="codex" -->

**25/09 — Robustesse Hub locale, non déployée.** `execution_id` sur retries Player est une fence de comparaison avec E canonique, jamais une autorité navigateur. Admission active revalidée avant write. `registerPlayer` ne peut devenir `registerOrganizer` ; initialisation/runtime officiels réservés au primary publié. Remote conserve les relais au Master. [Contrat, erreurs, tests et backport](../../notes/hub-execution-robustness-backport-2026-09-25.md).

**25/09 — Correctif Remote/reprise local, note V2 AH :** aucun changement du bridge service ou des moteurs. `client_routing` garde l’autorité Remote ; présence/readiness exactes, first_start accepté et écran `remote/state` opérationnel avant reveal. `remote-operational` est un constat de rendu local, pas un ACK de démarrage ni une preuve gameplay. En reprise, la projection UI `preparation=false` provient du first_start du même E (slot ou lifecycle), sans persistance nouvelle. `started`, reset et suspension canoniques restent inchangés.


**25/09 — Hub-native local :** aucun nouveau write bridge. Lecture `accepted_start` pour récupération ACK depuis slot closed/started, distincte du carrier reset `first_start`. Journal d’exécution `pregame_ui_mode`, slot `ui_mode`, valeurs `session|hub_native` ; absent → session, figé à la création E. Descripteur UI `embed_context.phase=runtime` autorise le remontage d’une E déjà existante sans inventer un slot ou une preuve started. L’ACK relu par WS exige slot starting/closed-started ou first_start durable de même E. Projection population précédente strictement diagnostique ; moteur5/10/5/90 inchangé. Voir note V2 AG.


**25/09 — Extension diagnostique locale, non déployée.** `hub_pregame stage=read` accepte `diagnostic_population=true` avec E ; open/session/E/version/focus officiel numérique cohérents donnent `population={execution_id,version,identities:[string]}`, sinon population inconnue (null/absente). IDs Global actifs sans mapping left ; probables non activés exclus, non mappés inclus ; aucun ensure/write/verrou/plafond. Relecture du slot après SELECT. Service-only, jamais au navigateur. Consommation WS pour traces uniquement, pas pour START. [Contrat et limites](../../notes/hub-open-players-foundations-2026-09-24.md#af-hub-native--audit-du-delta-et-instrumentation-préalable-start--25092026).


**25/09 — POC iframe livré en DEV et recette manuelle confirmée après la préparation locale ci-dessous.** Analyse sans nouveau patch : voir section AE de la note V2 ; ACK candidat UI, started preuve métier, limites de capture explicites. **Bilan local initial :** Opt-in `hub_embed_poc=ack|started`, officiel numérique uniquement ; même Canvas/primary conservé à la révélation, fullscreen parent, Annuler avant START accepté, retour enfant léger sans second Hub. Lecture DEV autorisée du slot pour distinguer started d’un simple closed. Remote, moteurs, ensure/mappings/compteur/auto-start et A/B/C inchangés.9 tests hôte +12 contrôles PHP +103 tests pregame existants réussis ; recette des trois jeux DEV à effectuer par l’opérateur. [Périmètre, liste exacte des9 fichiers applicatifs, activation A/B et limites, section AD](../../notes/hub-open-players-foundations-2026-09-24.md). Aucun deploy/restart.


**25/09 — C révisé, local non déployé : retrait Hub durable immédiat ; cleanup runtime non bloquant.** Tombstone + membership inactive + slot closed/removed + focus/présentation libérés dans la demande PHP, réponse removed/already_removed ; aucun moteur requis. Le moteur vivant observe le tombstone puis détache/ferme les sockets sans finaliser le Hub. Read retiré explicite, lifecycle/START/Player tardifs refusés, cleanup tardif sans mutation ; gameplay sain protégé. Ancien removing finalisable en retentant le retrait, sans réconciliateur. A/B, ensure, auto-start5s/10s/5s/90s, compteur et UI pregame conservés. Tests :20 suites principales,26 scénarios retrait moteur/retour,300 vérifications retrait PHP ; compléments admission/publics/Pro/fallback verts, effets externes simulés. [Contrat, fichiers et rollback C : section AC](../../notes/hub-open-players-foundations-2026-09-24.md). Markers25-09-2026/02 préparés ; aucun deploy/restart.


**Contrat courant pregame (24/09, local non déployé) :** départ automatique demandé, minimum5s / grâce sans bind10s / calme WS5s / watchdog exceptionnel90s, sans plafond normal. Remplace le départ exclusivement humain décrit dans les entrées historiques ci-dessous. Binds WS effectifs seuls ; compteur numérique regroupé sur250ms, sans effet sur le timer serveur. Signal HUB_PREGAME_AUTO_START au primary → ui/play → START/ACK existant, guards préservés. Aucun quorum ; zéro valide. Ensure/mappings/papier/démo inchangés. Tests auto37/37, UI20/20 ; vagues de5000 sockets simulés par moteur, charge DEV réelle et navigateur restant à qualifier. Détails, fichiers et rollback : section T de la note V2. Aucun déploiement/restart. Minimum depuis open accepté, indépendance de l’animation250ms ; CTA Démarrer le jeu et styles dédiés supprimés sur Master/Remote, seul retour volontaire conservé. Textes adaptés au départ automatique. Retry ACK avec request_id stable par E et reprise du même START en starting ; watchdog demandé/accepté tracé distinctement.


**Correctif local admission EP Hub numérique (non déployé).** La réponse DEV Blind Test27977/Hub353 expose `PARTICIPANT_SOURCE_INVALID` dans `access.ensure.api`, avant URL/redirection. Le motif interne exact (historique absent, clé, contexte ou SQL) n’est pas distingué par ce code erreur ; le même refus Quiz n’est pas encore capturé. L’ensure numérique atteste désormais une identité EP Hub active via un contexte PHP interne limité à l’appel `player_register`, restauré dans finally. Les adaptateurs Quiz/BT/Bingo vérifient jeu, session, identité et clé canonique avant d’exempter cette provenance du filtre d’historique organisateur. Aucun champ navigateur n’accorde cette confiance. Capacité, lifecycle, mappings left, marqueurs de jonction, protection des pseudos invités et injection papier inchangés. Aucun changement WS, schéma ou compteur prégame. Détails et recette : section Q de la note Open Players V2.


**UX prégame locale finalisée (non déployée, navigateur non qualifié) :** Lancer → prégame partagé Master/Remote → Démarrer le jeu → gameplay. Surface Hub isolée masquant totalement le lobby historique, contexte/branding déjà résolus, boutons propres, compteur « N joueurs prêts » et activité sans cible non bloquante. Retour à la soirée via cleanup canonique. Même E/slot sur retour d’un prégame sain ; Lancer avant START, Reprendre après départ réel. Confirmations redondantes retirées uniquement du parcours officiel numérique ; papier/démo préservés. Voir la section O de la note V2 pour tests, fichiers, limites et recette.

## 24/09/2026 — Bridge prégame V2 DEV, correctif transport local

`action=hub_pregame` est service-only (token Canvas existant), avec `game`, `sessionId`, `stage=read|publish|start|started|abandon|cleanup`, E/version/incarnation. Les preuves init/gameplay/détachement sont émises par les moteurs ; aucun navigateur ne les publie. Réponse `{ok,slot}` ; `slot:null` hors contrat/slot consommé. Journal CAS propre à l’action ; aucune réussite générique de replay. Les writes sensibles utilisent le verrou Hub jusqu’au dispatch effectif. [Contrat complet](../../notes/hub-open-players-foundations-2026-09-24.md).


**Correctif local du 24/09 après échec DEV :** les stages `publish`, `started`, `cleanup` passent par `canvas_hub_pregame_proof_normalize`. Une chaîne JSON objet/tableau est décodée ; un tableau PHP est conservé ; JSON invalide ou scalaire retourne `HUB_PREGAME_PROOF_INVALID`. Les exigences métier des preuves et leurs erreurs `*_UNPROVEN` restent inchangées. La trace `[hub_pregame][proof_validation]` contient stage, type reçu, normalisation, noms des clés reconnues, nombre de clés inconnues, résultat/erreur et Hub/session/E résolus. Aucune valeur de preuve ni nom de clé arbitraire n’est journalisé. Correctif non déployé, aucune nouvelle qualification navigateur.

### 22/09/2026 — Bingo : premier state Player Hub allégé

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../deployment-status.md).

`auth_player` Hub non-démo reçoit `state` avec le même `num_connected_players` et les mêmes champs phase/progression/génération/lots/reprise, mais sans `players`. Le Player utilise le total explicite ; aucun changement client requis. Autres rôles, papier/démo/hors Hub et publications périodiques gardent leur contrat. Routage DB grille+secret puis auth complète dans la queue ; deux reset_state nominaux au lieu de trois. Lifecycle et capacité frais conservés, pas de TTL ni de nouvelle action HTTP. [Preuves, invariants et limites](../../notes/bingo-digital-auth-performance-2026-09-22.md).


### 22/09/2026 — Capacité WS / publication BT (local)

> **Branche `sas_players` — NON DÉPLOYÉ EN PROD au 22/09/2026.** Exclu du déploiement `hub_soiree`. [État de livraison](../deployment-status.md).

Cohortes fermées avant fetch de `hub_capacity_get` : aucun cache de réponse réutilisé par une admission ultérieure, contrat API/stock/verrou Bingo inchangé. Modules `capacity_reads.js` à livrer avec `envUtils` et helpers capacité. BT indexe le lookup Player. Markers Quiz/BT/Bingo : `restart 22-09-2026/01` ; redémarrage des trois WS nécessaire après livraison future autorisée, aucun effectué. Pas de nouvel endpoint/env/SQL ni reload PHP. [Contrat, tests et limites](../../notes/hub-capacity-publication-patch-2026-09-22.md).


### PATCH1B — autorisation bornée pendant la suspension

Lors d’une reprise papier explicite, le grant existant est créé avant l’ensure collectif. Un contexte serveur temporaire permet uniquement le `player_register` canonique du participant attendu. Games relit session/Hub/exécution/focus/génération/fenêtre/expiration et suspension libérée avec jeton valide. Aucun champ client ne remplace les deux contextes serveur. Aucune levée globale du gel : toutes les autres écritures restent bloquées et seul l’ACK moteur normal produit `hub_resumed`. La correction nécessite Global `app_games_hubs_functions.php` **et Games `php/hub_lifecycle.php`** ; pas de WS/marker modifié. [Diagnostic et validation](../../notes/paper-resume-patch1b-2026-09-21.md).



### PATCH1B — résultat de reprise papier

`launch_session` officiel papier réutilisant l’exécution assure les participations Hub avant retour. Réponse additive : `injection` (six compteurs, `complete`, échecs/exclusions), `paper_roster_reconciled`, `runtime_reconciliation=pending`, `warning`. Échec individuel : reprise encore possible, avertissement `PAPER_ROSTER_RECONCILIATION_PARTIAL`, aucun ACK de convergence runtime. Les reprises recréées exposent le même bilan sur leur injection existante. [Contrat détaillé](paper-roster.md).


### PATCH3 Bingo papier — 21/09/2026

Aucun endpoint ni schéma changé. La résolution facultative WS relit `players_get` actif/admis via PATCH1. Association trouvée : `phase_winner` canonique existant, même `event_id`. ACK HTTP présent : refresh seul même si association introuvable ; sans ACK et sans identité : chemin historique sans joueur. Aucun contournement des refus métier HTTP. [Rapport](../../notes/bingo-paper-association-patch3-2026-09-21.md).


### PATCH2 — persistance papier (21/09/2026)

`quiz|blindtest:update_score`, intentions `paper_score_update` / `paper_score_read` : helper commun, K/D stricts, valeur demandée/confirmée et request ID, UPDATE exact et reçu `game_events` transactionnels. Ces deux intentions évitent le pré-enregistrement générique d’événement ; les autres actions conservent leur politique. `session_update` terminal papier compare `paper_score_snapshot` sous le même verrou avant écriture finale ; écart → `PAPER_RECONCILIATION_REQUIRED`. Aucun schéma ajouté. [Contrat et limites](paper-score-corrections.md).


### Branding compte Hub — complément 21/09/2026

Le branding Hub est maintenant hydraté depuis Global via `global_ajax.php?t=general&m=branding&action=get&format=json&hub_token=…` : résolution des fichiers sur Global, cascade Hub sans surcharge session, URL versionnées conservées. Le paramètre Hub est prioritaire sur le token session ; Hub inconnu/inactif/en suppression retourne un échec sans résolution session. Les appels historiques sans `hub_token` restent inchangés. Play normalise les champs logo/visuel, utilise un timeout borné et conserve le fallback existant si Global est indisponible. Logo centré sous le formulaire, visuel non recadré arrondi à12px. Signin/signup uniquement : titre avec son style gras précédent, puis « · organisateur » secondaire (`client.nom_social`, sinon `client.nom`, pour une soirée ; `event.naming_nom` pour un événement ; aucun séparateur si absent). WWW soirée/événement : sous-titre sombre et URL organisateur complète en lien texte, avec retour à la ligne mobile.


### 21/09/2026 — Capacité Hub et contrat service

`hub_capacity_get` est réservé au jeton de service Canvas ; payload `game`, `sessionId`. Retour : `ok`, `is_hub`, `capacity`, `current_capacity` pour Hub, `active_keys`, `active_count`, `active_identities` (alias → identité Hub pour dédoublonnage) ; démo `is_demo=true`, capacité 2. Les clés couvrent les identités canoniques et mappings legacy actifs. Erreurs explicites, aucun fallback commercial. Cette lecture peut synchroniser vers le haut la session et compléter le stock Bingo. `session_meta_get` expose `session.maxPlayers` et inclut la capacité dans sa signature pour rafraîchir Remote. `player_register` vérifie l’admission Hub avant écriture ; une identité left doit rejoindre explicitement le Hub. [Contrat et validation](../../notes/hub-capacity-upsell-2026-09-21.md).


### Player : marqueur de départ local — 19/09/2026

Départ volontaire navigateur isolé par jeu/session/clé stable joueur (`p:<UUID>`), helpers centralisés dans `play/player_identity.js`. Priorité à l’identité Hub validée au bootstrap ; rejoin explicite efface uniquement son marqueur. Ancien marqueur anonyme supprimé sans migration vers le joueur courant. Contrats HTTP/WS et membership serveur inchangés.


### Hub Master : surface mobile — 18/09/2026, local non déployé

`launch_session` conserve son service et ses gardes. Seule la politique papier du Master accepte `master_surface=mobile` ; sans cette valeur exacte, le papier officiel reste refusé `PAPER_LAUNCH_REMOTE_ONLY`. Indication du viewport courant `<992px`, jamais une authentification/capacité persistée. Revalidation client après confirmation et avant POST ; desktop `>=992px` reste Remote-only. Reprise numérique : `expected_execution_id` inchangé ; papier : contrat existant sans cette garde numérique. Retour session contextualisé vers Hub, puis lien explicite vers Dashboard. [Détails et tests](../../notes/hub-master-responsive-2026-09-18.md).


### Sortie de Remote remplacée — correctif local du 18/09/2026

`forcedDisconnect` n’est pas toujours un takeover. Seul `replacement_reason=takeover` déclenche après alerte la fermeture de l’onglet puis `about:blank` en repli. Avant retrait du transport, le lifecycle démo local est retraité sans close partagé : la démo du Master et de la nouvelle Remote continue. Continuité silencieuse sans popup, quit/suspension/fin naturelle vers Hub et auto-routing d’une nouvelle Remote restent inchangés. Aucun marqueur one-shot ni modification WS serveur. [Historique et tests](../../notes/remote-takeover-exit-2026-09-18.md).

### Régressions Remote — correctif du 18/09/2026, validation DEV confirmée par l’utilisateur

Le Master « historique » du signalement est le Master runtime ouvert depuis Hub. Une nouvelle URL Hub peut omettre `hub_routing_generation` : Organizer reprend alors uniquement la génération de la publication canonique correspondant à sa session source et son exécution. Si le paramètre existe, sa valeur est conservée, même zéro/obsolète, pour rester soumise au validateur Global inchangé. Aucun focus, intent ou nouveau droit de reprise n’est créé.

Le bootstrap Remote versionne aussi la dépendance relative `hub_runtime_authority.js` via l’import map et le script démo via son empreinte temporelle de fichier. Le transport standard retrouve `registerRemote` par le callback de reconnexion existant. Côté Quiz/Blind Test, découverte/registration secondaire restent accessibles à la candidate ; mutations réservées à la propriétaire, refus total de la révoquée. Continuité silencieuse, vrai takeover et clôture explicite démo restent distincts. [Rapport et limites de preuve mobile](../../notes/remote-bootstrap-regressions-2026-09-18.md).


### Complément Remote Quiz/Blind Test — 18/09/2026

Leurs builders `hubLifecycle.js` transportent désormais `trigger`, `surface`, `page_id` avec le `request_id` existant à travers validate/suspend/release/resume. Après release réussi, les surfaces sont marquées retirées avec execution/request avant `HUB_SESSION_SUSPENDED`, pour reconnaître la continuité de la même origine navigateur après reprise autorisée. Les preuves métier de validation/reprise/focus restent celles du bridge existant. `replacement_reason` appartient au message WS `forcedDisconnect` et au log de remplacement, pas à une nouvelle autorité HTTP. Ni secret de session ni token de reprise ajouté au diagnostic. [Contrat et preuves](../../notes/remote-ownership-transversal-2026-09-18.md).


### Complément18/09 — présence et diagnostic, local non déployé

La présence runtime utilise la publication Hub courante via `app_games_hub_remote_routing_intent_context_get` : génération et intention exactes, source et exécution ouverte du même Hub, focus officiel et instance Hub Master courante. `hub_master_instance_id` est distinct de l’identité runtime `master_instance_id`. Le bootstrap transmet l’identité Hub et l’intention ; aucun nouvel identifiant durable. Le lifecycle continue de bloquer une suspension effective, mais sa dernière génération de dégel ne remplace plus la publication. Après reprise génération2 puis perte involontaire du Master, une reprise active publiée en3 accepte uniquement3. Les démos gardent leur validation isolée existante et leur readiness.

`HUB_SUSPEND_REQUESTED` précède l’envoi front et la persistance serveur ; `trigger=master_button|remote_button|session_not_found`, surface, request_id, Hub, exécution, source/runtime numériques, génération/intention et page éphémère. Le relais Bingo conserve ces diagnostics ; PHP relit les identités et la publication canoniques, puis garde le même request_id dans `hub_suspended` et `hub_suspend_released`. Liste explicite de champs, aucun token de session/reprise/accès ajouté au diagnostic. Les anciens clients sans diagnostic produisent `unspecified` ; aucune causalité rétrospective inventée pour Hub120/session30700/runtime17898.


Réglages Hub Quiz (16/09/2026) : projection commune `series_names` depuis le helper de métadonnées existant ; aperçu dans la modale actualisé par les réponses/refreshs actuels. Aucun nouveau endpoint ou poll. La visibilité du pilotage manuel reste pilotée par `paperMode` ; le CSS Remote respecte désormais `hidden`.

## Préparation Hub : actualisation et contenu — 16/09/2026, local non déployé

Quick Add : après commit, présence de la session créée dans le Programme = affichage actualisé ; sélection et `in_flight` ne prouvent pas un échec. Retry d'affichage sans recréation. « ↻ Proposer une autre playlist » (Blind Test/Bingo) / « ↻ Proposer d’autres séries » (Quiz) apparaissent dans les réglages Master/Remote pour toute session prête compatible, sans origine imposée. Même commande HTTP et même service Global, revalidation sous verrou lancement/retrait, pas de nouveau canal inter-surfaces. Révisions Master et partagées Remote/Pro inchangées ; options runtime/WS/inscriptions inchangés. [Audit et validations](../../notes/hub-quick-add-renewal-2026-09-16.md).

## Retrait de membre Hub — 16/09/2026, local non déployé

Actions Hub `session_remove` (Master organisateur/CSRF/instance ; Remote accès/CSRF/instance avec Master présent) et commande Remote `remove_session`, exécutée par le poll Master. Service Global revalidé sous verrou ; réponse positive après rebuild réel pour les démarrées, retryable sur échec partiel. Le contexte runtime ne résout plus un membre retiré. `hub_execution_removed` ferme l’exécution ouverte, sans effacer le journal de suspension qui maintient le gel jusqu’au cleanup canonique de cutoff. Aucun nouveau protocole WS ni changement de `hub_suspend`. [Détails](../../notes/hub-session-removal-audit-2026-09-16.md).

## `hub_lifecycle` — suspension officielle, patch local non déployé

Le bridge exige le service token pour toutes les étapes, y compris `read`. La réponse suit l’enveloppe existante `{ok,data,error}` ; les clients WS normalisent le `data` déballé avant de vérifier le succès métier. `read` retourne `state` et peut retourner `activation_allowed=false` après cutoff. Un échec de lecture reste bloquant pour une inscription runtime : il ne vaut jamais preuve d’absence de suspension.

Les étapes `validate` → Pause/gel moteur → `suspend` → ACK → `release` précèdent le retour des surfaces. `release` appelle le clear focus conditionnel existant, conserve l’exécution ouverte et écrit le marqueur de libération. Le Hub ne délivre la reprise qu’après cette libération. `resume` vérifie le jeton de reprise, la génération, le focus et la fenêtre canonique avant de journaliser le dégel.

Marqueurs `game_events` : `hub_suspended`, `hub_suspend_released`, `hub_resume_requested`, `hub_resumed`. Ils portent les identités et le cutoff ; aucun snapshot de gameplay, nouveau statut DB ou migration. Les anciennes commandes `pending/claimed/processing` sont invalidées. Les présences runtime sont effacées à suspension/reprise ; un heartbeat suspendu ou d’une ancienne génération ne réarme pas le routage. `client_routing` refuse une suspension même avec présence stale.

`update_score` vérifie aussi le token résolu depuis l’ID de session historique Quiz/BT : fournir un autre token ne contourne pas le gel. Bingo vérifie aussi le scope playlist de `grid_get_or_assign`. Les actions gameplay suspendues échouent avec `HUB_SESSION_SUSPENDED` (HTTP409). Hors suspension, les handlers existants restent utilisés. [Contrat complet et tests](../../notes/hub-suspend-patch-2026-09-10.md).


16/09/2026 — Notifications gagnantes Bingo : reconstruction depuis winners structurés à la lecture WS, formatter commun live/reprise. Log PHP historique et tous les writes conservés. Contrat détaillé dans `canon/repos/bingo.game/README.md`. Patch local non déployé.

<!-- AUTO-UPDATE:END id="hub-suspend-20260910-bridge" -->

> **Maintenance pact**
> - Codex: you may only edit inside `AUTO-UPDATE` blocks.
> - Humans: edit anything outside blocks; keep block IDs stable.

# Canvas Bridge API (Contract)

<!-- NOTE TO CODEX:
Only edit inside AUTO-UPDATE blocks.
If required info is missing, update HANDOFF next steps instead of guessing.
-->

> Single source of truth for request/response formats and conventions.

<!-- AUTO-UPDATE:BEGIN id="bridge-contract" owner="codex" -->

### Hotfix hub_soiree — admission et attente runtime (23/09, non déployé)

`hub_capacity_get` reste service-only. Avec `stage=admit`, `game`, `sessionId` token, `hub_id`, `execution_id`, `player_id`, il valide fraîchement l’exécution officielle courante, fenêtre/expiration/focus/retrait/suspension/terminal, puis Player actif + mapping actif du jeu/session + participation réelle. Réponse ciblée : `ok`, `targeted:true`, `hub_id`, `session_id` numérique, `execution_id`, `player_id`, `identity`, `participation_id`. Aucune lecture roster complet, décision commerciale, synchronisation de jauge ou stock/GET_LOCK Bingo. Papier/démo retournent `targeted:false` et conservent le contrôle historique ; preuve négative refuse, elle ne peut déclencher un bypass. Sans contexte officiel WS fiable, le moteur utilise directement le chemin historique sans stage.

Master : l’action existante `remote_runtime_presence`, `source=autostart_validate`, effectue une lecture autorisée organisateur sans écrire de présence ; contrôle E1/Hub/session/lifecycle et instance/routing courants ; renvoie `ok,started`. Runtime-ready conserve sa sémantique locale et ajoute `hub_id,execution_id`. Timeout10 s non terminal pour officiel numérique ; papier/démo inchangés. Garde par onglet Hub/token/E1 avant begin, protections existantes conservées. Le délai local15 s de la Remote ne rend plus son observation définitivement abandonnée pour une session officielle numérique identifiée dans le programme serveur ; navigation toujours conditionnée au routage serveur joinable et à sa génération courante. [Contrat complet et risques](../../notes/hub-soiree-hotfix-2026-09-23.md).


## Hub readiness v1 — 23/09/2026, patch local

[Contrat complet](../../notes/hub-session-readiness-2026-09-23.md). API service-only `hub_readiness` : read/admit/decide/consume/started. Journal Global game_events ; verrous Hub puis admission ; roster et Master courant validés. Preuve WS `hubPlayerReady` après hydratation appliquée, scope Hub/session/E1/incarnation/identité/génération/challenge. `hubPreparationPoll`, `hubPreparation`, `hubHydrationRequest`, `hubHydrate`, `hubHydrationProof` (Bingo), `hubStartRequest`/`hubStartAccepted` continuent la même intention. Aucun diagnostic Browser n’autorise le gameplay.

La préparation E1 conserve une deadline unique ; all_ready ou borne avec runtime sain, sans CTA. Défaut recette `HUB_SESSION_CONVERGENCE_MS=15000`, non qualifié produit. Bingo prépare le reset initial via l’opération durable existante avant preuve ; E1 started/retardataires ne le rejouent pas. Legacy/papier/démo conservent leurs protections. Nouvelle admission ciblée WS, contrôles publics PHP restants inchangés.


## 21/09/2026 — Identité et population papier

`player_register` valide la provenance historique et K contre le compte organisateur. `players_get` live et preload partagent population active, canonique et admise ; historique explicite via `includeInactive`. Remote Hub retourne le droit d’ajout libre calculé côté PHP et assure les participations tardives du focus papier vivant. [Contrat](paper-roster.md).


Signin/signup Hub —21/09 : contexte d’affichage Hub commun aux sources WWW session et Games Hub ; branding résolu au niveau Hub sans session, métadonnées via helper canonique Games. Les paramètres d’authentification et les destinations probable EP / join Hub Play restent inchangés. Aucun nouveau token, write ou protocole runtime.


Complément21/09 — compte depuis Hub Play : le GET signin/signup déjà authentifié avec `hub_account_action=join` reprend l’admission canonique, comme le POST d’authentification, et revient à Hub Play si elle réussit. Fenêtre et jauge restent contrôlées ; `probable` reste EP sans admission. Le partage de probable utilise uniquement une URL de consultation WWW. Aucun protocole runtime modifié.


### Entrées publiques EP / WWW / QR — 20/09/2026

Contexte `app_games_hub_participation_cta` en lecture seule : `probable`, `cancel_probable`, `public_hub_play`, `closed` ou `none` ; `ep_join` supprimé. EP session/agenda/Hub n’exposent que probable/cancel, même fenêtre ouverte ; lecture individuelle Hub sans fallback legacy. WWW session revient à la fiche EP source après auth ; seule l’intention QR permanent `open` produit une URL Hub Play. Le retour auth `probable` ne crée aucun joueur ; `join` explicite depuis Hub Play reste disponible aux admissions terrain. Aucun changement Player, QR session/Hub, Master, Remote, jauge ou protocole runtime. [Contrat révisé, tests et limites](../../notes/hub-access-probable-only-2026-09-21.md).


### Ancienne URL Player Hub — 20/09/2026, local non déployé

`/play/{game}/{session_token}` est un alias vers Hub Play si une membership Hub est résolue. Décision dans `player_canvas.php` avant preload/HTML. Seul le contexte existant `hub_token` + `hub_player_token` + `hub_player_id`, validé sur le joueur actif, le focus rejoignable, l’exécution officielle ouverte et son mapping actif complet, autorise le Player numérique. Aucun nouveau paramètre de bypass. Source terminée/non focus et paramètres incomplets reviennent au Hub. Hub inactif/papier : retour Hub contrôlé ; autonome/démo serveur : parcours existant.

Retour EP session : résolution read-only du jeton court avec session/jeu, puis helper `app_games_hub_player_prepare_ep_return` inchangé. Fenêtre ouverte : nouveau retour Hub, sans runtime source ; avant/après fenêtre : routes EP Hub `pending`/`closed` existantes, sans création officielle. Les APIs `player_register` et les mécanismes internes ne changent pas. Voir README Games, « Entrée Player session vers Hub Play — 20/09/2026 » et `games/web/tests/hub_player_entry_test.php`.



### `hub_session_grace_expired` — expiration exacte, 18/09/2026, local non déployé

Action service-only existante, aucun nouvel endpoint. `hub_lifecycle/read` retourne désormais `execution` : `hub_id`, `execution_id`, `source_session_id`, `runtime_session_id`, `runtime_mode=official`, `routing_generation`. Le moteur mémorise cette identité et la copie à l’armement de la grâce ; changement d’exécution sur le même objet vivant refusé. À l’expiration réelle seulement, payload `{game, sessionId, hub_id, execution_id, source_session_id, runtime_session_id, runtime_mode, routing_generation}`. Les IDs numériques et la provenance sont revalidés ; `sessionId` sert au transport, jamais aux nouveaux diagnostics.

Événement persistant `game_events.action=hub_runtime_expired` : `hub_id`, `session_id` numérique, `source_session_id`, `runtime_session_id`, `execution_id`, `engine`, `reason=primary_grace_expired`, `request_id=primary-grace-expired`, `routing_generation`. La colonne historique `game_events.session_id` reste le token source. `event_id = hublife- + sha256("hub_runtime_expired|" + execution_id + "|primary-grace-expired|")[0:48]` ; `INSERT IGNORE`, même clé sur retry. Ni `hub_execution_completed`, ni modification de phase, ni purge des résultats.

Succès officiel : `persisted=true`, `cleared`, identités, `reason`. Notification obsolète/invalide ou suspension explicite : succès sans effet (`persisted=false`, motif explicite). Échec SQL/lock/clear : pas d’acquittement final, retry moteur avec même identité ; la lecture de journal en échec n’autorise aucune recréation. Le clear est sérialisé avec le lancement et conditionné à session/génération/date d’activation ; présentation conservée. L’enveloppe HTTP enlève `data.ok` : les callers WS normalisent le succès transport avant traitement.

`app_games_hub_official_execution_is_reusable()` consulte ce marqueur exact. Lancement Master, commande Remote, `execution_context_create(force_new)` et restauration lifecycle refusent `HUB_RUNTIME_EXPIRED` avant publication ou fallback. [Tests et limites](../../notes/hub-runtime-expired-2026-09-18.md).


### Préparation papier Hub Remote — 17/09/2026, local non déployé

Les actions HTTP papier existantes acceptent `paper_lobby_scope=hub` pour l’ouverture anticipée, sans `session_id` client. Le serveur revalide l’éligibilité et résout une référence technique déterministe ; le snapshot expose `paper_preparation.available` et `uses_teams`. Le roster reste Hub-scoped, sans commande de lancement, mapping runtime ou publication de routage. L’ajout et l’undo conservent la preuve d’ouverture existante ; une ancienne ouverture ne ferme pas la nouvelle. Le parcours historique par `session_id` reste disponible.

Lookup global joueurs et équipes si Quiz papier présent, clés et formes de payload existantes conservées. La saisie libre passe avant mutation par `canvas_session_has_referenced_participant_name` avec normalisation runtime et option interne `failClosed=true` ; refus `USERNAME_REFERENCED`, ou indisponibilité si la vérification échoue. Les appels runtime historiques gardent le comportement par défaut du helper. Aucune migration ni différenciation persistée Équipe/Joueur. [Contrat, contrôles et limites](../../notes/hub-paper-early-roster-audit-2026-09-17.md).


### Cycle démo Hub — 17/09/2026, local non déployé

Extension des routes HTTP existantes : POST `action=demo_lifecycle`, `operation=heartbeat|close`, `session_id` source, `runtime_session_id`, `execution_id`, `csrf_token`. Master exige les droits organisateur ; Remote exige son accès validé. La correspondance de l’exécution démo ouverte est revalidée ; une ancienne exécution ne peut modifier la suivante. Réponse `ok`, `closed`, erreur en cas d’échec storage/CSRF. Aucun nouveau endpoint WS ni migration.

Journal `game_events`, action `hub_demo_lifecycle`, clé stable Hub/source/intention : préparer, activer par présence, fermer irréversiblement. Publication de routage sélectionnée par source/exécution/intention/génération exactes, y compris prospect via `launch_session` et client actif via `launch_hub_demo`. Présence3s, perte >12s après arrivée, expiration45s si aucun Master arrivé. Les défauts de transport ne sont pas une autorisation de reprise. Retour démo : fermeture keepalive + marqueur local anticourse ; suspension officielle inchangée. [Détails](../../notes/hub-demo-lifecycle-patch-2026-09-17.md).


### Test de session Hub — 17/09/2026, local non déployé

Les routes existantes `launch_hub_demo` exigent une source explicite. Master : POST `session_id`, `launch_intent_id`, CSRF, contexte organisateur/instance courant ; service Global ciblé. Remote : POST `session_id`, `command_key` stable pour le retry, CSRF ; payload commande `session_id`, `source=hub_remote`, `contract=hub_remote_demo:v2`. Le consommateur Master relit la source et appelle le même service avec `remote-command-ID`. Remote ne crée pas de démo. Une commande failed/expired peut être réarmée explicitement avec la même clé et source ; les autres états ne sont pas réouverts. Une clé réutilisée pour une autre source est refusée.

Le composant de confirmation capture la source avant son attente et appelle `hubLaunchSessionTest(sessionId, intent)`, également utilisé par les réglages. Un nouveau geste volontaire produit une nouvelle intention ; le retry dans les réglages garde son intention. Papier permis sur les deux surfaces, runtime toujours numérique. Aucun nouvel endpoint ni changement de protocole readiness/routing. Le service ciblé ignore les démarrages des autres sessions et la trace historique QR ; il refuse toujours une cible déjà démarrée. La confirmation du premier lancement se base sur les officielles encore présentes : une suppression peut rétablir cette confirmation.


### Lecture agrégée Hub — 16/09/2026, local non déployé

Le fallback Global de `aggregate_ranking` relit les sessions membres actives et borne le SELECT historique avec `allowed_session_ids` avant agrégation, pour période et événement. Ensemble vide = aucun résultat ; photos enrichies uniquement sur les lignes restantes. Payloads/actions Canvas, rebuild nominal et usages historiques hors Hub sans option inchangés. [Validation](../../notes/hub-session-removal-audit-2026-09-16.md).


## Hub Remote — boucle automatique selon présence runtime — 10/09/2026

Contrat local implémenté, non déployé : une Hub Remote suit automatiquement la Remote de la session Hub en cours uniquement lorsque son Master runtime exact est présent. Si cette présence expire pendant l’utilisation de la Remote session, celle-ci revient automatiquement au Hub Remote. Si le Master revient, le Hub peut rerouter vers la même exécution et la même génération, sans clic.

Cette révision remplace les descriptions antérieures de récupération manuelle, de blocage du tuple retourné et d’abandon d’un accès déjà réussi. Les sections datées des 01–09/09 décrivant ces dispositifs sont historiques et ne définissent plus le contrat courant. Les assertions anciennes autorisant `existing` sans présence sont également remplacées.

- Hub → Remote : seul `control_poll.client_routing` autorise la navigation. `existing` conserve l’exécution et n’attend aucune nouvelle readiness ; `new/recreated` conservent leur readiness. Tous exigent la présence runtime exacte. Aucun changement du compteur causal.
- Remote → Hub : `AppConfig.hubRemoteReturn.presenceUrl` expose l’action autorisée `runtime_presence` sur le module `hub_remote`. Lecture de la session source appartenant au Hub, de son exécution ouverte et du runtime correspondant, puis getter Global existant. Cette lecture ne suit pas le focus et ne touche ni l’instance Remote, ni les commandes. Une erreur de contexte/lecture reste inconnue, jamais assimilée à une absence.
- Heartbeat Organizer inchangé : 3 s ; TTL SQL inchangé : 12 s. Observation Remote immédiate puis toutes les 2 s après réponse ; timeout HTTP 5 s traité comme erreur, sans navigation. Pas de deuxième grâce. Le délai dépend du réseau et de la disponibilité des timers navigateur. La présence reste celle du producteur HTTP actuel, sans nouvelle garantie de connexion WS continue.
- Le retour utilise la destination Hub validée et `hub_remote_returning=1` pour le voile existant. Aucun `returned_execution_id`, `returned_routing_generation` ou alias de blocage n’est émis ni lu par le Hub. Les paramètres d’entrée `hub_remote_execution` et `hub_routing_generation` restent nécessaires au contexte de la Remote historique.
- `accessWait` conserve uniquement la protection des attentes causales réellement engagées : une attente expirée reste abandonnée en sessionStorage et ne peut accepter une arrivée tardive. Un accès réussi est enregistré `completed` dans ce même état ; il ne peut plus être réarmé ni abandonné au retour. Une publication déjà expirée, jamais attendue par ce client, ne crée pas d’abandon. Les générations anciennes restent filtrées. Sans sessionStorage, la mémoire ne traverse pas les changements de page.
- Les CTA de récupération ont disparu des notices. `PRIMARY_DISCONNECTED` conserve l’information et désactive les commandes ; `GAME_RESUMED` restaure l’UI et invalide une observation en vol. Quit demandé/en confirmation, fin naturelle, terminaux et bootstrap restent prioritaires ; une navigation unique, sans commande métier. Hors Hub valide : aucune observation.
- Officiel/démo et papier/numérique utilisent la même règle avec validation source/runtime. Aucun changement de duplication, injection, confirmation officielle, état métier, focus, génération, readiness, serveurs de jeux, grâce longue ou producteur Organizer.

### Reprise numérique active — 09/09/2026, local

Master `launch_session` peut transmettre `expected_execution_id` pour la session active. Global conserve l’exécution officielle existante (aucune création de secours), publie via l’intention canonique une nouvelle `routing_generation` et retourne `transition_type=resume_existing_runtime`. URL Organizer : `hub_execution`, `hub_transition=resume_existing_runtime`, `hub_routing_generation`, sans `hub_launch=1`. Validation serveur du focus/runtime/exécution/génération avant projection `hubResumeExisting`, bootstrap Pause et aucune lecture automatique. Le retour Remote ne bloque plus le tuple ; la présence exacte autorise aussi la même génération. Remote Reprendre appelle déjà le même service. Aucun nouveau type d’exécution, WS/Play/terminal inchangés. [Audit complet](../../notes/hub-active-master-resume-2026-09-09.md).


### Préparation papier Hub Remote — 2026-09-09, local

Confirmation au dernier CTA avant submitLaunchSession, avec verrou local pendant attente ; annuler ne publie aucune intention. Préparation et inscriptions existantes non modifiées. Projection settings.game/paper_mode déjà disponible utilisée pour le vocabulaire équipes Quiz dans la seule modale ; aucun payload, mapping, endpoint ou champ DB modifié.


### Recovery Remote papier et officielle numérique Hub — 2026-09-09, local non déployé

`remote_canvas.php` ajoute `hubRemoteReturn.contextType` (`event|soiree`) depuis le Hub déjà résolu, sans nouvel appel. Le CTA Hub papier, étendu aux runtimes numériques explicitement `runtimeMode=official`, consomme `HubTransition.remoteRecoveryUrl()` : destination validée + tuple executionId/routingGeneration positif, marqueurs de retour existants dans l’URL ; tuple incomplet = aucune sortie non gardée. Navigation seule, sans signal terminal, quit, clear focus ou mutation runtime. Garde Hub et publication générationnelle inchangées ; numérique démo, mode numérique absent/inconnu et hors Hub exclus. Le message numérique reprend exactement l’aide papier : reprendre la diffusion depuis l’ordinateur puis retourner à la soirée/événement. `GAME_RESUMED` conserve sa fermeture automatique de notice.

### Test annexe actif — complément DEV 09/09/2026

`launch_hub_demo` garde ses entrées sans `session_id` cible et son resolver unique. Le fallback Quiz papier incompatible conserve `source_session_id` officiel et produit un runtime numérique isolé ; les autres lancements sont inchangés. Une commande Remote démo échouée persiste le message métier dans `result_json.message` et l'expose via `command.message`. Le renderer de cette commande affiche ce texte (fallback français si absent), sans modifier les messages des autres commandes. Voir README Global/Games pour cardinalité et gardes.


### Compatibilité legacy Hub — 2026-09-08, locale

Les entrées Organizer/Player/Remote résolvent le membership actif sans créer de Hub ni modifier les champs historiques. Hors exécution Hub explicite et vues terminales, l'ancienne entrée rejoint le Master/Play canonique. Remote exige un accès existant et un propriétaire ou une session Remote liée ; un simple token de session ne délivre aucun accès Remote. Sans membership, le chemin legacy reste disponible avec diagnostic. Les lots du résultat sont ceux de la session exacte ; aucun lot d'une autre session n'est promu. Les commandes de focus, présence, lancement et les contrôles commerciaux restent distincts de cette résolution. Voir les contrats README Global/Games/Pro et [rapport](../../notes/hub-legacy-runtime-compatibility-2026-09-08.md).


### 2026-09-08 — Intention locale de lancement officiel Hub

La confirmation concerne uniquement le premier lancement officiel du Hub. Master et la projection Remote `sessions[].action.confirm_official` consomment `games_hub_has_official_launch()` : trace Hub existante `player_qr_official_started_at`, ou au moins un `hub_has_started` canonique parmi les sessions officielles déjà chargées. Calcul serveur pur, sans requête ni write supplémentaire ; pas de récupération/mutation QR déclenchée. Démo seule exclue ; une officielle terminée/suspendue ou la trace durable suffit à dispenser les sessions suivantes. Les gardes session conservent l’exclusion des reprises/relances. Wording Hub unique papier/numérique, titre « Démarrer la soirée maintenant ? ». Confirmation locale avant POST, queue et sas papier ; aucune publication de confirmation_requested. Le consommateur Master de commande ne confirme pas. Annulation sans mutation issue du clic ; guards serveur et payload de lancement inchangés. Reprise/relance consommée et démos exclues ; papier officiel Remote-only.

Le garde front `isOfficialHubOrchestrated()` exige le contexte `hubOrganizer` activé, officiel, avec executionId et identité source/runtime concordante. Il supprime seulement les automatismes historiques diagnostic/QR papier incompatibles et le blocage prelaunch automatique de reprise. Aucun nouveau marqueur/endpoint ni changement au resolver, à la readiness, au focus ou au routage. [Preuves et recette](../../notes/hub-launch-resume-ux-2026-09-08.md).


### 2026-09-08 — Blind Test équipes en stand-by

Le WS OFF produit des classements individuels. Dans `blindtest_adapter_glue.php`, `_bt_persist_session_teams` retourne `ok=true`, `changed=false`, `skipped=true`, `reason=NO_TEAM_RANKINGS`, `teams=0` quand aucun participant équipe valide n’est fourni : aucune suppression des équipes historiques dans ce cas. Le traitement des snapshots équipe existants, `session_teams_get` et le preload des résultats sont conservés. Aucun schéma, endpoint ou contrat Hub nouveau ; `update_score` et les writes principaux de `session_update` ne changent pas.

### 2026-09-08 — `hub_session_natural_ended` : provenance de fin

Patch local : avant `hub_execution=true`, le bridge vérifie le start brut du dernier lancement pour le Hub/source (execution_id, mode, source/runtime/session primaire). La validation vaut pour démo, focus actif, recovery et `already_completed` ; ce dernier doit retrouver le start de la completion. Démo annexe de la source, provenance incompatible ou incomplète : `hub_execution=false`, fin historique, aucun clear/complete/rebuild. Le resolver générique garde ses fallbacks, les completions existantes ne sont pas réparées. Recovery officielle exacte et INSERT IGNORE idempotent conservés. Starts legacy sans métadonnées : pas de retour Hub via ce bridge. Ancienne officielle exacte encore ouverte sans preuve de nouvelle incarnation : ambiguïté temporelle non résolue, pas de changement WS/lancement. Dépendance de livraison : helper Global + bridge Games, Global disponible d'abord ; aucune nouvelle requête client ni changement de payload. Voir [rapport et tests](../../notes/hub-historical-player-end-audit-2026-09-07.md).


Historique du correctif Hub 288 (07/09), précisé le 08/09 pour Hub 296 : la preuve de session terminée avec podium exploitable (has_podium, rang 1–3, nom non vide) sert désormais seulement à valider une réduction de podium effectivement engagé. Elle ne bloque plus à elle seule l’éligibilité serveur. Celle-ci dépend de la suite officielle jouable/reprenable ; voir le contrat QR du 08/09. Aucun reset de présentation, de trace officielle ou de préférence reduced.
# Canvas Bridge API — contract (implementation-aligned)

## Endpoint
- `POST /GAMES/games_ajax.php?t=jeux&m=canvas` (alias historique: `/GAMES/global_ajax.php?t=jeux&m=canvas`)
- Request body:
  - `application/x-www-form-urlencoded` pour les appels bridge classiques
  - `multipart/form-data` toléré pour les uploads, notamment `session_podium_photo_upload` depuis la remote `games` et `player_podium_photo_upload` depuis `player_canvas`
- Response: JSON enveloppé `{ ok, data, error, ts }`
  - Les clients front qui attendaient historiquement un payload “plat” doivent lire les champs dans `data` (ou déballer `data`).

## Projection UI Hub — complément local du 07/09/2026

Le endpoint Hub existant `players_count` ajoute `active_count_confirmed: boolean` à côté de `active_count` et `active_players`. Le Master garde sa colonne droite et ses deux zones. Un entier zéro confirmé s’affiche discrètement dans l’en-tête Joueurs inscrits, avec masquage du seul grand compteur ; réseau, payload incomplet et lecture SQL non confirmée ne remplacent pas le dernier état. `active_count` et les usages Play/Remote restent inchangés. Le snapshot Remote ajoute `hub_branding.location` et `sessions[].visual_url`, dérivés des helpers Games existants et rendus à l’identique en PHP/JS. Le classement vide présente `Le classement apparaîtra ici après les premières parties.` ; le rafraîchissement partiel existant intègre une projection non vide et ne remplace pas un classement connu par une projection absente. Le titre du QR actif est `SCANNE POUR JOUER`, typographie de titre latéral partagée, QR prospect inchangé. Le bridge Canvas, `display_presentation`, `control_poll.client_routing`, droits et cadences ne changent pas. Le pilotage QR dédié est décrit ci-dessous.

## Pilotage du QR joueurs Hub — B local

### 2026-09-17 — QR initial produit par PHP

Contrat local non déployé : la `play_url` canonique est encodée une fois par réponse HTML Master officielle en PNG mémoire (ECC M, scale12, marge4), réutilisé petit/grand via data URI et marqueur `data-hub-player-qr-render`. Découverte : cadenas, zéro vrai QR et aucune URL de secours. Erreur encodeur : lien HTML/URL complète officiel. Poll JSON et Play n’encodent pas ; aucune route, donnée, queue ou cadence ajoutée.

Le contrôleur confirme seulement une IMG marquée complète avec naturalWidth/naturalHeight et dimensions DOM positives. Load/error en capture fonctionnent aussi après refresh ; le grand est montré/mesuré avant masquage du petit, sinon rollback accessible et aucune confirmation expanded. Refresh importe le PNG/texte déjà rendu et actualise le dialog existant, sans encodeur JS. Le script change de contrat avec `?v=filemtime` ; les deux fichiers Games sont à livrer ensemble. CDN QR absent du Master ; SweetAlert/confirmation defer, polices/icônes non bloquantes. Sans JS, petit QR/HTML initiaux conservés ; interactions avancées non garanties. Les règles de priorité, reprise, persistance et éligibilité décrites ci-dessous restent applicables.

[Validation et limites](../../notes/hub-player-qr-server-2026-09-17.md).

### 2026-09-08 — Éligibilité QR réversible selon le programme courant

Correctif local du Hub 296 : `app_games_hub_player_qr_has_continuation()` lit les sessions canoniques du Hub (membership active, organisateur du Hub, officielles, configuration complète). Une session avec token et jeu supporté compte si elle est `pending` ou `running`, non terminée, et passe le garde de lancement métier ; une exécution officielle ouverte réutilisable conserve l'exception du service de lancement. `running` sans focus signifie suspendue/reprenable : ce statut ne termine pas le programme. `terminated`, `completed`, démo seule, configuration incomplète, jeu non supporté, token absent ou refus métier ne constituent pas une suite. Aucun nouveau calcul à partir de la date de session : les statuts proviennent du loader canonique ; pour les jeux modernes, ils dérivent des phases runtime. Un statut/garde non résolu sans autre candidat confirmé interdit l'agrandissement ; exception de lecture = repli indisponible. Une liste vide interdit l'agrandissement, y compris si le loader renvoie vide après un échec de lecture.

`available` conserve activité Hub, accès officiel, absence de découverte, fenêtre `before|open` et données nécessaires résolubles. `can_expand = available && suite_jouable && !runtime_actif && !priorité_temporaire`. Côté serveur, `active_session_id>0` et le mode explicite `hub_podium` restent prioritaires. `presentation_session_id` terminée avec un ancien podium n'est plus un veto serveur, même en mode `session` ou `hub_idle`. `app_games_hub_player_qr_session_priority()` reste une preuve pour valider la réduction d'un podium réellement engagé, pas une définition de la fin du programme.

Complément Master du 08/09 après confirmation navigateur Hub 296 : `27718` était le seul podium avec `hidden=false` malgré `can_expand=true` et la partie suivante `27731`. Les résultats statiques issus de `session_results` portent désormais `data-hub-podium-preview="1"` : ils restent consultables dans le carrousel, mais ne constituent pas une présentation prioritaire QR. Le contrôleur ignore uniquement ce marqueur explicite ; un podium visible non marqué (notamment le podium global activé en `hub_podium`) conserve priorité, masquage et réduction acquittée. Les podiums runtime historiques des jeux ne sont pas modifiés. `hub_idle` masque aussi les aperçus de session et rend le branding, sans changer la session persistée.

Master et Remote partagent toujours policy, queue et confirmation. Une action explicite peut agrandir le QR par-dessus un aperçu historique quand le serveur l'autorise ; aucune action ne couvre un podium prioritaire. Réception d'un poll favorable à la même révision, ajout de partie, refresh et reload ne réactivent plus le verrou historique et ne provoquent aucune expansion automatique. Aucun nouveau flag persistant, endpoint, poll ou write Global. Le marqueur d'aperçu nécessite le renderer PHP et le JS Games ensemble ; un ancien HTML non marqué reste conservativement prioritaire jusqu'à son remplacement par le rendu actualisé.

Après fin de A, avec B prête/reprenable, le contrôle redevient utilisable hors priorité visuelle, même si la présentation serveur reste sur A. Sans suite, `can_expand=false` ; l'ajout autorisé d'une nouvelle partie le rétablit au poll/refresh existant, une fois toute présentation podium active quittée. Cette réévaluation ne modifie ni mode persistant, ni révision, ni date du premier officiel, ni présentation : `reduced` reste `reduced` jusqu'à une action explicite. Lancement/podium engagé, queue, CAS, instances, confirmations, TTL et cadences restent inchangés. Aucun DDL, réparation DB, déploiement ou redémarrage.


Implémentation locale autorisée le 07/09 après import DEV confirmé. Aucune nouvelle route Canvas : POST à l’URL Hub Master courante, ou action du handler Hub Remote existant. Code : Games `app_hub_view_helpers.php`, `app_hub_remote_ajax.php`, `includes/canvas/core/hub_player_qr.js` ; Global `app_games_hubs_functions.php` et `app_games_hub_player_qr_functions.php`.

| Échange | Champs et validation |
|---|---|
| Commande `player_qr_display_set` | `mode=expanded\|reduced`, `revision` entière attendue, `command_key` de 1 à 64 caractères `[A-Za-z0-9_-]`, `csrf_token`. Master : `master_instance_id` courant. Remote : son `remote_instance_id` courant et `qr_master_instance_id` cible, accès et présence Master validés par les gardes existantes. |
| Queue existante | Payload `{mode, revision, master_instance_id}` ; clé persistée `qr-{id_remote_access}-{command_key}` (0 pour Master). Même clé et payload = même commande ; clé réutilisée avec payload différent = conflit. TTL 20 s, claim/complete/failed/expired/cancelled existants. |
| Poll Master `remote_control_poll` | `player_qr_confirmation` JSON exact `{revision, instance_id, mode}`, 256 octets maximum ; révision entière positive sûre JS, instance de 1 à 80 caractères `[A-Za-z0-9_-]`, mode autorisé. `csrf_token` valide et Master courant requis. `player_qr_priority` et `player_qr_priority_session_id` signalent séparément le podium appliqué : preuve de fin Hub/session vérifiée côté serveur. Aucun droit transmis par le navigateur. |
| Polls Master/Remote | `player_qr` expose `available`, `can_expand`, `priority`, `revision`, `mode`, `confirmed`, `confirmed_mode`, `instance_id`. La requête peut joindre `player_qr_command_id` ; `player_qr_command` renvoie id/statut/erreur de la commande QR du Hub. Un stockage indisponible ne garantit que `available=false`. |

La cible persistante est séparée de l’état appliqué : `confirmed` nécessite même révision, même instance Master courante, même mode et éligibilité actuelle. Une ancienne confirmation ne valide jamais une nouvelle instance. Le navigateur confirme uniquement l’image QR marquée, chargée et dimensionnée (contrat PNG du17/09). Une confirmation identique n’effectue pas de nouvel UPDATE. Le terminal `completed` de la queue ne suffit pas à afficher une réussite. Les libellés sont `Réduire le QR` / `Agrandir le QR`, avec attente/réponse utilisateur sobre et aucun nom d’état technique.

Les quatre champs `games_hubs.player_qr_*` sont l’autorité QR. Initialisation réduite par comparaison `mode IS NULL`, sans historique de lancement ni automatisme temporel. Ni focus vide ni compteur de joueurs ne prouvent l’absence de lancement. Chaque modification compare révision et instance ; la sélection/focus courants sont aussi comparés pour refuser une décision devenue périmée. Un lancement officiel réussi réduit, incrémente la révision et conserve la première date via COALESCE ; une démo réussie réduit sans renseigner cette date. Un refus/échec ne change rien. Les anciens agrandissements échouent au claim après réduction. Aucun write QR sur `games_hubs` ne modifie `date_maj`, focus, sélection, participation, `display_presentation` ou génération.

Runtime et transitions masquent le grand QR immédiatement ; une interruption technique seule ne change pas la préférence. Un podium réellement engagé et validé réduit durablement : le navigateur retient son application entre deux polls pour éviter une réapparition après fermeture rapide. Après une écriture QR de lancement échouée, le serveur dépose dans la queue existante un reçu terminal `player_qr_display_set`, clé réservée `qr-launch-reduction-{revision}`, cible reduced/révision/instance et résultat `{launch_reduction_pending:true, revision, mode:"reduced", runtime_mode:"official"|"demo"}`. Il atteste le lancement réussi, pas un affichage confirmé ; aucun nouveau claim ni timer. Au poll suivant, seule la révision toujours identique est réduite et incrémentée, première date officielle conservée ; le reçu devenu ancien ne peut effacer une action manuelle plus récente. Le contrôle par clé unique évite un write répété. Cette reprise couvre aussi les parties suivantes et les démos. Pour une première date manquante, les reçus antérieurs `launch_session.completed` officiels ou `master_launch` corrélés à leur événement restent des preuves de secours lues seulement. Une simple tentative échouée ne remplace pas une préférence initialisée. Aucun réagrandissement automatique au retour.

QR manuel uniquement (consigne du 07/09 remplaçant l’accueil automatique) : arrivée réduite par défaut dans toute fenêtre. `initialize` initialise un mode NULL à reduced et incrémente sa révision, sans lecture de l’historique de lancement ni modification de la première date officielle. Agrandir exige une action explicite Master/Remote ; gardes d’éligibilité, réduction lancement/podium, queue et cadence inchangées.

Le choix expanded est restauré après reload/reconnexion/remplacement seulement si un reçu réussi de commande explicite expanded correspond à la révision persistée. Le reçu peut provenir de l’ancienne instance : il prouve le choix, pas l’affichage actuel. La nouvelle instance doit confirmer son application avec son propre identifiant. Un ancien expanded automatique sans ce reçu reste rendu réduit ; la préférence brute n’est pas effacée. Une réduction ou un lancement incrémente la révision et empêche la restauration depuis l’ancien reçu. Si le journal est indisponible, repli réduit, jamais déduction d’un choix manuel.

Le Master conserve son effet immédiat, Échap/focus et le masquage latéral avec emplacement réservé. La carte sombre et le grand QR arrondis sont centrés dans l’espace du viewport sous le titre/sous-titre du Hub. Aucune migration ni nouvelle boucle.

Master applique désormais une intention visuelle immédiate dans une superposition indépendante avant réponse de la queue. Elle n’est pas un nouvel état serveur : le POST, l’éligibilité, la révision attendue, l’idempotence et le claim restent identiques. Les clics locaux suivants remplacent l’intention ; les réponses POST précédentes et leur confirmation ne l’annulent pas. Un refus/conflit/terminal ou délai de la demande courante retire l’intention et réconcilie le dernier état serveur. Des commandes croisées restent susceptibles de conflit de révision, explicitement signalé, sans retry automatique. Le Master confirme un mode temporaire uniquement lorsqu’il correspond effectivement au mode/révision persistés (hors signal séparé de priorité métier existant). La Remote reste sans anticipation d’affichage et garde son verrou jusqu’à confirmation. Indicateur en pastille, erreurs hors flux ; pas de message normal de demande au Master.

Pilotage direct Master (correctif du 07/09) : la confirmation serveur ne conditionne plus le clic sur le QR déjà appliqué localement par l’instance courante. `app_games_hub_player_qr_master_command` conserve droits, présence, éligibilité, révision et queue, mais appelle enqueue sans prérequis de confirmation ; la Remote garde ce prérequis. Une seule commande Master est en vol : les clics suivants modifient immédiatement la cible visible, puis sont regroupés en une commande après le terminal de la précédente, uniquement si `player_qr_command.applied_revision` correspond encore exactement à la révision courante. Ce champ est extrait d’un résultat réussi, sans exposer le JSON brut. L’attente complète reste bornée à 20 s. Un lancement/révision concurrente empêche le report de l’ancienne intention. Un vrai refus `QR_REVISION_STALE` renvoie le snapshot `player_qr`, invalide l’ancienne confirmation locale et demande un nouveau clic explicite, sans retry automatique ; avec un ancien Global sans snapshot, le poll existant rétablit le contrôle. Aucun nouveau poll, timer, endpoint ou DDL.

Le contrôleur partagé utilise seulement les polls existants. Réponses de révision ancienne/instance remplacée ignorées ; erreur, absence Master, remplacement ou expiration 20 s terminent l’attente. Après rétablissement, le Master retrouve les commandes sur un état local applicable de son instance ; la Remote attend sa confirmation courante. Reload/reconnexion/remplacement préservent le choix et refont confirmer son application. Absence/partie illisible du schéma, erreurs SQL ou ancien Global : repli réduit sans réparation automatique, aucune exception QR ne veto un succès de lancement. Le repli ne réécrit pas la préférence persistée.

[Migration et livraison Global → Games](../runbooks/hub-player-qr-migration.md). Sources raw antérieures du contrat QR persistant : **non trouvé** ; nouvelle autorisation utilisateur et preuves code/tests consignées dans [l’audit](../../notes/hub-remote-master-ux-audit-2026-09-07.md#sources-raw-et-preuve-locale). Recette navigateur DEV et PROD non revendiquée.

## Bootstrap organizer Hub
- Le lancement Hub Master vers l'organizer reste une navigation même onglet vers `/master/{runtime_session}?hub_launch=1`; le boot lit `window.AppConfig.hubLaunchAutoStart` et `window.AppConfig.hubOrganizer`. Le contexte Organizer expose `sourceSessionId`, `runtimeSessionId`, `runtimeMode` et `executionId`; en officiel source et runtime sont identiques, en démo le runtime est la copie canonique hors membership Hub.
- Aucun payload bridge ni stockage navigateur ne transporte une intention plein écran Hub Master -> organizer. Les contrôles plein écran restent manuels et locaux au document courant.
- Le lancement depuis Hub Remote ne change pas le bridge Canvas: le téléphone dépose une commande `launch_session`, dont le `command_id` devient la clé de retry de l'intention. Hub Master claim puis appelle le même contrat central que son bouton local; toute nouvelle intention Hub crée un runtime démo distinct et la navigation finale reste `/master/{session}?hub_launch=1`.
- Hub Remote ne lance jamais directement le runtime historique : seul `control_poll.client_routing` autorise la navigation avec présence exacte. `AppConfig.hubRemoteReturn` porte la session source/runtime, l’exécution et la génération. La lecture `runtime_presence` observe ce tuple sans commande métier ; HubTransition retourne au Hub sans verrou returned à expiration. Les callbacks terminaux conservent leur propre contrat.
- Readiness, présence et fin naturelle valident l'Organizer contre le `runtime_session_id` déclaré tout en corrélant focus et exécution à la source officielle. Une fin démo complète l'exécution sans rebuild des stats ni injection de résultats Hub.
- Pour une injection Hub papier, le service central appelle avant le focus l'abstraction interne `canvas_historical_session_ensure_for_game(...)`: parent minimal Quiz/Blind Test assuré puis relu, validation sans write pour Bingo. Ce helper n'est pas une action bridge, ne change aucun payload `player_register` et n'appelle pas le preload complet.

## Auth inter-service (service-only)
- Les appels **front (browser)** ne doivent **pas** envoyer `X-Service-Token` (et ne doivent pas en dépendre).
- Le header `X-Service-Token: <secret>` est requis pour les appels **inter-service** idempotents et pour les actions explicitement service-only. Les writes player Bingo same-origin (`player_register`, `grid_assign`, `grid_cells_sync`) portent aussi un `event_id`, mais restent des appels browser sans secret.
  - Si le token n’est pas configuré côté serveur, réponse **403** `ok=false` (`error.code="misconfigured"`) **uniquement** quand le token est requis.
  - Si le token est absent/invalid, réponse **403** `ok=false` (`error.code="forbidden"`).
  - **Bypass dev temporaire (writes uniquement)** : si (1) environnement dev détecté (`APP_ENV=dev` **ou** `HTTP_HOST` contient `.dev.`) **et** (2) `CANVAS_DEV_ALLOW_UNAUTH_WRITES=1`, alors le bridge accepte les writes même sans `X-Service-Token`.
    - Le bridge ajoute `data.auth_bypassed=true` à la réponse JSON enveloppée quand le bypass est utilisé.
    - Un log warning explicite est émis côté PHP: `[canvas bridge][auth_bypass_used] ...`.
    - Interdit hors dev / si le flag est absent → comportement strict inchangé (403 comme avant).

## Dispatch
- `game_api_dispatch($pdo, $payload)`
- Convention:
  - tente `{$game}_api_{$action}` (ex: `bingo_api_session_update`)
  - sinon `canvas_api_{$action}`
  - sinon erreur “action not supported”

## Payload minimal (Bingo, d’après impl + smoke)
Champs communs:
- `game` (obligatoire): `bingo`
- `action` (obligatoire): ex `session_update`, `bingo:reset`, `bingo:end_game`, `phase_winner`
- `sessionId` (recommandé/attendu): token de session (id_securite)
- identité player (actions player/grid): `player_id` canonique (`p:<uuid>`) est la clé de référence; `playerId` numérique reste toléré en fallback legacy sur certaines actions et est résolu côté bridge.
- `phase_winner` (bingo) est désormais key-first: `player_id` canonique requis, `playerId` numérique optionnel (fallback compat).

Idempotence (writes / service-only):
- Toute action **write** (WS → Canvas) DOIT inclure `event_id` (UUID) ; sinon comportement **NON SUPPORTÉ**.
- Les writes browser player Bingo `player_register`, `grid_assign` et `grid_cells_sync` incluent également un `event_id` stable par tentative logique, sans `X-Service-Token`; leur autorisation reste celle du contexte player same-origin.
- `event_id` = intention d’écriture + idempotence.
- Replay (même `event_id`) → réponse `ok=true` avec `data.already_processed=true`.
  - Les erreurs 403 (`misconfigured` / `forbidden`) concernent les appels pour lesquels l'auth inter-service est requise; la simple présence d'un `event_id` sur les trois writes player Bingo n'impose pas de secret navigateur.
- Implémentation: côté PHP, **toute requête** qui contient `event_id` est traitée comme “write-idempotent” (insert/dedupe en `game_events`), peu importe `game`/`action` → ne jamais envoyer `event_id` sur les reads.
- Exception front “démo” : `resetdemo` est un write **front (organizer)** sans `event_id` (pas d’idempotence `game_events`, pas de `X-Service-Token`).
- Exception front “remote upload podium” : `session_podium_photo_upload` est un write **front (remote)** sans `event_id` ni `X-Service-Token`; l'autorisation repose sur `id_client` + appartenance de session + consentement organisateur present, puis delegue a `app_session_results_podium_photo_upload(...)`.
- Exception front “player upload podium” : `player_podium_photo_upload` est un write **front (player)** sans `event_id` ni `X-Service-Token`; l'autorisation repose sur l'eligibilite runtime revalidee cote serveur (session archivee, joueur courant, podium, consentement present), puis delegue au meme helper partage `app_session_results_podium_photo_upload(...)`.

Action d'expiration de grâce Hub:
- `hub_session_grace_expired` est un write service-only appelé uniquement après expiration définitive de la grâce organizer.
- Payload: `game`, `sessionId`, `event_id`. Raisons métier: `hub_focus_cleared`, `different_focus`, `not_hub_session`, `session_not_found`, `clear_failed`.
- Le clear est atomique et sans effet si `games_hubs.active_session_id` ne correspond plus à la session expirée.

Action de fin naturelle Hub:
- Un lancement explicite Hub écrit d'abord `hub_execution_started` dans `game_events`. Ce marqueur d'incarnation, le focus courant et l'écriture terminale distinguent une exécution Hub d'une ouverture historique d'une session seulement rattachée.
- `hub_session_natural_ended` est un write service-only distinct de la grâce, de `quitGame` et des abandons techniques. Il est appelé par le moteur uniquement après réussite de l'écriture terminale (`session_update` final Quiz/Blind Test, `bingo:end_game` Bingo).
- Payload: `game`, `sessionId`, `event_id`; `X-Service-Token` est obligatoire même indépendamment de la règle générique liée à `event_id`.
- Le bridge exige `hub_execution_started` encore ouvert et `active_session_id = session`, relit les résultats, effectue le clear gardé puis écrit `hub_execution_completed`. Réponse métier: `hub_session`, `hub_execution`, `cleared`, `reason`, `hub_id`, `hub_token`, `session_id`, `current_session_id`, `podium_available`.
- Après preuve de clôture Hub (`hub_execution_completed`, récupération tardive ou replay `already_completed`), le bridge déclenche le rebuild persistant dev des stats joueurs Hub via `app_games_hub_players_stats_rebuild(..., dry_run=false, write=true)`. Les sessions démo sont exclues; les erreurs ou résultats runtime incomplets sont journalisés et marquent les stats dirty/error quand le contrat Global est disponible, sans exposer d'erreur dans la réponse du callback.
- Une course tardive A après activation de B retourne `different_focus` et ne vide pas B. Une session hors Hub retourne `hub_session=false`; les moteurs gardent alors leur écran final historique.
- Les replays sûrs de `hub_session_natural_ended`, `player_register`, `grid_assign` et `grid_cells_sync` redispatchent leurs handlers idempotents afin de restituer le résultat métier, tout en conservant `already_processed=true`. Cela évite qu'une réponse réseau perdue transforme un ACK de replay en payload incomplet.
- Pour Quiz et Blind Test, `player_register` ne déduit jamais une remise à zéro du seul statut `is_active`. `score=0` exige le contexte serveur interne posé par Hub Play pendant `manual_join_session`, après vérification sous verrou que le mapping de cette identité était `left`; jeu, session et `player_id` doivent correspondre. Toute autre réactivation conserve le score. La réponse inclut `score` dans `upsert.changed_fields` seulement si cette opération autorisée a effacé une valeur non nulle.
- Bingo ne transpose pas ce reset aux gains de phase: `bingo_phase_winners` et `phase_wins_count/last_won_*` survivent à `deactivate_player` puis `player_register`, car ils matérialisent un résultat acquis. Ils ne sont purgés que par les actions de reset complet prévues à cet effet.
- Lors d'une injection Hub papier, `player_register` reçoit la clé `p:*` du joueur Hub actif. Si une unique ligne runtime du même jeu et de la même session porte déjà le pseudo exact sous une ancienne clé Remote, un contexte PHP interne — jeu, token session, clé, pseudo, Hub et joueur Hub — autorise le remplacement de cette seule clé. L'ID de ligne, score, grille et gains sont conservés; hors de ce contexte ou avec plusieurs conflits, `USERNAME_ALREADY_USED` reste la réponse.
- Les writes Bingo browser génèrent leur `event_id` côté appelant. Une requête simultanée est coalescée; après erreur réseau, le retry logique réutilise l'ID, puis une nouvelle tentative métier en crée un nouveau.

Normalisation d’action:
- Si `action` est de la forme `bingo:xxx` et `game=bingo`, le bridge normalise vers `action=xxx` avant dispatch.

## Gotchas (à garder en tête)
- **`players_get` runtime actif** : pour Quiz, Blind Test et Bingo, le contrat par défaut retourne les joueurs actifs. `includeInactive=1` doit rester borné aux écrans terminaux, historiques ou de résultats; les réhydratations `canvas_display.js` pendant `En cours` ou `Pause` ne doivent pas l'envoyer, sinon un joueur volontairement sorti (`is_active=0`) peut revenir dans le roster et gonfler `GameStore.totalPlayers`.
- **Upload podium remote** : `session_podium_photo_upload` attend un vrai fichier dans `$_FILES['files_img']`, un `sessionId`, un `rank` (`1..3`), un consentement explicite, et, si disponible, un `photo_row_key` pour cibler proprement un ex aequo. La reponse de succes peut embarquer un `session_meta` deja rafraichi pour rerender l'UI sans second call.
- **Priorite organisateur** : quand la photo visible d'une ligne podium est issue d'un upload organisateur (`games_remote_organizer` / `pro_organizer`), le socle la marque comme prioritaire et le flow player ne doit plus pouvoir l'ecraser.
- **Upload podium player** : `player_podium_photo_upload` attend lui aussi un vrai fichier dans `$_FILES['files_img']`, mais n'accepte l'ecriture que pour le joueur courant si la session est terminee, que le joueur est sur le podium, et que `consent=1` est present. La reponse peut renvoyer un `player_access` rafraichi pour rerender la carte de fin.
- **Remote papier Quiz/Blind Test `update_score`** : la correction de score depuis la remote papier passe par le bridge HTTP avant le WS. Payload attendu: `game=quiz|blindtest`, `action=update_score`, `sessionId`, `sessionPrimaryId`, `player_id` canonique ou `playerId` numerique, `score`, `event_id`, `role=remote`, `remote_action=paper_score_update`, `paperMode=1`. Le succes HTTP est l'ACK fiable apres write DB; le WS `admin_set_score` est seulement un refresh best-effort et peut etre manque si aucun primary organizer n'est connecte.
- **Blind Test equipes runtime** : `blindtest:session_update` peut recevoir `players` / `rankings` / `finalRankings` pour persister `blindtest_session_teams`. Une ligne est persistée comme equipe uniquement si `teamMemberCount`, `team_member_count` ou `members` indique au moins 2 membres; une equipe préparée restée seule doit rester une ligne joueur solo dans les payloads publics.
- **Remote papier Bingo `phase_winner`** : l'attribution gagnante avec joueur depuis la remote papier passe par le bridge HTTP avant le WS. Payload attendu: `game=bingo`, `action=phase_winner`, `sessionId`, `player_id` canonique ou `playerId` numerique, `phase`, `event_id`, `role=remote`, `remote_action=paper_phase_winner`, `paperMode=1`. Le WS `admin_phase_winner` porte ensuite `persisted=true`, `wonPhase`, `nextPhase` et `requiresResync=true` pour rafraichir les sockets connectees sans repersister. `PHASE_MISMATCH`, `GAME_ALREADY_ENDED` et `phase_winner_conflict` sont des conflits métier HTTP 409, pas des erreurs serveur 500. Le fallback de saisie de lignes convertit les numéros humains 1-based en index `grid_lines` 0-based avant la requête.
- **Terminal papier commun** : `awaiting_score_validation` reste non terminal. Pour Quiz/Blind Test, `paper_finalize_end` est une commande WS avec `event_id`; le serveur persiste le `session_update` final avant tout `hub_session_natural_ended`. Pour Bingo, `phase_winner(nextPhase=-1)` déjà acquitté précède `bingo:end_game` avec un ID stable. `hub_session_natural_ended` n'est appelé qu'après le write terminal; le WS n'est jamais l'unique preuve de succès.
- **Erreur terminale papier** : si `session_update` final ou `bingo:end_game` échoue, aucun appel Hub n'est effectué et `paper_score_finalization_state` ramène les organisateurs à `awaiting_score_validation`. Le payload WS est une notification d'UI, pas une preuve DB.
- **Retry completion Hub** : si `hub_session_natural_ended` a déjà vidé le focus mais échoue sur `hub_execution_completed`, un replay retrouve la session terminée et l'exécution encore ouverte, écrit la preuve idempotente puis renvoie `hub_execution=true`; aucune socket Master n'est requise.
- **Formats courts musicaux** : `championnats_sessions.id_format=5` est interprete par jeu sans migration DB. Blind Test limite le preload a 20 titres via ordre deterministe `id_session|id_morceau`; Bingo lit le format 5 comme une grille 3x3 dans `grid_lines`, `grid_assign` et les mappings WS. Les reponses Bingo `grid_assign` / `grid_hydrate` doivent porter `gridFormat`, `gridCols`, `gridRows` et `gridCellCount` afin que le player rende le layout depuis le format, pas depuis la seule longueur de `numbers`.
- **Trace suppression** : le write path player snapshotte aussi le pseudo/libelle runtime visible lors de l'upload, afin de retrouver plus vite photo + session + joueur si une demande d'effacement arrive ensuite.
- **Eligibilite player** : `player_podium_photo_access_get` est un read bridge front destine a l'ecran `Partie terminee`; il retourne l'etat d'eligibilite, la meta podium ciblee et le texte de consentement a afficher. En cas d'ineligibilite, l'UI doit masquer le CTA et le write path doit de toute facon refuser ensuite cote serveur.
- **Diagnostic catalogue YouTube** : `youtube_catalog_diagnostics_get` est un read front utilise par le test pre-lancement organizer. Il recoit une liste compacte `{id,url}` de supports YouTube detectes, extrait les `videoId`, relit `content_links_check_results` et renvoie le dernier diagnostic connu par support. Il ne lance aucun appel YouTube Data API et ne fait aucun write.
- **prizes_save partiel** : `prizes_save` accepte des payloads partiels. Une cle de lot absente preserve la colonne `lot_*` correspondante; depuis le 2026-05-05, `mainTitle` absent preserve aussi `championnats_sessions.diffusion_message`.
- **Bingo identité canonique** : ne pas confondre `player_id` (string stable `p:<uuid>`) et `playerId` (id DB numérique legacy). Les actions player/grid doivent privilégier `player_id`.
- **Bingo demoParticipant** : `demoParticipant` est un flag WS-only sur `auth_player`, pas un champ du Canvas bridge. Depuis le 2026-05-04, il n'exclut pas le socket demo desktop du quota WS: `Joueur démo` compte dans `maxPlayers`.
- **Switch format demo** : depuis le 2026-06-22, `session_meta_get` ne verrouille plus une session demo par principe. `format_locked` depend de l'etat runtime comme pour une officielle: phase attente autorisee, session demarree verrouillee. Les actions `quiz|blindtest|bingo:session_update` peuvent donc persister `paperMode` sur une demo non lancee, mais doivent toujours renvoyer `FORMAT_SWITCH_LOCKED` si la session est deja demarree.
- **Organizer iframe postMessage** : `gm-player-ready` est un message browser parent/iframe, pas une action bridge. Depuis le 2026-05-05, le parent organizer doit le refuser si l'origine, l'iframe source, la session, le jeu ou la grille Bingo attendue ne correspondent pas au contexte courant.
- **Validation payload player-scoped** : côté WS wrappers, `player_id` doit être canonique et `playerId` doit rester strictement numérique (jamais `p:<uuid>`).
- **403 sur un appel inter-service idempotent/service-only** : vérifier le token et sa configuration. Les trois writes player Bingo same-origin constituent l'exception documentée: ils portent un `event_id` sans exposer de secret au navigateur. Si un read reçoit un 403, vérifier qu'un client/proxy ne le transforme pas en write authentifié.
- **Différencier `misconfigured` vs `forbidden`** :
  - `error.code="misconfigured"` : le serveur PHP n’a pas `CANVAS_SERVICE_TOKEN` (ex: env manquante / secret non chargé) alors qu’un write le requiert.
  - `error.code="forbidden"` : header `X-Service-Token` absent ou ne matche pas `CANVAS_SERVICE_TOKEN` côté serveur.
- **Symptôme “writes WS bloqués”** : si les writes Canvas idempotents (ex: `bingo.session_update`, `bingo.reset`, `bingo.end_game`) renvoient 403, les effets DB associés ne se produisent pas → logique aval “bloquée” (ex: progression liée à `session_update` comme le compteur renvoyé `numPassedSongs` sur certains chemins).

## Format de réponse (réel)
```json
{
  "ok": true,
  "data": {
    "idempotent": true,
    "already_processed": false,
    "event_id": "00000000-0000-0000-0000-000000000001"
  },
  "error": null,
  "ts": 1700000000000
}
```
### Bingo reset versionné — 11/09/2026 (local)

Les accès Canvas Bingo concernés passent sous un verrou par playlist. `resetdemo`/`reset` ne passent plus par le marqueur pré-dispatch : un journal `game_events` pending/completed publie `bingo_reset_generation` seulement après succès vérifié. `event_id` doit être réutilisé après erreur partielle. `grid_cells_sync` et writes de phase/progression vérifient la génération avant mutation/replay ; champ absent permis seulement avant le premier reset, sinon `BINGO_RESET_STALE` HTTP409. Même grille retournée aux propriétaires ; nouveaux joueurs attribués normalement. `reset_state` expose génération, phase, playlist et `reset_pending` pour le WS ; pending bloque le gameplay, tout en permettant l’auth Master de récupération et le retry corrélé du reset. Le lancement attend `reset_ack` avant sa première commande ; preload reste accessible pendant pending pour la récupération. Aucune migration ni dépendance Hub nouvelle. [Contrat détaillé](../../notes/bingo-reset-generation-patch-2026-09-11.md).

<!-- AUTO-UPDATE:END id="bridge-contract" -->

<!-- AUTO-UPDATE:BEGIN id="bridge-examples" owner="codex" -->
## Examples (auto)
### Bingo `reset` (write, idempotent)

Request (form-urlencoded):
```bash
	curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H "X-Service-Token: ${CANVAS_SERVICE_TOKEN}" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=bingo&action=bingo:reset&sessionId=SESSION_TOKEN&target_phase=1&event_id=00000000-0000-0000-0000-000000000010'
```

Response (1er appel):
```json
{ "ok": true, "data": { "idempotent": true, "already_processed": false, "event_id": "00000000-0000-0000-0000-000000000010" }, "error": null, "ts": 1700000000000 }
```

Response (replay, same `event_id`):
```json
{ "ok": true, "data": { "idempotent": true, "already_processed": true, "event_id": "00000000-0000-0000-0000-000000000010" }, "error": null, "ts": 1700000000000 }
```

### Quiz papier `update_score` depuis remote

Request (form-urlencoded, front remote):
```bash
curl -i -X POST 'https://games.dev.cotton-quiz.com/games_ajax.php?t=jeux&m=canvas' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data 'game=quiz&action=update_score&sessionId=SESSION_TOKEN&sessionPrimaryId=123&player_id=p:00000000-0000-4000-8000-000000000001&score=30&event_id=remote-evt-1&role=remote&remote_action=paper_score_update&paperMode=1'
```

Response:
```json
{ "ok": true, "data": { "idempotent": true, "already_processed": false, "event_id": "remote-evt-1", "changed": true, "currentScore": 30, "requiresResync": true }, "error": null, "ts": 1700000000000 }
```
<!-- AUTO-UPDATE:END id="bridge-examples" -->
