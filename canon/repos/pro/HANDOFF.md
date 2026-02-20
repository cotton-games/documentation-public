# Handoff — Repo `pro` (canon)

Date: 2026-02-20  
Sujet: Audit ONLY “offre active” à déplacer de PROGRAMMER vers LANCER (sans patch code).

## Update 2026-02-20 — PATCH implémenté (schedule autorisé, launch backend-gated)
- Scope code:
  - `pro/web/ec/ec.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_play_classic.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php`
- Actions réalisées:
  - programmation:
    - suppression du renvoi e-commerce par défaut au moment de programmer (onboarding `choose/0`)
    - `session_init` accepte explicitement le mode non-démo via `flag_session_demo=0` même sans offre active
  - lancement:
    - ajout d’un garde-fou backend central `app_session_launch_guard_get(...)`
    - application du verdict en point d’entrée `/extranet/start/game/play/{id}` avec refus propre + CTA `Voir les offres`
  - uniformisation:
    - `app_session_get_link(..., 'launcher', ...)` passe désormais par le funnel `/start/game/play/{id}` (backend source-of-truth)
    - garde-fou UI local retiré de la carte agenda (la décision d’accès n’est plus côté template)
- Vérifications:
  - `php -l` OK sur tous les fichiers touchés

## Update 2026-02-20 — Fix remaining entrypoints blocking scheduling
- Scope code:
  - `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_0_offres_client.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- Actions réalisées:
  - widget agenda vide:
    - CTA sans offre active redirigé vers `/extranet/start/game/choose/0` (plus vers commande e-commerce)
  - route `/extranet/start/game/offres/`:
    - si aucune offre active listée, redirection automatique vers `choose/0` (programmation autorisée)
    - conservation du contexte éventuel (`id_securite_operation_evenement`, `from`)
  - bibliothèque (programmation non-démo):
    - suppression du retour forcé `/start/game/offres/` quand pas d’offre active
    - envoi explicite `flag_session_demo=0` dans `session_init`
- Vérifications:
  - `php -l` OK sur les 3 fichiers

## Update 2026-02-20 — Home EC sans offre active (widgets harmonisés)
- Scope code:
  - `pro/web/ec/modules/communication/home/ec_home_index.php`
  - `pro/web/ec/modules/widget/ec_widget_ecommerce_abonnement.php`
  - `pro/web/ec/modules/widget/ec_widget_jeux_discover_library.php`
- Actions réalisées:
  - home no-offer:
    - affichage forcé de 2 widgets uniquement (commande puis découverte bibliothèque)
    - masquage des autres widgets de home dans ce cas
  - mapping commande no-offer:
    - typologie `1/8` (+ défaut) => widget abonnement
    - typologie `2/3` => widget événement
    - typologie `12` => widget particulier
  - bypass règles internes abonnement en no-offer:
    - plus de blocage par `id_pipeline_etat` / `id_solution_usage` si `offre_client_active_count==0`
  - widget bibliothèque:
    - nouveau widget “Découvre les jeux Cotton” enrichi (3 points + pictos)
    - CTA vers `/extranet/games/library`
- Vérifications:
  - `php -l` OK sur les fichiers touchés

## Résumé audit
- Audit effectué sur les flux `start` (programmation + lancement) avec preuves `fichier:ligne`.
- Garde-fou actuel trouvé principalement dans la carte agenda (UI) et non au point backend source-of-truth.
- Cartographie livrée pour:
  - flux `PROGRAMMER` (onboarding offres -> `session_init` -> write session)
  - flux `LANCER/JOUER` (UI cards/widgets -> `app_session_get_link` -> route play/launcher)
  - emplacement de la carte session programmée pour le futur message paywall + CTA offres.

## Points d’entrée clés identifiés
- Routing start: `pro/web/.htaccess:168`, `pro/web/.htaccess:179`, `pro/web/.htaccess:200`
- Calcul onboarding offre active: `pro/web/ec/ec.php:63`, `pro/web/ec/ec.php:100`, `pro/web/ec/ec.php:119`
- Create session (`session_init`): `pro/web/ec/modules/tunnel/start/ec_start_script.php:161`, `pro/web/ec/modules/tunnel/start/ec_start_script.php:258`
- Garde-fou UI actuel (agenda): `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:291`, `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:536`
- Génération des liens de lancement: `global/web/app/modules/jeux/sessions/app_sessions_functions.php:851`

## Référence détaillée
- Voir `canon/repos/pro/sessions_scheduled_paywall_audit.md`.
