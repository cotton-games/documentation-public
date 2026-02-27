# Audit — Offre active (schedule vs start)

Date audit: 2026-02-20  
Scope: `pro/web/ec/modules/tunnel/start/*`, `pro/web/ec/ec.php`, dépendances `global/web/app/modules/*`  
Contraintes: audit documentaire uniquement, aucun patch applicatif.

## 1) Findings (preuves fichier:ligne)
- Le point d’entrée “Programmer” est conditionné par le nombre d’offres actives (`id_etat=3`) dans le shell EC:
  - `pro/web/ec/ec.php:63`
  - `pro/web/ec/ec.php:100`
  - `pro/web/ec/ec.php:119`
- Le bouton “Ajouter” de l’agenda réutilise ce lien onboarding:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php:8`
- Le widget “Nouvelle session” réutilise aussi cette logique onboarding:
  - `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php:5`
  - `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php:38`
- Le handler de création session est `session_init`:
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php:161`
  - write DB via `app_session_ajouter(...)`: `pro/web/ec/modules/tunnel/start/ec_start_script.php:258`
- Le lookup offre client depuis `id_securite_offre_client` ne filtre pas l’état actif:
  - `global/web/app/modules/ecommerce/app_ecommerce_functions.php:822`
- Le garde-fou actuel “offre active” côté sessions programmées est dans la carte agenda (UI):
  - calcul flag accès: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:291`
  - logique date_fin ABN: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:304`
  - fallback CTA “Je renouvelle mon offre”: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:538`
- Le lancement réel passe par des routes dédiées:
  - route play classique: `pro/web/.htaccess:200`
  - handler play classique: `pro/web/ec/modules/tunnel/start/ec_start_sessions_play_classic.php:1`
- La fonction de génération de liens de lancement (`app_session_get_link`) gère surtout la chronologie session (`before/during/after`) et pas l’état actif offre:
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php:851`
  - `global/web/app/modules/jeux/sessions/app_sessions_functions.php:855`
- Surface UI alternative: le widget agenda pointe directement sur `app_session_get_link(...)` sans le garde-fou de `sessions_list_bloc.php`:
  - `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php:100`

## 2) Flow map

### PROGRAMMER (hors démo)
1. UI agenda/dashboard:
   - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php:8`
   - `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php:38`
2. URL onboarding construite selon offres actives:
   - `pro/web/ec/ec.php:95`
   - `pro/web/ec/ec.php:100`
3. Choix jeu -> POST `frm_mode=session_init`:
   - `pro/web/ec/modules/tunnel/start/ec_start_step_1_game.php:52`
4. Handler:
   - `pro/web/ec/modules/tunnel/start/ec_start_script.php:161`
   - résolution `id_offre_client` via `app_ecommerce_offre_client_get_id`: `pro/web/ec/modules/tunnel/start/ec_start_script.php:180`
5. Write DB:
   - `app_session_ajouter(...)` -> table `championnats_sessions`: `pro/web/ec/modules/tunnel/start/ec_start_script.php:258`

### LANCER / JOUER
1. UI carte session programmée:
   - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:492`
2. URL launcher:
   - `app_session_get_link(...)`: `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:385`
3. Variante classique:
   - route `/extranet/start/game/play/{id}` -> `sessions_play_classic`: `pro/web/.htaccess:200`
   - handler: `pro/web/ec/modules/tunnel/start/ec_start_sessions_play_classic.php:1`
4. Source-of-truth de construction des liens:
   - `global/web/app/modules/jeux/sessions/app_sessions_functions.php:851`

## 3) Matrice checks “offre active” (actuel)

| Zone | Check offre active | Où | Effet actuel |
|---|---|---|---|
| UI onboarding programmer | Oui (`id_etat=3`) | `pro/web/ec/ec.php:63` | Redirige vers offres si 0 active |
| Backend `session_init` | Partiel (existence id_securite -> id_offre_client) | `pro/web/ec/modules/tunnel/start/ec_start_script.php:180` | Crée session si offre trouvée, sans check explicite “active” |
| UI carte session programmée | Oui (cas ABN/date_fin) | `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php:291` | Cache “Ouvrir le jeu”, montre “Je renouvelle mon offre” |
| Backend lancement source-of-truth | Non trouvé (offre active) | `global/web/app/modules/jeux/sessions/app_sessions_functions.php:851` | Lien calculé selon chronologie session |
| UI widget agenda (autre surface) | Non (équivalent garde-fou) | `pro/web/ec/modules/widget/ec_widget_client_lieu_sessions_agenda.php:100` | Lien direct launcher |

## 4) Candidate patch points (sans code)
- Retirer le garde-fou “offre active” de la couche UI programmation/liste si l’objectif produit est de déplacer le verrou au lancement.
- Implémenter le check bloquant offre active côté backend de lancement (route/handler commun launcher/play) pour en faire la source-of-truth.
- Harmoniser les surfaces UI (liste agenda + widget agenda + accès URL direct) avec un état cohérent issu du backend:
  - message explicite
  - CTA “Voir les offres”.

## 5) Risques / non-régression à couvrir au patch futur
- Différence de comportement entre:
  - démo (`flag_session_demo=1`)
  - programmation hors démo (`flag_session_demo=0`)
  - accès direct URL launcher/play.
- Multi-jeux (Quiz/Bingo/Blindtest) car `app_session_get_link` est partagé.
- Cohérence old/new launchers (types produit 1/3/4/5/6).

## 6) Patch implemented (2026-02-20)
- Programmation autorisée sans offre active:
  - onboarding par défaut vers `choose/0` (au lieu renvoi offres) dans `pro/web/ec/ec.php`.
  - transport explicite `flag_session_demo` depuis le step jeu (`ec_start_step_1_game.php`).
  - `session_init` accepte un flux non-démo sans offre active (`ec_start_script.php`).
- Garde-fou déplacé au lancement backend:
  - fonction source-of-truth `app_session_launch_guard_get(...)` ajoutée dans `global/web/app/modules/jeux/sessions/app_sessions_functions.php`.
  - vérification bloquante appliquée dans `pro/web/ec/modules/tunnel/start/ec_start_sessions_play_classic.php` avec écran de refus + CTA offres.
- Uniformisation UI:
  - funnel `launcher` vers `/extranet/start/game/play/{id}` via `app_session_get_link(...)`.
  - retrait du garde-fou d’accès local dans `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`.
- Entry points restants corrigés (programmation):
  - widget `Nouvelle session` (agenda vide / sans offre) -> `choose/0` au lieu d’e-commerce:
    - `pro/web/ec/modules/widget/ec_widget_jeux_sessions_cta.php`
  - route `start/game/offres`:
    - si liste d’offres actives vide, redirection vers `choose/0` (programmation non bloquée):
    - `pro/web/ec/modules/tunnel/start/ec_start_step_0_offres_client.php`
  - flux bibliothèque:
    - suppression du stop sur absence d’offre active + `session_init` non-demo explicite (`flag_session_demo=0`):
    - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
