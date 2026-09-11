# Branding Hub — synchronisation et footer Play — 2026-09-07

## Statut

Audit ciblé suivi d’un patch local autorisé. Aucun déploiement, accès DB, SSH ou navigateur DEV/PROD. Les correctifs « Lancer un test », validés en DEV dans la note dédiée, et les travaux préexistants sont conservés. Recette navigateur de ce branding encore à effectuer.

## Sources raw et périmètre

Préflight rechargé : [START main](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md), sections « Statut actuel » et « Comparer develop vs main » ; [SITEMAP.txt develop](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt), « Repos » ; [manifest raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), « Update triggers ». Les README Games/Global/Pro référencés ont été relus en raw main et develop ; leurs différences ne constituent pas une preuve de déploiement.

Contrats invoqués :

- [Pro README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md), « Etat 2026-07-17 - Dashboard soirée/événement: personnalisation unifiée » et « Etat 2026-07-23 - Dashboard personnalisation: actions design locales et design compte » : séparation publication/branding, stockage explicite du design Hub dans general_branding, cascade et médias.
- [Global README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md), « Etat 2026-07-17 - Branding Hub soirée », « Update 2026-07-26 - Branding Canvas Hub: fallback Cotton complet hors logo » : resolver canonique, couleurs/police/visuel Cotton, absence de logo Cotton ajouté par défaut.
- [Games README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/games/README.md), « 2026-07-31 — Hub Play: branding live » : current_player/active_launched_session exposent hub_branding ; application CSS, police, visuel, logo, titre et méta ; invalidation des images par révision.
- Même Games README raw, « Update 2026-08-25 - Hub Remote UI mobile-first » et « Update 2026-08-25 - Hub Remote bootstrap sélection et police » : snapshot métier avec hub_branding, bootstrap initial et rendu Remote existant.
- [Pro README raw](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md), « Etat 2026-03-16 — Design reseau: la page branding TdR est maintenant une vraie experience dediee », paragraphe « correctif de relecture » : URLs médias versionnées par modification du fichier.

Contrat raw imposant déjà un footer logo avant inscription, ou un signal branding dans la révision légère Remote : **non trouvé**. Ce sont les extensions locales demandées ici, documentées dans les README locaux.

Le [journal AI Studio raw fourni](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb) a été relu avant patch : HTTP 200, Markdown extrait de la variable raw de l’enveloppe, sections « EN COURS », « TODO » et travaux livrés ; dernière entrée 28/08. Aucun chemin Hub ciblé modifié hors workspace n’y est identifié. Aucun écart concret ne justifie un rechargement ; ce constat ne certifie pas l’identité binaire des fichiers servis.

Inventaire vérifié dans Pro : `web/ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php` propose `branding_visuel`, `branding_logo`, `color_background_1`, `color_background_2` ; `ec_start_sessions_day_personalization_helpers.php` conserve aussi les données de police héritées lors du save et les intentions médias clear/cotton. La police est une donnée déjà consommée, pas un nouveau contrôle ajouté au dashboard. Nom/méta/lieu viennent du contexte Hub/publication et restent transportés par le payload existant, sans introduire un champ éditorial de branding.

| Élément existant | Master | Play | Remote |
|---|---|---|---|
| Visuel effectif / fallback Cotton | Visuel central | Bandeau intégral | Pas de couverture dans le design Remote actuel : aucun visuel ajouté |
| Logo effectif, vide autorisé | Bloc Lots | Footer partagé avant/après inscription | Logo compact existant |
| Deux couleurs / contraste | Variables CSS | Variables CSS | Variables CSS |
| Police héritée, URL existante | CSS et stylesheet | CSS et stylesheet | CSS et stylesheet |
| Titre/méta/lieu existants | Rendu du contexte Hub | En-tête existant | En-tête et localisation existants |

## Mécanismes et causes établies

La source commune est `app_games_hub_branding_get` dans Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php`, qui applique la cascade existante puis les defaults Cotton. Le view-model Games et `games_hub_play_branding_payload` projettent cette source sans créer de branding ni modifier focus ou présentation.

**Master** : `games_hub_preparation_revision` hache notamment le branding complet. Le poll `preparation_revision` détecte les changements, recharge le HTML puis met à jour les fragments sélectionnés ; `syncBranding` copie le style, titre, méta et visuel, et le bloc Lots transporte le logo. Ce n’est pas un reload global du navigateur. Le patch complète le lien de police et évite de réassigner un src central inchangé.

**Remote** : le contrôle léger utilise `app_games_hub_remote_business_revisions_get`. Son empreinte de préparation ne contenait que Hub/sessions/settings/lots, pas le branding effectif. Une écriture general_branding ou un remplacement de fichier ne change pas nécessairement ces données. `businessRevisionChanged` ne déclenchait donc pas `business_snapshot`, bien que celui-ci expose déjà hub_branding et que `syncHubBranding` fonctionne. Le patch intègre l’empreinte canonique de branding dans la préparation existante ; aucun nouvel endpoint, intervalle, champ de révision ou canal de navigation.

**Play avant inscription** : current_player synchronisait au chargement, mais showBefore ne démarrait pas de poll de branding. Le compteur périodique ne démarrait qu’après inscription. Le logo était en outre à l’intérieur du panneau ready masqué. Le patch démarre la boucle de compteur existante également depuis showBefore ; cette requête demande `include_branding=1` uniquement sans identité. Le handler expose alors le payload existant en chargeant client/sessions/branding, sans agrégats joueur. La réponse ne met à jour que compteur et branding, sans rappeler showBefore, réécrire le pseudo, les cookies ou l’identité. Si une inscription a abouti entre-temps, cette ancienne réponse ne réapplique pas son branding.

**Play après inscription** : le code local possédait déjà la chaîne `active_launched_session` → hub_branding → syncHubBranding, avec son contrôle des réponses obsolètes. L’audit ne prouve donc pas une absence générale de ce mécanisme dans l’état inscrit. Cette voie est conservée et vérifiée localement ; le symptôme global de recette ne doit pas être transformé en cause supplémentaire acquise. La révision d’image auparavant liée à toute la préparation est désormais limitée au branding ; suppressions de src/logo et nettoyage du stylesheet vide sont explicitement traités.

## Cache et footer

Les fichiers logo/visuel canoniques sont relus par `app_general_branding_asset_versioned_url` dans `global/web/app/modules/general/branding/app_branding_functions.php` : `v=filemtime`. Un remplacement au même chemin avec mtime modifié produit une nouvelle URL effective, change l’empreinte et déclenche l’actualisation. Play/Remote conservent le cache-buster `hub_revision`, maintenant stable tant que le branding ne change pas. Les src sont comparés avant écriture : pas de rechargement des images à chaque poll ni lors d’un changement de session seul.

Limite du mécanisme existant : le mtime a une granularité d’une seconde ; un remplacement externe préservant exactement le mtime et toutes les données exposées n’offre aucun signal observable. Le patch ne modifie pas le versionneur commun aux interfaces historiques, hors périmètre ; le test couvre le cas normal du même chemin avec version de fichier modifiée.

Un seul footer logo est placé hors du panneau ready, toujours dans la section Play. Les sélecteurs, source, opacité, dimensions `max-width:min(150px,48vw)` / `max-height:42px` et styles responsive existants sont conservés. Sans logo : wrapper hidden/display:none, aucun src vide ni espace réservé. Ajout et suppression restent possibles pendant la saisie sans reconstruction du formulaire.

## Fichiers et validations locales

Fonctionnels :

- Games `web/modules/app_hub_view_helpers.php` : poll compteur optionnel, révision branding stable, footer partagé, mutations DOM ciblées Master/Play.
- Games `web/modules/app_hub_remote_ajax.php` : nettoyage du logo supprimé et du stylesheet vide, état des commandes/routage inchangé.
- Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php` : empreinte branding dans la préparation Remote.

Aucune modification Pro ni interface historique de jeu. Les trois fichiers contiennent éventuellement des changements antérieurs autorisés ; ils ne doivent pas être remplacés par une copie HEAD pour livrer ou annuler cette passe.

Tests exécutés depuis chaque repo :

~~~text
Games php web/tests/hub_branding_sync_test.php — OK
Games node web/tests/hub_branding_sync_test.mjs — OK
Games php web/tests/hub_remote_master_ux_test.php — OK
Games node web/tests/hub_remote_polling_test.mjs — OK
Games node web/tests/hub_remote_return_execution_test.mjs — OK
Games php web/tests/hub_demo_readiness_flow_test.php — OK
Games node web/tests/hub_demo_player_presentation_test.mjs — OK
Global php web/tests/hub_client_routing_canonical_test.php — OK
Games php web/tests/hub_demo_runtime_surfaces_test.php — mêmes 3 ÉCHECS QR/notice préexistants
~~~

Le test PHP exécute les vrais producteurs de payload et de révision, avec frontières DB/branding isolées ; il vérifie changements branding seuls, stabilité hors branding, options de chargement, fallbacks et le versionneur réel sur fichier temporaire. Le test JS exécute les fonctions DOM/poll réelles : lifecycle logo, couleurs/police/visuel, absence de src réassigné sans changement, saisie/selection/identité/commande conservées, requête unique en vol et réponse retardée après inscription. Structure et dimensions du footer vérifiées localement ; rendu effectif mobile/desktop non visualisé. Lints PHP des trois fichiers et diff check : OK. Aucun test ou correctif QR opportuniste.

## Recette navigateur DEV restante

1. Ouvrir le dashboard Pro, Master, Remote et deux Play du même Hub : un inscrit, un sur le formulaire. Saisir un pseudo sans le soumettre ; noter sa sélection et l’identité de l’autre onglet.
2. Dans Design, ajouter un logo et modifier le visuel/les deux couleurs. Attendre les polls existants (jusqu’à 15 s sur le formulaire). Vérifier les éléments du tableau sur les trois surfaces sans reload ; pseudo et identité conservés.
3. Remplacer logo/visuel au même chemin : vérifier nouvelle version `v`, puis nouveaux médias. Après stabilisation, attendre deux polls et vérifier qu’ils ne rechargent pas à nouveau sans changement.
4. Supprimer le logo, revenir au design Cotton : logo absent sans espace vide, visuel/couleurs/police effectifs conformes au fallback. Réajouter le logo pendant la saisie ; inscrire le joueur et vérifier le même footer.
5. Vérifier le footer en mobile et desktop : largeur bornée, hauteur ≤42 px, aucune déformation ni espace réservé sans logo.
6. Avec une commande Remote en cours, modifier le branding puis contrôler son état, la sélection et le routing normal. Les changements de branding ne doivent pas modifier focus/présentation. Vérifier aussi une nouvelle démo annexe et son retour, déjà validés avant cette passe.

Aucun SQL indispensable à ce correctif. Les limites réseau/caches réels, performance du resolver dans le contrôle Remote et rendu visuel sont à confirmer en DEV. Aucun déploiement effectué. Rollback : retirer seulement les hunks branding/footer et les deux tests de cette passe ; préserver les correctifs de démo et les autres travaux, aucun rollback DB.
