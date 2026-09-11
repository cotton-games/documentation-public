# Hub Play — départ du Hub, réinscription et ajustements du 07/09/2026

État : audit terminé, copies, lots et réservation publique des pseudos ajustés localement après décision utilisateur, **aucun déploiement**. Aucune fusion/suppression d’identité ni modification du départ serveur. La passe UX/UI et les correctifs photo/consolidation sont préservés.

Recette quitter/réinscrire validée par l’utilisateur le 07/09 : le pseudo utilisé avant départ est bien refusé. Correctif conservé ; cette validation ne vaut pas recette des nouveaux ajustements de classement.

## Preuves documentaires et versions

Parcours rechargé avant patch : [START main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), « Parcours » et « Discipline de génération » → [SITEMAP TXT develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), SITEMAP MD et index Games/Global → [DOCS_MANIFEST](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Routing rules » → HANDOFF et README/TASKS ciblés.

- [README Games raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), **« Update 2026-07-08 — Hub play runtime players V1 »** : identité `guest:{player_token}` dans le Hub, statut left conservant la ligne et l’excluant du compteur ; réactivation si même identité ; unicité des pseudos **actifs** via `pseudo_normalized`.
- Même URL, **« Update 2026-07-08 — Hub play V1: correctif UI historique »** : suppression de l’identité locale et flag leftVoluntarily. Cette section décrit l’ancienne UI locale ; le départ serveur a été ajouté depuis, mais l’effacement navigateur subsiste.
- Même URL, **« Update 2026-09-04 - Hub Play: fondation UX/UI de l’entrée joueur »** : préservation des contrats d’inscription, identité et photo active. La passe locale du 07/09 complète cette section ; les copies raw sont antérieures aux modifications locales.
- [README Global raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), section « Update 2026-07-31 - Photo podium active Hub » : photo active liée à l’identité Hub, aucune reprise par pseudo. Contrat explicite imposant de conserver la preuve navigateur après le bouton Quitter, ou de réserver un pseudo après perte de cette preuve : **non trouvé**. L’unicité des joueurs actifs est en revanche documentée.

Journal AI Studio raw consulté avant patch, puis relu avant l’ajustement des lots et avant la nouvelle règle d’inscription demandés pendant la passe : HTTP 200, contenu identique, dernière mise à jour 28/08. Aucun chemin Hub récent trouvé. URL : `https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb`. Sources PHP serveur non récupérables avec les accès disponibles (pas de SSH/FTP utilisable). Les fichiers potentiellement concernés sont Games `web/modules/app_hub_view_helpers.php`, Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php`, et le garde historique Games `web/includes/canvas/php/boot_lib.php`. Aucun écrasement ; les modifications UX/UI locales étaient présentes et sont conservées.

## Identifiants et chronologie observés

Hub fourni par l’utilisateur : `/hub/31c298ad6a7780b438fb49d074d25b66eaaf36bdba8abad0/master`. Les traces des requêtes `/play` de ce même Hub donnent **id_hub=287**.

| Horodatage serveur | Emplacement | Extrait utile / portée |
|---|---|---|
| 07/09 07:27:36 | Games `logs/error_log:368` | `HUB_PLAY_IDENTITY_RESOLVED_BEFORE_SCREEN_SELECT {id_hub:287,id_hub_player:415,resolved:true}` |
| 07/09 08:29:04 | Games `logs/error_log:1297` | Même événement, identité **415** encore résolue |
| 07/09 08:32:19 | Games `logs/error_log:1377` | `hub_player_leave_party_requested {id_hub:287,player_token_present:true,id_ep_player:0}` : demande de départ invité, sans ID joueur dans ce jalon |
| 07/09 08:32:19 | Games `logs/access_log:3618–3619` | Deux POST vers ce Hub, HTTP **200 / 59 octets**, puis **499 / 0 octet**. Les corps/action ne sont pas consignés : ne pas identifier le POST annulé comme une inscription échouée |
| 07/09 08:32:20–23 | Games `logs/access_log:3621–3625` | POST 200 de 72, 155 puis 1750 octets. Compatibles avec les étapes UI, mais leur taille ne prouve pas `register_guest` ni un INSERT |
| 07/09 08:40:03 | Games `logs/error_log` | `hub_session_access_resolve_start {hub:287,id_hub_player:416,id_session:27681,join_source:auto}` ; identité **416** dans le parcours suivant |
| 07/09 08:40:17 | Games `logs/error_log:1550` | `HUB_PLAY_IDENTITY_RESOLVED_BEFORE_SCREEN_SELECT {id_hub:287,id_hub_player:416,resolved:true}` |

**Avant/après établi : 415 → 416**, pas une simple différence `REMO12`/`Remo12`. Le départ trouvé précède les captures de 08:39–08:40 ; aucune correction de fuseau n’est inventée pour les faire coïncider. Les access logs indiquent explicitement **+0200**. Les error logs n’impriment pas de fuseau, mais les requêtes correspondantes portent la même heure dans les access logs ; cela concorde avec Europe/Paris ce jour-là.

Ce que ces logs ne prouvent pas : SQL INSERT/réactivation exact à 08:32, contenu de la réponse d’inscription, empreintes des tokens avant/après, `hub_photo_media_id` et ligne agrégée de 415/416. Le changement d’identité est prouvé ; l’attribution de la photo/statistiques affichées à 415 reste à confirmer par snapshot/lecture SQL. Le seul écran avec pseudo identique n’aurait pas suffi.

### Journaux réellement examinés

Première lecture avant rechargement : fichiers courants jusqu’au 06/09 22:12:26 Games et 21:45:46 Global. Après le rechargement utilisateur :

- Games `access_log` : 07/09 03:55:53–08:46:38 (4610 lignes datées) ; `error_log` : même période (1646 lignes).
- Global `access_log` et `error_log` : 07/09 03:52:49–08:40:08 (85 lignes chacun).
- Archives gzip examinées en ignorant les exclusions Git : Games `access_log-20260905.gz`, `error_log-20260905.gz`, `access_log-20260906.gz`, `error_log-20260906.gz` couvrent les 04–05/09 ; Global mêmes familles suffixées `20260904`, `20260905`, `20260906` couvrent du 03/09 au 06/09 02:37:05. Aucune trace du 07/09 dans ces archives.
- Recherche ciblée initiale 08:35–08:45, puis élargie à toutes les traces du Hub dans les logs courants : confirmation 415 dès 07:27 et départ à 08:32. Global ne porte pas de jalon d’identité Hub permettant d’enrichir cette chaîne.

Copies d’analyse et couverture dans `/tmp/hub-rejoin-audit`, sans recopier tokens/cookies dans cette note.

## Chemin exécuté et cause

### Départ du Hub, distinct du départ de session

Games `leave_player` appelle Global `app_games_hub_player_leave` : recherche par preuve d’identité dans le Hub, puis `games_hubs_players.status='left'`. Pas de suppression, pas de modification des colonnes de photo/statistiques, pas d’écriture des mappings. `app_games_hub_players_count_active` compte exclusivement les lignes `status='active'` : **1 inscrit n’implique pas 1 identité historique**.

Le callback JS du bouton Quitter envoie d’abord `leave_player` avec la preuve courante, puis arrête le watcher, efface `hub:{token}:player_identity`, pose `hub:{token}:leftVoluntarily=1`, efface les cookies `cotton_hub_token` et `cotton_hub_player_token`, affiche l’inscription et vide le champ. Le flag de départ n’est pas une preuve d’identité et ne réserve pas un pseudo. Le chemin historique ne vérifie pas le booléen métier du payload avant cet effacement et le helper serveur ne vérifie pas le résultat SQL du départ ; aucune preuve que ce défaut de confirmation explique la recette, donc aucun changement de ce périmètre ici.

À l’inverse, `leave_session` conserve l’identité Hub et marque seulement `games_hubs_players_sessions.status='left'`, avec `mark_left=true`. Les logs `hub_session_left_mapping_updated` / `hub_session_left_hub_identity_preserved` et le parcours de retour Player l’expriment. Le départ du Hub n’est ni un reset de score de session ni ce rejoin manuel.

### Inscription et garde d’unicité

- `cleanName` / validation locale et `app_games_hub_player_pseudo_validate` : espaces successifs regroupés, trim, longueur 1–20, casse d’affichage conservée. `app_games_hub_player_pseudo_normalize` replie la casse (`mb_strtolower` si disponible, sinon strtolower) ; `Remo12`, `REMO12`, ` remo12 ` ont la même clé. `remo 12` reste différent de `remo12`.
- Games `games_hub_player_name_validate_for_sessions` possède aussi un garde historique `USERNAME_REFERENCED`, seulement si helper Canvas et PDO sont disponibles. `canvas_session_has_referenced_participant_name` (`boot_lib.php:1020`) recherche les équipes/participants EP référencés du client via leurs historiques ; ce n’est pas la réservation de tous les pseudos invités du classement Hub. Un échec de lecture retombe sur false. Aucun élément des logs ne permet d’affirmer que ce garde devait refuser ce pseudo précis.
- Global `app_games_hub_player_upsert` identifie d’abord `(id_hub, auth_identity_key=guest:{player_token})`. Le propriétaire du pseudo est cherché par `(id_hub,pseudo_normalized,status='active')`. Autre propriétaire actif → `USERNAME_TAKEN`. Les lignes left sont exclues de cette recherche.
- Même identité retrouvée → UPDATE de la même ligne, `registration_state=reactivated` si left ; résultats/photo ne sont pas déplacés. Preuve absente → génération d’un token ; preuve nouvelle → INSERT d’une nouvelle identité. Aucune recherche de récupération par pseudo.
- Le submit navigateur appelle `ensureIdentity` avant `register_guest`. Après le départ qui a effacé le stockage, il génère donc une nouvelle preuve. Ce mécanisme, reproduit en tests, explique une inscription distincte après Quitter. Les logs attestent ici les deux IDs, mais pas l’INSERT lui-même.

### Classement et ancienneté

`games_hub_play_current_identity_keys` retourne uniquement `hub-local:{id_hub}:{id_player}` ; `games_hub_play_general_ranking_for_player` compare cette clé exacte. Le pseudo n’identifie pas le joueur courant. Un invité nouvellement créé sans contribution peut donc voir le classement historique d’un homonyme avec sa photo, tout en recevant `not_ranked=true`. C’est cohérent avec des IDs distincts ; le payload réel du classement manque pour confirmer son attribution ligne par ligne sur la recette.

Comparaison locale avec **Games HEAD d0155a8, 06/09 22:57:39 +0200**, antérieur à la passe UX/UI : `leave_player`, branche intégrale `register_guest`, lecture/création/écriture de preuve JS, callback Quitter, validation des noms et calcul des clés d’identité **identiques avant la passe**. Avant le correctif de réservation ci-dessous, Global applicatif était identique à **HEAD e61a2de, 06/09 22:57:49 +0200**. La sélection visuelle de tête a changé pendant l’UX, mais pas la manière d’identifier le joueur courant. **Mécanisme antérieur, pas une régression d’identité introduite par l’UX/UI** ; égalité avec les sources déployées non vérifiable faute d’accès PHP serveur.

## Caractérisation du comportement antérieur (conservé pour les appels internes)

| Cas | Comportement antérieur testé |
|---|---|
| Même navigateur, preuve valide conservée | `get_current` retrouve la ligne left sans l’activer ; réinscription explicite avec cette preuve réactive le même ID, photo/statistiques conservées |
| Même navigateur après Quitter ou effacement complet de preuve | Nouvelle preuve ; si aucun autre propriétaire actif, nouvelle identité, sans photo/statistiques de l’ancienne |
| Autre navigateur, même pseudo | Refus si propriétaire actif ; nouvelle identité si seuls des propriétaires left subsistent |
| Ancienne preuve retrouvée après réattribution du pseudo | Le garde du propriétaire actif prime : pas de vol/récupération automatique du pseudo |
| Casse/espaces | Casse et espaces extérieurs neutralisés pour l’unicité ; espace interne conservé après regroupement |
| Deux identités homonymes dont une left classée | Ancienne ligne/photo conservées ; nouvelle identité non classée ; compteur actif=1 |

## Règle publique validée et correctif

Décision utilisateur du 07/09 appliquée : l’inscription invitée publique appelle `app_games_hub_player_register_guest_from_play`, qui réserve dans ce Hub tout pseudo normalisé déjà présent, y compris `left`. Après départ, même avec l’ancienne preuve, le pseudo est refusé (`USERNAME_TAKEN`) ; un autre pseudo libre crée une identité neuve sans historique/photo. Une identité encore active peut rejouer sa propre inscription sans mutation. Les réparations internes EP/papier/runtime gardent leur réactivation par identité ; aucune ligne existante n’est fusionnée ni supprimée.

Cette réservation après départ est une nouvelle décision métier explicite de l’utilisateur, et non une règle trouvée dans les anciens documents raw. La requête de propriétaire filtre `id_hub` et `pseudo_normalized`, sans filtre de statut. La normalisation existante reste inchangée. Un verrou SQL nommé par Hub (`GET_LOCK`, libération en `finally`) sérialise les inscriptions publiques ; refus explicite en cas de verrou indisponible ou de lecture échouée. Il ne verrouille pas les réparations internes et n’ajoute pas de contrainte unique de schéma.

| Cas public testé après correctif | Résultat |
|---|---|
| Même navigateur, identité encore active, preuve valide | Même ID, replay sans mutation |
| Après départ, ancienne preuve et même pseudo | Refus, historique intact |
| Preuve effacée, nouveau token ou autre navigateur, même pseudo quitté | Refus, aucune ligne créée |
| Variantes casse/espaces extérieurs du nom réservé | Même refus selon normalisation existante |
| Après départ, autre pseudo libre avec ancienne preuve | Nouvel ID et nouvelle preuve, sans photo/statistiques reprises |
| Nom identique dans un autre Hub | Autorisé selon les gardes habituels |
| Homonymes historiques 415/416 | Aucune migration ; l’identité active peut continuer son replay |
| Lecture propriétaire échouée ou verrou occupé | Erreur explicite, aucune création |

Les tests vérifient aussi compteur actif, correspondance exacte du classement et absence de mutation des mappings. Aucun rapprochement par pseudo ne transfère de résultat.


Pour lever la limite d’attribution des données, lecture seule dans phpMyAdmin (aucun token brut) :

```sql
SELECT id, id_hub, pseudo, pseudo_normalized, status, auth_type,
       LEFT(SHA2(auth_identity_key, 256), 12) AS identity_fingerprint,
       created_at, updated_at, hub_photo_media_id,
       stats_aggregate_score, stats_parties_count
FROM games_hubs_players
WHERE id_hub = 287 AND id IN (415, 416);

SELECT id_hub_player, id_session, status, id_participation, game_type
FROM games_hubs_players_sessions
WHERE id_hub = 287 AND id_hub_player IN (415, 416)
ORDER BY id_hub_player, id_session;
```

## Ajustements appliqués et tests

Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php` : nouveau garde public décrit ci-dessus. Games `register_guest` exige ce helper ; aucun repli vers l’ancien garde. Les deux fichiers applicatifs doivent être livrés ensemble.

Games `app_hub_view_helpers.php` :

- bouton `Quitter la soirée` / `Quitter l’événement` depuis `games_hub_master_wording_labels_get(...).noun_with_article`, incluant le contexte d’usage du client existant ; confirmation reprend exactement ce texte + ` ?` ;
- `Chargement de ta partie…` remplacé par **`Chargement en cours…`** ;
- instruction de masquage des lots par défaut **annulée** : `games_hub_play_prizes_payload` conserve les lignes backend marquées défaut, leurs labels et leurs rangs, puis le renderer les affiche sans recréer de label. Les métadonnées source/is_default restent transmises. HTML initial et poll suivent cette même projection. Aucun lot personnalisé → fallback de `app_games_hub_prizes_default_context`, partagé avec Master ; #3 seul reste #3 ; #1+#3 reste #1+#3 ; suppression totale restaure les fallbacks backend. Une réponse réellement vide/non disponible ne fabrique pas de valeurs.

Tests exécutés **OK** :

- Games `hub_session_settings_test.php` / `hub_session_settings_dom_test.mjs` : copies contextuelles, projection des vrais fallbacks Global, rangs partiels et suppression, DOM conservant les labels backend, garde de preuve/effacement navigateur et confirmation événement/soirée. Les tests réseau et UX de la passe précédente restent verts.
- Nouveau test Global `hub_guest_rejoin_test.php` : fonctions réelles extraites, double SQL en mémoire ; preuve A réactive le même ID, preuve B crée un ID distinct, garde actif/normalisation/portée Hub, photo/stats non reprises, compteur et matching exact du classement. IDs **synthétiques 1→2**, distincts des preuves de recette 415→416 ; aucune connexion DB réelle. Suite publique supplémentaire : refus après départ avec/sans preuve, autre navigateur, casse/espaces, portée Hub, nouvel ID sans historique pour un autre nom, replay actif, homonymes historiques, erreurs/verrou et intégration du vrai handler Games vérifiant le JSON `USERNAME_TAKEN`.
- Global `hub_player_roster_registration_state_test.php`, `hub_aggregate_photo_fallback_test.php`, `hub_stats_pending_session_test.php` ; Games `hub_photo_replace_test.mjs` : verts, A→B→C et maintien du formulaire pendant les polls, consolidation valide et 20 lectures sans fallback après rebuild simulé.
- PHP lint et diff check : OK. Aucun test navigateur réel ni lecture SQL du Hub 287 exécuté ; aucune nouvelle instrumentation serveur ajoutée.

Documentation : HANDOFF + TASKS Games/Global actualisés dans leurs entrées existantes, README Games et Global/canon précisés, note UX mise en cohérence avec le retour des fallbacks, CHANGELOG actualisé ; sitemap/index régénérés puis relus. Retour arrière limité aux ajustements de cette passe, sans retirer l’UX/photo/consolidation existants.
