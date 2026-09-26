<!-- AUTO-UPDATE:BEGIN id="remote-takeover-exit-20260918" owner="codex" -->
# Remote session remplacée : sortie du pilotage — 18/09/2026

Le correctif takeover/rattachement tardif précédent est **validé en DEV par l’utilisateur**. Cette passe traite uniquement la sortie de l’ancienne Remote sur takeover, y compris son interruption indue d’une démo Hub. Nouveau correctif local, recette DEV restante.

## A. Historique retrouvé et préflight

Sources publiques relues avant modification :

- [START RAW main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), « Statut actuel » et « Règle preuve d’abord » : develop pour les travaux, preuves explicites.
- [SITEMAP RAW develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), entrées Games et interfaces ; README, SITEMAP.md et HANDOFF également consultés.
- [Manifest RAW develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers (mapping) » et « Routing rules » : README/TASKS, HANDOFF, CHANGELOG pour changement visible, génération sitemap/index.
- Journal public AI Studio demandé, Markdown décodé depuis `const raw` : aucun fichier ciblé Games signalé comme modifié hors workspace. Mentions WWW/e-commerce sans chevauchement ; aucun reload requis identifié. Copies de préflight dans `/tmp/remote-takeover-exit/`.

Destination historique exacte du takeover : **non trouvé dans la documentation publique consultée** ; retrouvée dans Git local Games :

| État Git | Comportement Remote session |
| --- | --- |
| `871b14d` (22/01/2026), `remote-ui.js`, `showRemoteForcedDisconnect` | Alerte warning « Déconnexion », message par défaut « Une autre télécommande a pris la main sur cette session. », CTA « Fermer », puis `tryCloseTab()`. |
| Parent de `4dc215a` (avant31/07) | `tryCloseTab()` tente `window.close()`, retente avec `window.open('', '_self')` après50ms, puis `location.replace('about:blank')` après120ms si le document reste visible. Sortie du pilotage, aucune destination Hub. |
| `4dc215a` (31/07/2026) | Ajoute en tête du helper partagé le retour Hub quand `hubRemoteReturn.enabled` ; la branche forcedDisconnect utilise déjà ce helper et hérite donc du retour. |
| `9c47a21` (24/08/2026) | Remplace explicitement `tryCloseTab()` par `returnToHubRemoteAfterNotice(..., 'forced_disconnect')`, également pour erreurs et fin de session ; revoit le quit volontaire via Organizer. |
| `cbf249b` (24/08/2026) | Ajoute le fallback Pro/WWW pour fin de session non-Hub. Ce n’est pas la destination historique du takeover ; elle n’est donc pas retenue ici. |

Preuves reproductibles : `git show 4dc215a^:web/includes/canvas/remote/remote-ui.js`, `git show 4dc215a -- web/includes/canvas/remote/remote-ui.js`, `git show 9c47a21 -- web/includes/canvas/remote/remote-ui.js`. Les messages de commit génériques `hub_soiree` ne documentent pas l’intention précise de l’auteur.

## B. Régression et sémantique

Le diff montre une intégration du retour Hub dans un helper commun de sortie, puis dans les notices. L’extension au takeover est trop large ; l’hypothèse d’une intention limitée au seul quit n’est pas démontrée par ces commits. Le Hub fait correctement son auto-routing dès que A y revient.

En démo, la redirection UI n’est pas le seul problème : `remote/forcedDisconnect` appelle aussi `HubDemoLifecycle.interrupt()`, qui POSTe `demo_lifecycle/close`, pose le marqueur de clôture puis retourne au Hub. La clôture concerne l’exécution partagée : le Master et B la constatent ensuite. Le complément utilisateur confirme ce symptôme.

| Signal actuel | Branche et politique après patch |
| --- | --- |
| `forcedDisconnect`, `replacement_reason=takeover` | Retrait du lifecycle local démo de A, retrait transport/reconnexion déjà existant, alerte, fermeture/repli about:blank. B reste propriétaire ; pas de close de démo émis par A. |
| `same_continuity_reconnect`, `stale_socket_replaced` | Retrait silencieux existant ; aucune alerte ni sortie historique. |
| `forcedDisconnect` sans motif ou motif inconnu | Comportement précédent conservé ; pas d’inférence takeover. Cet événement est aussi utilisé lors du remplacement d’un organisateur (Quiz/BT `replacePrimarySocket`, Bingo auth organisateur). |
| Quit volontaire | Demande `RemoteAPI.requestQuit` via Organizer ; terminal accepté et retour Hub existants. Aucune branche takeover. |
| Suspension volontaire officielle | Intent `hub_suspend`, ACK `HUB_SESSION_SUSPENDED` correspondant, retrait transport puis retour Hub existant. |
| Fin naturelle/terminal | Chemins `endGame`/`SESSION_ENDED`, présentation finale et retour Hub selon le contrat courant ; aucun changement. |

Les trois serveurs fournissent déjà le motif structuré du remplacement Remote. Aucun payload moteur à modifier.

## C. Correctif minimal

`remote-ws.js` ajoute uniquement `takeover` aux motifs appelant le `retire()` existant du lifecycle démo, **avant** retrait du transport et émission UI. Ainsi les handlers secondaires close/offline/pagehide et une réponse heartbeat tardive ne clôturent pas la démo et ne naviguent pas au Hub. Aucun nouveau flag persistant ou one-shot ; la session partagée reste pilotée par B et le Master. Le code de `hub_demo_lifecycle.js` ne change pas.

`remote-ui.js` transmet `replacement_reason` à `showRemoteForcedDisconnect`. Seul `takeover` appelle, après l’alerte, `tryCloseTab()` puis `location.replace('about:blank')` après120ms. La destination historique est restaurée avec le helper de fermeture actuel ; la seconde tentative ancienne `window.open` n’est pas réintroduite. Le repli ne dépend pas de la visibilité, afin que A quitte aussi le document de pilotage si elle passe en arrière-plan. Wording et CTA « Fermer » restent identiques.

## D. Fichiers modifiés et livraison

**Code Games seulement :**

- `web/includes/canvas/remote/remote-ui.js` — branche de sortie explicite.
- `web/includes/canvas/remote/remote-ws.js` — retrait du lifecycle local sur takeover.
- `web/tests/hub_remote_continuity_test.mjs` — transport/UI réels, démo, quit et suspension.

Seuls les **deux fichiers JS applicatifs** sont nécessaires à la livraison de cette passe, ensemble et en conservant les patches précédents. Aucun marker/restart WS requis.

**Documentation :** `HANDOFF.md`, `CHANGELOG.md`, `canon/repos/{games,quiz,blindtest}/{README,TASKS}.md` (contrat commun et validation précédente confirmée), `canon/interfaces/{actions,canvas-bridge}.md`, statut de `notes/remote-bootstrap-regressions-2026-09-18.md`, présente note et index générés. Aucun code Quiz/Blind Test/Bingo/Global modifié.

## E. Tests

Reproduction sur le code applicatif initial vérifié par SHA-256, avec fixtures corrigées : **9 échecs fonctionnels/30 tests**, soit6 cas UI (trois moteurs, avec/sans Swal) et3 cas lifecycle démo. Les échecs concernent le retour Hub au lieu de la fermeture et le close partagé. Résultat conservé dans `/tmp/remote-takeover-exit/before.tap`. Six contrôles de quit volontaire/suspension ont ensuite été ajoutés.

Après correction : **Games74/74**, **Quiz24/24**, **Blind Test24/24**, **Bingo10/10**. Les tests moteurs exécutent leurs vraies registrations/handlers : B seule propriétaire, commandes/quit tardifs de A refusés. Les tests Games exécutent vrai transport, handlers et fonctions d’alerte/sortie ; le vrai lifecycle démo subit close, offline, pagehide, pageshow et heartbeat tardif sans clôture partagée pour takeover. Quit volontaire déclenché depuis la fonction UI, retour sur ACK suspension ou terminal accepté ; auto-routing tardif couvert par la suite de polling Hub existante. Aucun service réel ni navigateur utilisé.

```sh
# Games
node --test web/tests/hub_remote_continuity_test.mjs web/tests/hub_remote_automatic_return_test.mjs web/tests/hub_remote_polling_test.mjs web/tests/hub_remote_presence_test.mjs web/tests/hub_demo_lifecycle_test.mjs web/tests/hub_suspend_test.mjs
# Quiz, puis Blind Test
node --test tests/remote-continuity.test.cjs
# Bingo
node --test ws/tests/remote_continuity.test.js
# Documentation
npm run docs:sitemap
```

Syntaxes des deux JS et `git diff --check` vérifiés. Les suites démo génériques conservent aussi leur clôture volontaire. La recette réelle doit confirmer : après takeover en démo, A sort, B commande toujours et Master reste dans la session ; puis quit volontaire normal, continuité et ouverture tardive.

## F. Non-régressions et limites

Auto-routing Hub Remote, quit volontaire, ownership, présence/génération Master strictement inchangés cette passe, par comparaison aux empreintes initiales. Aucun changement Global ni serveur moteur ; aucun changement de contrat de reprise, TTL ou droits. Aucun mécanisme ne bloque une réouverture manuelle ultérieure d’une Remote : l’objectif est d’éviter le retour/rattachement automatique de A dans le flux de l’alerte.

Les navigateurs peuvent refuser `window.close()` : le repli about:blank fait donc partie du comportement attendu. Le retrait du lifecycle local sur takeover corrige volontairement l’interruption indue de la démo partagée ; il ne touche pas au quit volontaire ni à la vraie interruption d’une surface encore courante.

## G. Documentation

TASKS actualisés dans les tâches existantes ; README et contrats distinguent explicitement **quit volontaire Remote ≠ takeover Remote**. Sur takeover, l’ancienne Remote session quitte le parcours de pilotage et ne revient pas au Hub Remote. Validation DEV antérieure enregistrée d’après déclaration utilisateur ; cette nouvelle correction ne bénéficie pas encore d’une recette DEV. Blocs AUTO-UPDATE et IDs conservés ; sitemap/index régénérés, jamais édités à la main.

## H. Déploiement et rollback

Aucun déploiement, restart, SSH, accès DB réel, navigateur intégré ou accès applicatif DEV/PROD. Consultation HTTP limitée aux documents publics demandés. Rollback : retirer uniquement ce diff des deux JS Games, en conservant les correctifs antérieurs ; aucun reset global des dépôts ni restauration de données. Ce rollback réintroduirait le retour automatique de A et l’interruption démo sur takeover.
<!-- AUTO-UPDATE:END id="remote-takeover-exit-20260918" -->
