# Hub Play — remplacement de photo, audit du 6 septembre 2026

## Sources et état de travail

- [START raw main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), sections « Statut actuel », « Parcours », « Discipline de génération » : main = production documentaire, develop = travail en cours.
- [SITEMAP raw develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), puis SITEMAP.md, README, index canon/repos/Games, manifeste et HANDOFF rechargés. Copies de lecture temporaires dans `/tmp/hub-photo-docs`.
- [Manifeste raw develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers » : TASKS/HANDOFF, README fonctionnel et génération obligatoire.
- [Games README raw develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « Update 2026-09-04 - Hub Play: fondation UX/UI de l'entrée joueur » : identité `games_hubs_players`, action auprès de « Tu participes avec », autorité Top 3 agrégé serveur, conservation hors Top 3, consentement et enrichissement des podiums.
- [Global README raw develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Update 2026-07-31 - Photo podium active Hub » : média actif, writer et révision Hub. README/TASKS Play également consultés ; le code du parcours est dans Games et Global.
- Les mêmes chemins README Games/Global sur main et develop diffèrent : écart documentaire develop/main, aucune preuve de déploiement du patch présent.
- Journal AI Studio public fourni : HTTP 200 par curl ; lecteur HTML contenant le Markdown intégral dans `const raw`, décodé sans exécution. `raw=1` renvoie également le lecteur HTML. Dernière mise à jour : 28/08/2026 ; sections « EN COURS » et « Fait, livré en PROD » : campagne Rentrée, WWW/AI Studio/ecommerce, aucun chemin Hub Play/photo récent à recharger. Le navigateur outil a refusé l'URL ; lecture curl réussie.
- Worktrees Games/Global/Play/Documentation propres au départ. Aucune modification locale écrasée. Source serveur potentiellement concernée : `games/web/modules/app_hub_view_helpers.php`, `app_hub_play_ajax.php`, `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php`, `sessions/app_sessions_functions.php`, `global/web/lib/core/lib_core_upload_functions.php`. Comparaison/rechargement source serveur **non réalisé** : SSH bloqué par absence de clé d'hôte connue, profils FTP locaux sans mot de passe enregistré. Pas de conflit source détectable sans cette comparaison. Les archives de logs ont été rechargées par l'utilisateur pendant l'audit.

## Logs examinés avant correctif ou instrumentation

Archives décompressées seulement dans `/tmp/hub-photo-logs` ; aucun log brut/token/IP publié dans le dépôt.

| Emplacement | Période réelle examinée | Observations |
| --- | --- | --- |
| `games/logs/{access,error}_log-20260905.gz` | 04/09 03:56:16–23:44:35 | 27 543 lignes access, 11 475 error |
| `global/logs/{access,error}_log-20260904.gz` | 03/09 04:22:45–04/09 02:57:33 | 301 lignes chacun, inclut le début du 4 |
| `global/logs/{access,error}_log-20260905.gz` | 04/09 05:28:12–22:30:25 | 720 lignes chacun ; aucune trace métier photo/upload Hub corrélable |
| Games/Global `*-20260906.gz` | 05/09, Global jusqu'au 06/09 | inventaire temporel ; aucun complément de recette du 4 |
| Games/Global `access_log`, `error_log` | 06/09 jusqu'à 21:42:17 Games / 21:41:19 Global | mêmes fichiers manquants retrouvés à 20:58:21 et 20:59:56 Games |

Access porte explicitement `+0200` (Europe/Paris en septembre). Error nginx n'indique pas de fuseau : les mêmes POST corrélés portent exactement la même heure qu'access, donc +0200 déduit pour ces occurrences, pas une vérification de configuration PHP/SQL.

- **04/09 18:57:58**, error décompressé ligne **10173** : `[hub_aggregate_ranking_persistent_loaded] {"id_hub":283,"rows_count":2,"read_ms":5}`, puis `[missing_local_file] media=hub-player-283-410-podium-active.jpg`. Le chemin recherché est `/var/www/www.dev.cotton-quiz.com/web/upload/www/images/championnats/resultats_podium_sessions_blindtest/hub-player-283-410-podium-active.jpg`. Même POST `/hub/[token masqué]/play` dans access ligne **24792**, **HTTP 200**, 393 octets.
- **04/09 19:00:40**, error ligne **10272** : apparition de `hub-player-283-411-podium-active.jpg` manquant, en plus de 410. Trois POST de cette route à la même seconde (access **25098, 25099, 25101**), HTTP 200, respectivement 1824/396/164 octets : attribution individuelle de l'action impossible sans corps POST.
- 410 : **492 lignes error** contenant son fichier manquant entre 18:57:58 et **19:46:30**. 411 : **439 lignes**, entre 19:00:40 et 19:46:30. Comptage de lignes, pas de requêtes d'upload (plusieurs messages PHP possibles dans une ligne).
- Contexte observé avant incident : Hub 283, présentation session **27673**, à 18:57:17. Le dossier média indique Blindtest. Cela ne prouve pas le `session_id` soumis pour consentement.
- HEAD effectué le 06/09 sur le chemin image 410, domaines `www.dev.cotton-quiz.com` et `www.cotton-quiz.com` : **404**, `text/html`. Le resolver renvoie une URL de repli PROD même lorsqu'aucun fichier local n'existe ; une URL non vide n'est donc pas une preuve de fichier disponible.

Les logs prouvent des lectures de médias Hub manquants et des POST HTTP 200, mais ne contiennent ni action multipart, ni corps JSON, ni ID numérique média/consentement, ni sélection/prévisualisation navigateur. Premier ajout versus remplacement historique : **non déterminable individuellement**. Les deux petites réponses 393/396 octets sont compatibles avec l'upload, sans en constituer la preuve. La disparition exacte est établie par reproduction du writer, pas par une assimilation des POST aux uploads.

Chronologie : le nom fixe du writer apparaît dans Global **154137f, 31/07/2026 10:30:35 +0200**. Les commits Games Remote du 04/09 à 12:27:37, 16:29:52, 16:59:19 et 19:45:57 encadrent les observations (18:57/19:00). Les dates de commits ne sont pas des heures de déploiement ; aucun lien causal Remote démontré. Aucun rollback Remote.

## Parcours exécuté et diagnostic

| Étape | Preuve code / observation |
| --- | --- |
| Entrée et sélection | `app_hub_play_ajax.php` → helpers ; handlers `podiumPhotoPick` et `podiumPhotoReplace` appellent le même `ensurePodiumPhotoInput()`, remise à zéro de `input.value`, puis `click()` |
| Prévisualisation/consentement | `FileReader` → `podiumPhotoDraftPreview`, `renderIdentityPhotoEditor`, checkbox obligatoire dans `submitPodiumPhoto`. Les polls ordinaires conservent fichier, draft et consentement tant que l'accès reste éligible ; test JS exécuté. Annulation native sans fichier n'envoie rien ; annulation du draft revient à la photo active |
| Requête | `apiFormData` POST sur l'URL Hub Play courante, credentials same-origin, `action=player_podium_photo_upload`, identité locale/cookies, `session_id`, `consent_granted=1`, texte/version, `files_img[]` |
| Erreurs HTTP | Avant patch, un 400/403 jetait `HUB_HTTP_n` avant lecture JSON : motif métier perdu. Désormais lecture JSON et conservation du code ; 413 non JSON explicite |
| Autorisation | `games_hub_handle_play_action` résout l'identité active et `games_hub_play_identity_photo_access` lit le rang agrégé canonique ; 403 hors Top 3. Session et mapping vérifiés comme contexte de traçabilité. Le writer Global reçoit cette preuve interne, pas un rang navigateur |
| Média | `app_games_hub_player_podium_photo_upload` → `upload` → `upload_traiter`. Chaque upload INSERT un nouveau `medias_images`, mais le nom fourni était toujours `hub-player-H-P-podium-active.ext` ; `rename` écrase le même chemin |
| Persistance/suppression | Le writer change `hub_photo_media_id`, puis `app_session_results_media_delete(old_id)` fait `unlink` du nom de l'ancien média, **identique au nouveau**. Premier ajout sans ancien média réussi ; remplacement de même extension : référence nouvelle présente, fichier supprimé |
| Faux succès possible | Upload refusé par le helper sans nouvelle ligne : l'ancien SELECT par nom fixe pouvait retrouver le média précédent et renvoyer un succès. Autre faille : résultat SQL de l'écriture active non contrôlé |
| Lecture/rendu | `app_games_hub_player_active_photo_get` → `app_session_results_podium_photo_src_from_media` peut renvoyer une URL de fallback non accessible. Le succès alimente `podiumPhotoThumb.src`, les lectures suivantes relisent la même référence cassée. Pas une preuve de cache |
| Poll concurrent | Une réponse commencée avant l'upload pouvait réinjecter l'ancien `player_access` après sa confirmation. Test JS de réponse retardée ; garde local de génération **photo uniquement**. Le poll et le reste de sa projection restent inchangés |
| Master | `games_hubs.date_maj` reste mis à jour ; inclus dans `games_hub_preparation_revision`, puis refresh partiel existant. Global enrichit podium agrégé et podiums de session via la photo active. Propagation réelle navigateur à recetter |

Classification : fichier non prévisualisé historiquement **non trouvé** ; upload non envoyé historiquement **non trouvé** ; référence non persistée historiquement **non trouvé**, mais échec SQL désormais traité ; référence correcte/fichier inaccessible **reproduit** ; réinjection d'état ancien **possible et couverte par test de réponse retardée**, non établie dans la recette historique.

## Correctif et vérifications

- Nom aléatoire unique par tentative ; stockage et traitement historique 900×900/90 conservés. Nouveau média/fichier valide contrôlé avant consentement et bascule ; ancien média supprimé seulement après écriture active réussie.
- Écriture conditionnée à l'ancien ID actif pour ne pas écraser un remplacement concurrent ; échec SQL/exception/conflit → `PHOTO_PERSIST_FAILED`, suppression du seul candidat, ancienne photo conservée. Ni transaction ni migration ajoutée.
- UI : JSON d'erreur exploitable, succès uniquement après réponse confirmant média et source ; protection des réponses photo périmées ; FileReader tardif ignoré après annulation, erreur de lecture visible.
- Test rouge avant patch : `hub_photo_replace_test.php` réussit le premier ajout puis échoue sur « replacement A -> B file survives old-media unlink ». Utilise le vrai writer, le vrai `upload_traiter` (INSERT/rename) et le vrai delete/unlink ; transport multipart, SQL et transforms image remplacés par doublures ; fichiers temporaires réels.
- Après patch : premier ajout, A→B→C même extension, URL distincte, une photo active, refus upload/fichier, fichier absent, consentement, écriture SQL/exception/conflit, rang 4 et absence de fichier ; lectures répétées. Test JS : sélection/prévisualisation/consentement conservés sur polls, annulation, A→B→C, poll ancien ignoré, erreurs JSON 400/403 et 413 non JSON visibles. Ce sont des tests de fonctions avec DOM simulé, pas une recette navigateur/BDD réelle.
- Tests existants : contrats Games `hub_probable_play_contract_test.php`, `hub_session_settings_test.php` (inclut DOM), Global `hub_players_stats_projection_contract_test.php` ; assertions statiques DOM adaptées à la signature avec génération photo. Lints PHP et diff-check.

Recette navigateur restante (DEV après mise à disposition des fichiers) : ouvrir Hub Play avec une identité Top 3 et Hub Master/podium session dans d'autres fenêtres ; ajouter A, consentir, vérifier POST 200 `ok:true`, nouvelle référence/URL et GET image 200 ; remplacer B puis C ; attendre au moins cinq polls (≈18 s), recharger Play et vérifier C ; constater la propagation aux podiums ouverts sans reload manuel ; annuler, essayer un fichier refusé/volumineux, vérifier ancienne photo intacte et erreur ; sortir du Top 3, forger le même POST et vérifier 403 `PLAYER_NOT_IN_HUB_TOP3`, sans suppression de C. Conserver Network (POST/action/status/JSON, GET image) et console en cas d'écart. Aucun ajout d'instrumentation serveur nécessaire pour prouver la cause reproduite.

Limites : source serveur non comparée, pas de déploiement ni écriture BDD réelle, aucun ancien fichier perdu restauré. Les médias déjà supprimés physiquement nécessitent un nouvel upload après correctif. La propagation Master conserve la révision existante à la seconde ; deux confirmations dans une même seconde ne sont pas validées ici. Rollback : retirer seulement les diffs photo de cette passe ; les noms uniques déjà stockés restent lisibles par le resolver existant.
