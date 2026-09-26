<!-- AUTO-UPDATE:BEGIN id="hub-access-probable-only-20260921" owner="codex" -->
# Accès WWW/Play Hub probable-only — révision locale du 21/09/2026

## A. Contrôle préalable docs/journal

Sources RAW consultées, sans accès applicatif distant :

- [START](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), « Parcours », « Discipline de génération ».
- [SITEMAP texte](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), « Repos » / « Global specs » ; [NDJSON](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.ndjson), entrées `repo`/`doc` ; [SITEMAP Markdown](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md), navigation.
- [README général](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), « Doc discipline (repo-first) » ; [manifest](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers » / « Routing rules » ; [HANDOFF](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md), « Actions réalisées ».
- [Play README](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/play/README.md), « Update 2026-07-31 — EP auth: intention probable Hub » ; [Global README](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Update 2026-07-31 - Participations probables Hub et présence runtime ».
- [WWW README](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/www/README.md) et [bridge](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/interfaces/canvas-bridge.md) consultés ; nouveau contrat du21/09 non trouvé dans ces versions RAW, décrit par la demande utilisateur puis les modifications locales.
- [Journal AI Studio RAW](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb&raw=1), « Septembre 2026 », épisode `.htaccess`, et « Mars 2026 », interconnexion des pages features. Le Markdown a été extrait de `const raw` dans l’enveloppe HTML reçue.

Les écarts WWW déjà signalés sont couverts par la confirmation « fichiers rechargés » consignée dans [le rapport local du20/09](hub-participation-cta-2026-09-20.md), section « Préparation et sources ». Aucun nouveau signal ciblé à recharger ; aucune parité serveur certifiée. Aucune copie distante, opération SSH/DB/DEV/PROD, navigation intégrée, livraison ou restart.

## B. Comparatif Git/local du patch précédent

Les dépôts contenaient déjà les patches CTA, jauge et routage. Baseline des fichiers modifiés/non suivis et `git diff` sauvegardés dans `/tmp/cotton-access-audit/baseline/` avant édition ; hunks propres à cette révision dans `/tmp/cotton-access-audit/revision/`. Ces chemins temporaires ne sont pas des livrables versionnés.

- play HEAD : `4a7c22623ca2e8f0eef6dc176c51a4ed1876e733`.
- www HEAD : `138584c3e57f007961b5bc95abb8f00de1fcbb52`.
- global HEAD : `0fbb78cfb868a3c996a6036c77d20811649a6401`.
- documentation HEAD : `974d9496853459cc8cc9cb81ecc27b192b7a1690`.

| Surface du20/09 ou historique31/07 | Révision du21/09 |
|---|---|
| Contexte EP `open → ep_join` | `probable` ou `cancel_probable` avant/open |
| Action `session_hub_ep_join` | Refusée ; branche d’admission supprimée |
| Page EP Hub `hub_ep_join` | Action et formulaire supprimés ; probable/cancel avec CSRF |
| WWW session → intention Hub `join` pendant fenêtre | `/signin/public/{token source}` → fiche EP source |
| Intention auth absente/invalide normalisée `join` | Normalisée `probable` dans les pages, scripts et helper Global |
| `prepare_ep_return(intent=probable)` admettait pendant fenêtre | Retour EP Hub sans admission, quelle que soit l’ouverture |
| CTA Hub en haut de fiche WWW + boutons FAQ | Participation réintégrée à son emplacement existant ; FAQ informative |
| Boutons Hub supplémentaires cartes/client/page Hub classiques | Retirés ; consultation existante conservée, exception QR maintenue |
| Probable individuelle avec fallback legacy session | Lecture Hub stricte pour les surfaces EP, défaut legacy conservé ailleurs |

Conservés : helper contexte en lecture seule, temporalité canonique, déclaration/annulation, wording utile, filtrage QR `open` J/J-1, session autonome. `player_canvas.php`, `.htaccess` Play/WWW, helper capacité, Bingogrids et moteurs ne sont pas modifiés par cette révision. Les changements préexistants de ces fichiers restent présents.

## C. Fiche EP probable-only

Le renderer commun ne rend et n’accepte que probable/cancel. État annoncé lu depuis la table Hub ; absence/annulation restaure la participation. Aucun URL Hub Play ni admission. Le renderer reste placé avant la branche de résultats de la session : S2 terminée ne bloque pas le Hub pertinent. L’ancien paramètre POST `ep_join` est refusé.

## D. Agenda EP probable-only

`ep_sessions_list_bloc.php` reste inchangé dans cette révision : son appel au helper partagé reçoit automatiquement le nouveau contrat. Le fallback de lecture session n’est pas utilisé pour l’état individuel Hub. Préchargements et compteurs legacy existants non refondus.

## E. Page EP Hub probable-only

Même contexte de lecture et mêmes états que fiche/agenda. POST déclaration/annulation uniquement, identité EP et CSRF contrôlés. Ancien POST `hub_ep_join` refusé, aucun redirect Hub Play, aucun message d’accès ou de jauge pleine ; informations et consultation conservées. Après expiration/inactivité : aucune action de probable.

## F. Signin/signup et joins automatiques

Le token session des URLs WWW reste dans les liens croisés signin/signup et les formulaires ; retour EP session via le helper historique. Pour un contexte Hub sans session, `probable` revient à la fiche EP Hub même si la fenêtre s’ouvre pendant l’authentification. Intention absente/invalide : probable ; aucun fallback runtime sur échec d’un retour probable.

Le `join` explicite produit par Hub Play reste fonctionnel pour la connexion d’un compte depuis une vraie porte terrain. Le helper n’est donc pas supprimé globalement. Complément demandé ensuite : seuls les GET `probable` déjà connectés affichent l’EP sans write. Les GET explicites `join` provenant du parcours compte Hub Play reprennent désormais l’admission canonique, comme les POST auth ; voir [correctif compte/partage](play-hub-account-return-share-2026-09-21.md). Il s’agit d’un contrat de navigation, pas d’une preuve cryptographique d’origine : les URLs historiques contenant explicitement `hub_account_action=join` restent compatibles avec le parcours compte Hub Play.

## G. WWW classique → EP

Participation de la fiche session dans l’emplacement existant ; destination `/signin/public/{token}` et wording soirée/événement. Les emplacements de simple consultation sur les cartes agenda/client/Hub restent des liens de détail ; aucun bouton Hub additionnel classique. FAQ de participation informative, sans second bouton ajouté. Aucune URL Hub Play classique générée.

## H. QR permanent, seule exception Hub Play WWW

`/place/{code_client}` et son intention propagée `qr_place=1` gardent le CTA runtime sans compte imposé uniquement si `app_games_hub_temporal_state()` renvoie `open`. Futur/expiré/inactif : aucun accès direct. J+1 avant midi couvert par la temporalité canonique. Invité/compte restent décidés dans Hub Play.

Le programme filtre toujours les Hubs ouverts publiables J/J-1 et dédoublonne leurs sessions. Un test avec deux Hubs ouverts vérifie qu’aucun n’est sélectionné arbitrairement. Existence réelle de plusieurs Hubs ouverts pour un établissement : non vérifiée, faute d’accès DB ; aucune règle silencieuse ajoutée.

## I. Sessions autonomes et équipes

Le renderer Hub laisse les sessions autonomes à leurs branches historiques. Test explicite du retour EP direct le jour J, avec bridge simulé ; aucune modification des helpers d’admission session. Anciennes URLs Player et QR Hub/session inchangées, suite de routage legacy verte.

Équipes Quiz : modèle et actions équipe legacy inchangés. Interaction résiduelle préexistante : le CTA individuel Hub prend le pas sur les branches équipe dans fiche/agenda ; préchargement et compteurs legacy subsistent. Aucune probable équipe transformée en probable Hub individuelle.

## J. Tests

Depuis `/home/romain/Cotton` :

```bash
php play/web/tests/ep_session_hub_cta_test.php
php play/web/tests/ep_hub_probable_capacity_test.php
php play/web/tests/ep_hub_detail_contract_test.php
php play/web/tests/ep_session_routing_contract_test.php
php global/web/tests/hub_ep_return_intent_test.php
php global/web/tests/hub_probable_participations_contract_test.php
php global/web/tests/hub_player_roster_registration_state_test.php
php global/web/tests/hub_player_qr_temporal_test.php
php global/web/tests/hub_capacity_test.php
php global/web/tests/hub_capacity_bingo_grid_test.php
php games/web/tests/hub_legacy_entry_routes_test.php
php games/web/tests/hub_probable_play_contract_test.php
```

Résultat : suites ci-dessus vertes. 310 contrôles du contrat CTA/rendus/retours ; 16 contrôles probable/cancel utilisant les vrais helpers SQL avec DB simulée à50/50 ; routage75 et jauge89 contrôles. Fixtures testent avant/open, déclaré/annulé/confirmé, GET sans write, CSRF, anciens joins refusés, S2 terminée, auth connecté/non connecté au niveau du retour partagé, QR invité, J+1 cutoff, deux Hubs ouverts, vrais renderers client et page publique Hub, vraie page EP Hub. Le rendu complet fiche/agenda est contrôlé par leur intégration au helper ; aucune recette navigateur ni auth HTTP interdomaines exécutée.

La suite supplémentaire `php games/web/tests/hub_player_qr_server_test.php` échoue : `Trying to access array offset on null`, `app_hub_view_helpers.php:4985`, `$conf['server']` absent de sa fixture. Ces deux fichiers Games sont inchangés et propres par rapport à HEAD ; le test ne charge aucun fichier applicatif modifié ici. Échec indépendant signalé, pas de correction hors périmètre.

Lint PHP sur les19 fichiers applicatifs/tests de cette révision et `git diff --check` vérifiés ; `npm run docs:sitemap` exécuté. DB/réseau simulés ; aucune preuve de persistance réelle ni d’interface mobile.

## K. Fichiers et documentation

### global

- `web/app/modules/jeux/hubs/app_games_hub_participation_cta.php`
- `web/app/modules/entites/joueurs/app_joueurs_functions.php`
- `web/app/modules/jeux/hubs/app_games_hubs_functions.php`
- `web/tests/hub_ep_return_intent_test.php`

### play

- `web/ep/includes/ep_session_hub_cta.php`
- `web/tests/ep_hub_probable_capacity_test.php`
- `web/tests/ep_session_hub_cta_test.php`
- `web/ep/ep_signin.php`
- `web/ep/ep_signup.php`
- `web/ep/modules/compte/authentification/ep_authentification_script.php`
- `web/ep/modules/compte/joueur/ep_joueur_script.php`
- `web/ep/modules/jeux/hubs/ep_hubs_detail.php`
- `web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `web/ep/modules/jeux/sessions/ep_sessions_inscription_script.php`
- `web/tests/ep_hub_detail_contract_test.php`

### www

- `web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- `web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
- `web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
- `web/fo/modules/operations/hubs/fr/fo_hubs_view_shared.php`


Documentation : README/TASKS Play, WWW, Global ; `canon/interfaces/canvas-bridge.md`, `canon/runbooks/security.md`, `DOCS_MANIFEST.md` R22, `HANDOFF.md`, `CHANGELOG.md`, note historique20/09 annotée et cette note. Le contrat31/07 est explicitement remplacé dans les blocs maintenables des README/TASKS ; contenu historique hors blocs préservé. Sitemap et index régénérés par le générateur, pas édités à la main.

## L. Limites et rollback

Reste recette navigateur/HTTP/DB réelle après livraison autorisée : signin/signup, navigation session→EP, agenda, QR invité/compte et état réel des Hubs ouverts. Les tests locaux ne certifient ni les données distantes ni l’intégration de services. Échec QR serveur indépendant ci-dessus.

Rollback : appliquer uniquement l’inverse des hunks de cette révision, en préservant les fichiers/hunks préexistants sauvegardés ; ne pas utiliser `git reset`/`checkout` global, les patches20/09 et jauge ne sont pas tous committés. Retirer le nouveau test de capacité probable seulement si rollback complet ; régénérer les index. Aucun changement de schéma ou données à restaurer.
<!-- AUTO-UPDATE:END id="hub-access-probable-only-20260921" -->
