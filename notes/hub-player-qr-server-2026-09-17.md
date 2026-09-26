# QR joueurs Hub Master serveur — 17/09/2026

<!-- AUTO-UPDATE:BEGIN id="hub-player-qr-server-validation" owner="codex" -->

Correctif local, non déployé. Objectif : rendre le QR joueurs initial indépendant de la compatibilité JavaScript de la Smart TV. Deux fichiers applicatifs Games : `web/modules/app_hub_view_helpers.php`, `web/includes/canvas/core/hub_player_qr.js`. Tests ajoutés `hub_player_qr_server_test.php`, `hub_player_qr_image_test.mjs` ; tests adaptés `hub_player_qr_test.mjs`, `hub_remote_contract_test.php`.

## Précondition et preuves

Journal AI Studio public relu avant modification : entrée04/05/2026 « Amélioration Hub Leads […] & Fix Tags Tracking Brevo », chemin `global/global_librairies.php`. La section HANDOFF « Actions réalisées — 2026-09-09 — Patches PROD appliqués sur Hub » et `notes/hub-prod-code-migration-2026-09-09.md` documentent la réconciliation (statut SERVER_RECONCILIATION CLEARED). L’artefact local non publié `tmp/hub-prod-code-2026-09-09/reconciliation/application-verification.json` porte le hash final `997779e7e19de58825ac6b270e9ce00d6af129f139781c435d012bf38aa7d778`, identique au fichier Global local (commit de réconciliation68ee426). Cela démontre la resynchronisation documentée, sans prétendre lire l’état serveur actuel. Global reste intact ; le fichier ecommerce hors chemin n’a pas été chargé.

Le bootstrap Games (`games_ajax.php`) charge Global puis PHP QR Code existant. L’adaptateur local utilise la branche fichier `php://output`, qui n’émet pas l’en-tête PNG de la branche outfile=false. Pas de nouvelle inclusion qrlib, route, fichier PNG temporaire, cache applicatif ou dépendance applicative. Le cache interne historique du tiers reste inchangé.

## Contrat final et dégradation

`play_url → QRcode::png(ECC M, scale12, marge4) → buffer PNG → signature/dimensions → data URI unique → petit/grand IMG marqués`. Une invocation par rendu Master officiel ; aucune pour Play, découverte ou JSON poll. La génération défaillante retourne un secours HTML : Accès joueurs et URL complète, sans carré imposé/clipping du texte. Aucun lien de secours prospect.

QR CDN supprimé uniquement du Master ; usages des autres pages conservés. SweetAlert puis launch_confirmation en defer : usages dans les callbacks d’interaction. Fontes et bootstrap-icons en media=print avec onload ; sans JS la police système reste utilisable. Base CSS explicite block/width/max-width/height:auto et hauteur défilable ; géométrie actuelle sous @supports grid/min/clamp.

Le contrôleur exige marqueur, IMG, complete, dimensions naturelles et affichées positives. Il montre puis mesure le grand avant de masquer le petit. En échec il referme le grand, restaure classes/inert/aria-hidden/focus, sans acquittement expanded. Observation load/error unique en capture ; elle couvre les nodes importés. Refresh conserve le dialog mais remplace son contenu QR/secours et sa classe si nécessaire, après import du panneau prizes. Aucune génération JS. Version d’asset via filemtime.

Sans window.qrcode, CDN QR, exécution du contrôleur, parsing du grand script ou JS entier : le HTML contient déjà le petit PNG. Le test serveur démontre ce contrat sans exécuter de JS navigateur ; il ne simule pas un moteur TV. Pas de promesse ES5 sur programme interactif, lancement/test, refresh, plein écran, Remote. Un CDN SweetAlert lent peut retarder les scripts defer suivants, pas le parsing du body/QR.

## Tests exécutés

Depuis `/home/romain/Cotton/games` :

```sh
php web/tests/hub_player_qr_server_test.php
node web/tests/hub_player_qr_test.mjs
npm install --prefix /tmp/cotton-qr-test --cache /tmp/cotton-npm-cache --no-save --ignore-scripts jsqr@1.4.0 pngjs@7.0.0
NODE_PATH=/tmp/cotton-qr-test/node_modules node web/tests/hub_player_qr_image_test.mjs
php -l web/modules/app_hub_view_helpers.php
node --check web/includes/canvas/core/hub_player_qr.js
git diff --check
```

Résultats : succès. Encodeur PHP réel isolé (cache/log disque désactivés dans la fixture uniquement), décodage indépendant jsQR via pngjs. Jetons synthétiques16/32/128 caractères :492/540/732px, contenu exact = URL canonique fournie ; marge blanche4 modules vérifiée aux quatre bords et par dimension/version, ECC M contrôlé à l’appel. Les deux images SSR sont identiques, une seule génération ; offre propre/réseau/inactive × before/open/expired. Prospect sans URL ni marqueur réel ; Play et dispatcher players_count sans encodeur. Buffers appelants intacts en succès/exception/buffer interne abandonné, warning sans pollution, sortie invalide → secours. HTTP PHP éphémère sur127.0.0.1 : Content-Type text/html en succès et erreur. Aucun bootstrap application ni DB.

DOM Node/vm : images chargées/en attente/cassées, naturalWidth/Height nuls, dimensions affichées nulles, cadenas ignoré, load/error et load après refresh, import du secours, bascule/échec/focus/inert/aria-hidden, confirmations Remote, priorité podium, aperçu historique, takeover, queue, reload et intention manuelle. Liens images DEV-only contrôlés au SSR avec le helper réel.

Suites associées réussies, mêmes répertoires :

```sh
php web/tests/hub_empty_commercial_test.php
php web/tests/hub_branding_sync_test.php
php web/tests/hub_session_settings_test.php
php web/tests/hub_demo_runtime_surfaces_test.php
php web/tests/hub_launch_confirmation_contract_test.php
node web/tests/hub_branding_sync_test.mjs
node web/tests/hub_remote_polling_test.mjs
node web/tests/hub_launch_confirmation_test.mjs
node web/tests/hub_launch_demo_shortcut_test.mjs
```

Depuis `/home/romain/Cotton/global` (lecture code et fixtures mémoire, aucune requête DB exécutée) :

```sh
php web/tests/hub_player_qr_temporal_test.php
php web/tests/hub_player_qr_continuation_test.php
php web/tests/hub_player_qr_master_command_test.php
```

Succès : éligibilité commerciale, before/open, programme vide/terminé/suite jouable, runtime actif, podium, réduction/agrandissement manuel, persistance/reload et changement d’instance. Le code Global ne change pas.

Deux suites plus larges restent rouges :

```sh
php web/tests/hub_remote_contract_test.php
# FAIL: both lobbies keep QR explanation above the field and search help below
php web/tests/hub_remote_master_ux_test.php
# RuntimeException: SSR demo CTA eligibility
```

Contre-épreuve : versions HEAD des tests et du view helper exécutées depuis une copie temporaire avec chemins de lecture réancrés vers le workspace ; mêmes deux erreurs avant patch. Aucun correctif hors périmètre. La seule assertion modifiée du contrat Remote vérifie désormais l’appel du markup serveur avec le flag DEV, à la place du générateur JS supprimé.

## Documentation et suite

Mises à jour dans leurs blocs AUTO-UPDATE : README/TASKS Games, Canvas bridge, HANDOFF, CHANGELOG ; cette note conserve la preuve des tests. `npm run docs:sitemap` régénère les index selon le manifest.

Recette physique restante : Smart TV problématique, scan smartphone des deux tailles, JS coupé et script volontairement non parsable, CDN lent/bloqué, vieille CSS, desktop/hauteurs réduites, focus et Remote pendant refresh. Aucun navigateur réel utilisé ici ; les assertions CSS sont statiques. Aucun accès DEV/PROD, SSH, DB, déploiement, restart ou commit. Livrer ensemble PHP et contrôleur versionné lorsqu’autorisé ; rollback des deux fichiers applicatifs Games ensemble, sans opération données.

<!-- AUTO-UPDATE:END id="hub-player-qr-server-validation" -->
