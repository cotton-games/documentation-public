# Home EC — Widgets INS/CSO (ordre + variantes UI)

Date: 2026-02-23

## Objectif
Améliorer la home EC sans offre active avec:
- un widget découverte des jeux harmonisé (INS/CSO),
- un widget CSO “Choisir une offre” clarifié.

## Ordonnancement
- Source pipeline: `client_pipeline_etat_nom` (voir `pro/web/ec/ec.php:60`).
- Home no-offer: `pro/web/ec/modules/communication/home/ec_home_index.php`.
- Règles:
  - INS: découverte en 1er, offre en 2e.
  - CSO: offre en 1er, découverte en 2e.
  - Offre dynamique selon typologie (CHR/événement/particulier), avec variante CSO dédiée sur CHR/lieu public.

## Widget découverte
- Fichier: `pro/web/ec/modules/widget/ec_widget_jeux_discover_library.php`.
- Texte final:
  - Titre: `Les jeux Cotton`
  - Sous-titre: `Parcours les catalogues Blind Test, Bingo Musical et Cotton Quiz.`
  - CTA: `Découvrir les jeux` (fixe, sans condition INS/CSO)
- Assets bannière 3 visuels (bibliothèque):
  - `.../statique/jeux/blind-test/presentation/blind-test.jpg`
  - `.../statique/jeux/bingo-musical/presentation/bingo-musical.jpg`
  - `.../statique/jeux/cotton-quiz/presentation/cotton-quiz.jpg`
- Bullets:
  - `Joue des démos en 1 clic`
  - `Utilise tes contenus persos`
  - `Programme tes sessions dans l'agenda`
- UI:
  - carte cliquable globalement (`stretched-link`)
  - alignement vertical centré texte/icone sur les 3 bullets
  - icones sombres uniquement pour typologie événement (`id_typologie` 2/3), blanches sinon
- Couleur accent:
  - typologie 1/4/5/6/8 => `20`
  - typologie 2/3 => `22`
  - typologie 12 => `21`

## Widget CSO “Choisir une offre”
- Fichier: `pro/web/ec/modules/widget/ec_widget_ecommerce_abonnement_cso.php`.
- Spécificités:
  - pastille supprimée.
  - titre:
    - `✨ Fidélise ta clientèle et apporte de la nouveauté.`
  - intro:
    - `Découvre ou redécouvre comment nos jeux transforment l'ambiance et boostent le CA de ton établissement.`
  - 3 bullets:
    - `Sans engagement` + `Flexible selon la fréquentation. Annulation en 1 clic.`
    - `Sessions illimitées` + `Accès immédiat à Blind Test, Bingo et Quiz.`
    - `Prêt en 2 minutes` + `Plug & Play, sans téléchargement.`
  - CTA:
    - `🚀 Je choisis mon offre`
  - note bas de carte:
    - supprimée (version finale)

## Correctifs liens commande
- `pro/web/ec/ec.php`
  - routes commande root-relative pour éviter le doublon `/extranet/extranet/...`:
    - `/extranet/ecommerce/offers/abonnement/s1/1`
    - `/extranet/ecommerce/offers/evenement/s1/6`
    - `/extranet/ecommerce/offers/particulier/s1/1`
- `pro/web/ec/modules/communication/home/ec_home_index.php`
  - closure de rendu home no-offer corrigée pour capturer `$url_ecommerce` dans son scope.
- `pro/web/ec/modules/widget/ec_widget_ecommerce_abonnement_cso.php`
  - CTA explicite vers `/extranet/ecommerce/offers/abonnement/s1/1`.
