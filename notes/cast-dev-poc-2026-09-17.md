# POC expérimental Cast DEV — non disponible en production

> **Statut au 22/09/2026 : branche `cast`, EN COURS — NON DÉPLOYÉ EN PROD.** Ce lot est exclu du déploiement `hub_soiree` confirmé par l’opérateur. La promotion documentaire vers `main` ne change pas ce statut. [État de livraison](../canon/deployment-status.md).


Implémentation locale du 17/09/2026, **aucun déploiement, même DEV**. Aucun accès SSH/PROD, aucune requête DB, migration, partie officielle ou Remote créée. Le résultat des tests simulés ne démontre pas la compatibilité d'un appareil réel.

## A. Préconditions AI Studio et preuves

Parcours documentaire consulté : [START RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), [SITEMAP RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md), [TXT](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), [NDJSON](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.ndjson), [README RAW — règles générales](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), [Manifest RAW — Update triggers / Routing rules](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), [HANDOFF RAW — actions réalisées](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md).

[Journal AI Studio public](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb) consulté avant modification, puis relu après implémentation : Markdown embarqué dans `const raw`, 471 lignes. Sections « EN COURS », « Fait, livré en PROD / Septembre 2026 », « Mai 2026 » : travaux WWW/AI Studio et référence à `global/global_librairies.php`. Référence précise à une modification externe de `ec_start_sessions_day_dashboard_view.php`, `player/index.js`, `canvas_display.js` ou à un receiver Cast : **non trouvé**. Global non modifié, ni chargé par les nouveaux endpoints. Aucun accès serveur permettant de certifier une égalité local/DEV/PROD.

[README Pro RAW — Dashboard mobile : choix explicite du Master individuel](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md) : contrat historique à conserver. Contrat préexistant pour ce POC Cast : **non trouvé** ; cette note décrit du code local neuf, pas une fonctionnalité déployée.

Preuves locales : garde DEV existant en tête de `pro/web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`, importmap dans `games/web/organizer_canvas.php`, helpers exportés dans `games/web/includes/canvas/core/player/index.js`, loader réel `core/yt_loader.js`. Les nouveaux endpoints reprennent `$conf['server'] === 'dev'` après lecture du seul `web/config.php`, sans bootstrap métier.

## B. Architecture

Dashboard Pro mobile → module sender → sélecteur Google Cast → Custom Web Receiver Games DEV → vrai module player Cotton → A → B avec pause/reprise → accueil local persistant → C → verdict mobile.

Transport JSON dédié `urn:x-cast:com.cotton.dev.poc`. INIT version 1, UUID de test indépendant de toute session métier, séquence croissante. Un sender et un run par durée de vie du receiver ; INIT répété du même sender rejoue le dernier état. Les runs concurrents/anciens sont ignorés. Pour recommencer : « Arrêter le test Cast », puis lancer une nouvelle connexion. Le receiver ne navigue jamais et ne détruit ni CAF ni le player pendant A/B/C.

## C. Fichiers modifiés/créés

Pro : une ligne ajoutée à `web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php`. Nouveaux `tools/cast-dev/{config.example.php,dashboard.php,guard.php,sender-state.mjs,sender.mjs,sender.test.mjs}` et `web/cast/dev/asset.php`.

Games : nouveaux `tools/cast-dev/{config.example.php,guard.php,guard.test.mjs,no-business-api.mjs,receiver.mjs,receiver.test.mjs,sequence.mjs,sequence.test.mjs}` et `web/cast/dev/{asset.php,receiver.php}`. **Aucun fichier du player partagé modifié.**

Documentation : cette note, README/TASKS canoniques Pro et Games, manifest, HANDOFF, CHANGELOG et index/sitemaps générés.

## D. Guard DEV

Comparaison stricte avec `dev`, sans nouvelle déduction par hostname. Include Dashboard conditionnel côté PHP ; garde répété dans le fragment. Endpoint direct : 404 vide si `prod`, `local`, environnement absent ou `DEV` en majuscules. Config runtime absente : refus. Assets : whitelist fermée, aucun chemin fourni par le client n'est ouvert. Réponses endpoints `no-store` et `nosniff`.

Sources spécifiques hors de `web/`, desservies uniquement par `asset.php`. Conserver le document root habituel sur `web/` : ne pas publier le répertoire `tools/`. Les modules player partagés restent ceux de Games, déjà publics ; aucun POC ne s'y ajoute. La protection suppose que le flag canonique décrit correctement l'environnement.

## E. Sender

Sous992px : CTA sticky haut « Diffuser sur une TV », badge Expérimental, caché initialement. Affichage seulement après callback SDK disponible, CastContext initialisé et état de découverte connu avec appareil. SDK absent/bloqué/incompatible : pas de CTA ; ID vide/invalide : log DEV explicite, pas de module ni CTA. Sur desktop, aucun SDK injecté.

Include hors des cartes et de `.event-dashboard__header-actions`, donc hors des remplacements ciblés du refresh. Aucun handler/lien/formulaire historique modifié. Le bouton ouvre le sélecteur dans le geste utilisateur. Annulation restaure AVAILABLE. Bouton d'arrêt séparé ; logs consultables/exportables après verdict.

États sender : UNAVAILABLE, AVAILABLE, SELECTING, CONNECTING. États receiver : RECEIVER_READY, PLAYER_READY, AUTO_TESTING, AUDIO_WAITING, ACTIVATING, PLAYING_A/B/C, SUCCESS, FAILED. Les messages d'un autre run, les séquences répétées/anciennes, les états inconnus et les messages postérieurs au verdict terminal sont rejetés.

## F. Receiver

URL prévue après installation manuelle : `https://games.dev.cotton-quiz.com/cast/dev/receiver.php` (pas de rewrite ajouté). Page HTTPS dédiée, zone vidéo 16:9, diagnostics français, script CAF puis module receiver. Aucun login Pro nécessaire sur ce document ; la TV doit pouvoir le télécharger sans cookie utilisateur ni challenge interactif.

INIT réémis toutes les1,5s jusqu'au premier état accepté. Absence de message receiver pendant30s : FAILED_RECEIVER_TIMEOUT côté sender. Préparation player :20s ; démarrage/progression :12s ; activation locale :45s ; pause/stop :4s. La durée d'extrait est bornée à5–60s, avec délai supplémentaire de12s pour la progression. Les heartbeats diagnostiques CAF toutes les2s ne sont pas des pings Master.

Capabilities collectées après READY : DISPLAY_SUPPORTED, CAST_LITE_ONLY, IS_GROUP, DPAD_INPUT_SUPPORTED ; modèle/OS/autres informations disponibles, viewport et DPR. Valeur manquante = unknown. Groupe/audio-only/sans display déclaré : FAILED_DEVICE_CAPABILITIES. DPAD ne vaut jamais preuve d'une activation utilisable. [Référence Google — system / DeviceCapabilities](https://developers.google.com/cast/docs/reference/web_receiver/cast.framework.system).

## G. Réutilisation du player Cotton

Importmap vers les vrais `player/index.js`, `yt_loader.js`, store, bus, timer, display et score. `prepareMainPlayer()`, `cueSupport()`, `loadAndPlaySupport(...,{unmute:true})`, `stopSupport()` sont réellement appelés. L'instance fournie par Cotton, `window.__canvasYT`, sert aux mesures, au seek et à pause/reprise.

Activation : appel synchrone `unMute/setVolume/playVideo` sur cette même instance depuis le handler original. `primeYTForGesture()` n'est pas appelé : son mute, son await et sa pause programmée à50ms brouilleraient cette mesure d'activation unmuted. Aucun second player YouTube, aucun boot organisateur/Hub, aucune stratégie de jeu initialisée.

L'import `api_client` du module display est remplacé **uniquement dans l'importmap de ce document** par `no-business-api.mjs`, qui lève une erreur pour tout appel métier. Le véritable lecteur et son loader ne sont pas remplacés. Aucun fetch applicatif, WS métier, résolution Hub, focus, token Remote ou écriture officielle.

## H. Médias configurables

Deux fichiers **à créer manuellement uniquement en DEV**, déjà couverts par le gitignore :

- Pro : copier `tools/cast-dev/config.example.php` vers `web/config.cast-dev.php` ; renseigner `CAST_DEV_APPLICATION_ID` avec l'ID réel, huit caractères hexadécimaux.
- Games : même copie depuis son propre template ; renseigner `CAST_TEST_VIDEO_A`, `CAST_TEST_VIDEO_B`, `CAST_TEST_VIDEO_C`, chacun `{id, offset, duration}` en tableau PHP. Trois IDs YouTube distincts de11 caractères ; offset numérique positif ou nul, durée5–60s.

Choisir trois médias embeddables représentatifs de Quiz, Blindtest et Bingo ; vérifier qu'ils dépassent offset + durée et sont audibles. Aucun ID artificiel committé dans la configuration, aucune lecture de catalogue DB. Les IDs des tests automatiques sont exclusivement des fixtures. Configuration incorrecte : FAILED_MEDIA_CONFIG avant création du player.

## I. Instrumentation et critères

Logs mobiles horodatés : nom/appareil Cast sélectionné, capabilities, informations receiver, état, événement TV, compteur d'événements et compteur d'activations, vidéo, temps, mute, volume, erreurs. Export JSON des1500 dernières entrées, sans stockage serveur. Échantillonnage player toutes les250ms durant les vérifications.

DOM capturé : keydown, keyup, click, key/code, repeat, isTrusted, userActivation si disponible. Activation sur Enter/Select/espace au keydown de confiance ou click de confiance ; keyup journalisé sans réactiver. CAF PLAY intercepté, senderId/requestId tracés quand disponibles. Les répétitions n'activent pas une seconde fois. CAF LOAD ne lance aucun média officiel. Un CAF PLAY ne prouve pas à lui seul un geste DOM local : source à interpréter lors de la recette. Les événements internes à l'iframe YouTube peuvent être invisibles au document parent.

A : ID correct + PLAYING + temps progressif + non mute + volume positif ; sinon attente d'une seule activation. Seek explicite vérifié avec tolérance1,5s, nouvelle progression, stop à offset + durée (précision du polling, environ250ms hors ralentissement). B : mêmes vérifications, pause observée avec stabilité du temps pendant1s, reprise automatique observée. C : accueil1,5s par overlay sans navigation/destruction, puis mêmes vérifications automatiques.

B/C ou reprise B bloqués : FAILED_SECOND_GESTURE_REQUIRED, sans retenter par un geste. Ce code est un critère d'échec conservateur : une lenteur réseau peut aussi produire ce résultat, il faut examiner les logs. Les erreurs explicites YouTube restent FAILED_YOUTUBE_<code>. [Référence YouTube — Events / onAutoplayBlocked / onError](https://developers.google.com/youtube/iframe_api_reference).

SUCCESS affiche « Diffusion Cotton compatible », la lecture de plusieurs extraits sans nouvelle interaction, puis « READY — la redirection Remote serait déclenchée ici. » **Aucune redirection.** Les mesures prouvent un état logiciel de lecture non muette, jamais le son physique du téléviseur : confirmation à l'oreille indispensable.

## J. Tests automatiques

Exécutés sous Node18.20.4 et PHP8.3.25 : **30 tests POC réussis**, **59 contrôles de routage historique réussis**. Lint PHP/JS et diff-check réussis. Tests de guard avec configurations inertes en répertoires temporaires ; aucun chargement de config réelle dans ces tests, aucune DB.

```bash
cd /home/romain/Cotton/documentation
node --experimental-vm-modules --test ../pro/tools/cast-dev/*.test.mjs ../games/tools/cast-dev/*.test.mjs
php ../pro/web/ec/modules/tunnel/start/ec_start_dashboard_mobile_routing_test.php
npm run docs:sitemap
```

Couverture : SDK absent/présent, desktop/mobile, appareils disponibles/absents, annulation sélecteur, receiver ready, messages anciens/étrangers, timeout receiver/player/activation, autoplay immédiat/bloqué, activation unique malgré keyup/click/CAF répétés, vidéo erronée, mute/volume nul/temps figé, seek/pause ignorés, blocage B/reprise/C, erreur YouTube, configuration invalide et succès.

Le test receiver exécute le **graphe réel des modules Cotton**, avec CAF/YouTube/DOM/horloge simulés : une seule construction YT observée, A/B/C et transition accueil exécutés. Il ne remplace pas la recette Chrome Android + Chromecast/Google TV, ni une validation visuelle du sticky avec le CSS complet Pro.

## K. Configuration Google Cast manuelle

Après livraison DEV par l'opérateur, vérifier que le receiver et ses assets répondent sur l'URL prévue et que le flag canonique vaut réellement `dev`. Conserver les sources `tools/cast-dev` à leur place hors document root ; les livraisons qui n'envoient que `web/` doivent aussi inclure ces modules et helpers.

Dans [Google Cast SDK Developer Console](https://cast.google.com/publish/), ajouter une application **Custom Receiver**, nom « Cotton DEV expérimental », URL `https://games.dev.cotton-quiz.com/cast/dev/receiver.php`. Laisser audio-only et relay casting désactivés pour cette recette. Enregistrer sans publier ; relever l'Application ID et le renseigner côté Pro (§H). Si la console demande le sender Web : `https://pro.dev.cotton-quiz.com`.

Enregistrer chaque appareil de test par son numéro de série Cast (Android/Google TV : numéro logiciel Cast). Attendre le statut Ready for Testing, environ15min, puis redémarrer l'appareil. [Google — Registration / Applications / Devices](https://developers.google.com/cast/docs/registration).

Téléphone et TV sur le même réseau avec découverte locale possible. Pro et Games en HTTPS avec certificat reconnu, accès Google CAF/YouTube autorisé. Conserver l'origine Games réelle du document pour l'iframe YouTube ; ne pas ouvrir une copie locale/file://. La TV ne peut pas utiliser localhost du poste de développement. Aucun déploiement ou enregistrement Google n'a été effectué ici. [Google — Setup Web Sender](https://developers.google.com/cast/docs/web_sender).

## L. Recette physique

1. Ouvrir un Dashboard authentifié sur `https://pro.dev.cotton-quiz.com` dans Chrome Android, largeur CSS sous992px.
2. Vérifier que le CTA Expérimental apparaît après détection Cast ; les cartes historiques restent utilisables. Tester une annulation du sélecteur.
3. Cliquer Diffuser, choisir l'appareil enregistré, observer RECEIVER_READY puis PLAYER_READY sur le téléphone.
4. Laisser A tenter son autoplay. Si demandé, appuyer **une seule fois** sur OK de la télécommande TV.
5. Vérifier A audible ; ensuite **ne plus toucher à la TV ni aux commandes média du téléphone**.
6. Vérifier B audible, sa pause d'une seconde puis sa reprise **automatiques**.
7. Observer l'accueil intermédiaire puis C audible.
8. Lire SUCCESS/READY ou FAILED sur le téléphone. Aucune Remote ne doit s'ouvrir.
9. Exporter le diagnostic, même en succès ; noter appareil/modèle, version Chrome, son réellement entendu A/B/C, éventuel appui OK et heure approximative.
10. « Arrêter le test Cast » avant une nouvelle tentative ; garder le téléphone au premier plan pendant la mesure. Vérifier ensuite un CTA historique.

En cas d'échec : renvoyer `cotton-cast-dev.json`, modèle TV/Chromecast, état visible TV, A/B/C réellement audibles ou non, nombre d'appuis physiques, timing de l'appui, erreur affichée. Si aucun CTA : vérifier ID, réseau et disponibilité SDK côté téléphone ; les erreurs de SDK ne sont consignées qu'en console DEV puisque le panneau doit rester invisible.

## M. Limites

Compatibilité du Web Receiver avec iframe YouTube, autoplay sonore, événements télécommande réels, importmaps/ES modules et firmwares : **non validée physiquement**. Les capabilities ne garantissent rien sur l'activation. Aucune équivalence avec un Hub complet ni preuve de compatibilité du runtime entier des trois jeux : on teste les helpers du vrai player, isolés de leur orchestration métier.

Pas de récupération d'une page mobile rechargée au milieu d'un run : arrêter le Cast et recommencer. Un seul essai par receiver, aucun historique serveur. Téléphone en arrière-plan/réseau coupé peut donner un timeout prudent. Le receiver reste persistant jusqu'à l'arrêt manuel ; le verdict ne lance rien d'autre. Aucun contrôle physique du volume système TV. Déploiement manuel, disponibilité HTTPS, configuration Google et choix de médias encore à réaliser.

## N. Rollback

Désactivation immédiate du sender DEV : vider CAST_DEV_APPLICATION_ID. Pour couper également l'URL receiver, retirer du serveur DEV les nouveaux endpoints `web/cast/dev/` Games/Pro. Retour complet : retirer la seule ligne d'include du Dashboard et les répertoires nouveaux `tools/cast-dev/` et `web/cast/dev/` des deux repos, plus leurs configs locales si créées par l'opérateur. Ne retirer aucun fichier player partagé. Aucun rollback de données, schéma, session ou Remote. Conserver le rapport documentaire comme trace si le POC est abandonné.
