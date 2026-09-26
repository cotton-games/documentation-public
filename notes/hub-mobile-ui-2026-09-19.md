# Mini-patch UI Dashboard / Hub mobile — 19/09/2026

Local uniquement, sans déploiement/restart. Complète le [responsive du 18/09](hub-master-responsive-2026-09-18.md).

## Preuves avant patch

START main, SITEMAP develop, README général, manifest, HANDOFF, README Pro/Games et journal AI Studio RAW relus. Le journal ne mentionne aucun des fichiers ciblés ; aucune divergence distante déclarée n’a nécessité de rechargement. Ce constat ne certifie pas la parité serveur.

État initial : Pro `hub_soiree`, HEAD `234deaef30e311ea31cd68871391688ea800bbfa` ; Games `hub_soiree`, HEAD `855c25a4f8a29d65e0381f1e8333f8b02fd3c4f2`. Les modifications non commitées du responsive précédent étaient présentes, préservées. Documentation `develop`, HEAD `ca89215e5a0585f0415fda2a96d13c86e0ec9ab1`, également modifiée par le patch précédent.

Cause desktop : `.event-dashboard--v2 .event-dashboard__header-action-main .event-dashboard__hub-main` (trois classes) imposait `display:block`, contre deux classes pour masquer le libellé mobile. Le masque utilise maintenant la même spécificité et vient après. Les règles desktop antérieures au bloc responsive sont identiques octet pour octet à l’état d’entrée : ratio, sticky, spacing, couleurs, hover/focus conservés. La composition Remote et le libellé desktop PHP n’ont pas changé.

## Corrections

- Pro mobile : barre sticky `top:.75rem`, même niveau et tokens de surface/bordure que le desktop, marges dans le flux ; hauteur minimale du CTA 64px, texte pouvant revenir à la ligne. Aucun header masqué.
- Wording PHP : la projection existante `is-upcoming` donne Préparer, `is-live` Reprendre, sinon Lancer ; suffixe soirée/événement. Priorité `is_done` : traitement mobile précédent conservé (Lancer), aucun CTA résultats ajouté. Le prospect utilise la même projection, sans changer son offre/démo. Les refresh recopient le libellé serveur sans recalcul JS.
- Hub : « Retour à l’espace organisateur », href inchangé. Quick Add : padding symétrique, + et libellé centrés, CTA Ajouter pleine largeur inchangé.
- Compteur : sous QR, typographie compacte, couleur/graisse issues du compteur existant. Summary et zéro du panneau joueurs masqués uniquement mobile. Le compteur sous QR est masqué quand son voisin porte `is-discovery`, règle déjà présente dans chaque rendu SSR/refresh. Données, sélecteurs JS et polling inchangés.
- `Démo non disponible pour cette partie.` : texte, style, visibilité et logique inchangés. Comparaison du renderer Games avant/après : seule modification PHP = libellé du retour. Papier, service Hub, QR/overlay/scan, lots, utilitaires, Global, moteurs, Play et DB hors patch.

## Fichiers de ce mini-patch

Pro, sous `web/ec/modules/tunnel/start/` : `ec_start_sessions_day_helpers.php`, `ec_start_sessions_day_dashboard_view.php`, `ec_start_sessions_day_dashboard_v2_style.php` ; nouveau test `ec_start_dashboard_mobile_wording_test.php`.

Games : `web/modules/app_hub_view_helpers.php`, `web/includes/canvas/css/hub_master_mobile.css` ; nouveau test `web/tests/hub_mobile_ui_test.mjs`.

## Tests exécutés

Depuis Pro :

```sh
php web/ec/modules/tunnel/start/ec_start_dashboard_mobile_wording_test.php
php web/ec/modules/tunnel/start/ec_start_dashboard_mobile_routing_test.php
node web/ec/modules/tunnel/start/ec_start_dashboard_mobile_refresh_test.mjs
php web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php
```

Résultats : 10 libellés validés via la vraie projection PHP (préparation/prêt/en cours/suspendu/terminé × soirée/événement) ; 154 contrôles routage verts ; refresh et décisions d’accès 991 ↔ 992 verts ; suite Dashboard verte.

Depuis Games :

```sh
node web/tests/hub_mobile_ui_test.mjs
node web/tests/hub_master_mobile_actions_test.mjs
node web/tests/hub_player_qr_test.mjs
node web/tests/hub_quick_add_refresh_test.mjs
php web/tests/hub_prospect_card_action_test.php
```

Résultats : verts. Le nouveau test vérifie les règles CSS/markup et exécute le hook réel de copie du libellé après refresh. Les autres suites exercent handlers, accès, QR et Quick Add dans des adaptateurs DOM/VM. Lint PHP des quatre fichiers PHP applicatifs concernés : OK. Aucune prétention de validation du layout navigateur par ces tests.

## Recette visuelle restante

Sans navigateur intégré, DB, SSH ou DEV/PROD : recette non exécutée. Tester actif/prospect, soirée/événement, 1/plusieurs sessions à 360/390/430/768/991/992px. À 991 ↔ 992 sans reload : seul libellé approprié visible ; sticky mobile/desktop ; retour ; Quick Add centré ; compteur unique sous QR actif et absent en découverte ; refresh sans réapparition ; desktop Diffusion/Remote identique. Contrôler header visible, absence de débordement horizontal/recouvrement gênant, couleurs claires/sombres et scroll naturel. Vérifier Mode découverte et Activer mon essai gratuit inchangés.

## Git et rollback

`git diff --check` : OK. Branches et HEAD inchangés. Les statuts finaux incluent les modifications précédentes ; ce mini-patch ajoute seulement les fichiers/tests listés ci-dessus et sa documentation. Aucun autre repo applicatif modifié. Rollback : retirer seulement ce complément UI, préserver le responsive du 18/09 ; aucune donnée à annuler.

Statuts applicatifs finaux (`git status --short`, comprenant le travail précédent) :

pro

```text
 M web/ec/modules/tunnel/start/ec_start_dashboard_mobile_refresh_test.mjs
 M web/ec/modules/tunnel/start/ec_start_dashboard_mobile_routing_test.php
 M web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_test.php
 M web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_v2_style.php
 M web/ec/modules/tunnel/start/ec_start_sessions_day_dashboard_view.php
 M web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php
?? web/ec/modules/tunnel/start/ec_start_dashboard_mobile_wording_test.php
```

games

```text
 M web/includes/canvas/core/hub_player_qr.js
 M web/modules/app_hub_view_helpers.php
 M web/tests/hub_launch_confirmation_test.mjs
 M web/tests/hub_player_qr_test.mjs
?? web/includes/canvas/css/hub_master_mobile.css
?? web/tests/hub_master_mobile_actions_test.mjs
?? web/tests/hub_master_mobile_cards_test.php
?? web/tests/hub_master_mobile_post_test.php
?? web/tests/hub_mobile_ui_test.mjs
```

