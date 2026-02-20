# Handoff — Bibliothèque Pro

Date: 2026-02-20  
Scope: `pro` bibliothèque (`ec_bibliotheque_lib.php` + editor/sources/start) et `www` cron (`cron_routine_bdd_maj.php`).

## Update 2026-02-20 — Builder Quiz: CTA fiche sans modale + redirection liste
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- Actions réalisées:
  - fiche Quiz (`view`):
    - bouton `Créer un Cotton Quiz` renommé en `Utiliser cette série`
    - suppression du flux modale pour ce CTA (retrait du hook `js-quiz-program-form` en contexte Quiz)
    - clic branché en `content_library_quiz_builder_add` (idempotent) avec `return_url` vers liste en `builder=1`
  - liste Quiz (`list`) — bloc builder:
    - titre mis à jour: `Compose ton quiz (X / 4 séries max.)`
    - sous-titre dynamique explicite:
      - `Tu peux ajouter N série(s) supplémentaire(s) si tu le souhaites...` (quand `X<4`)
      - `Ta sélection est complète.` (quand `X=4`)
    - bouton principal renommé `Valider` (action continue inchangée)
    - boutons builder empilés verticalement, alignés à droite et centrés verticalement (`Valider` puis `Annuler`)
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## Update 2026-02-20 — Signalement contenu (Cotton/Communauté) en page view
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- Actions réalisées:
  - ajout d’un bouton d’action rouge en header du bloc `Contenu de la série/playlist`:
    - libellé: `Signaler un problème sur cette playlist/série` (dynamique selon le jeu)
    - affiché uniquement sur les vues `type=cotton` et `type=community`
  - ajout d’une modale de signalement avec motifs:
    - `Contenu inapproprié`
    - `Erreurs dans le contenu` (champ détail obligatoire)
    - `Autre raison` (champ détail obligatoire)
  - ajout d’un traitement backend `mode=content_library_report_issue`:
    - validation des paramètres (type, jeu, contenu, motif, détail conditionnel)
    - envoi d’un mail à `contact@cotton-quiz.com` via `mail_send` (fallback `mail`)
    - inclusion du contexte dans le mail (jeu, type, id/nom contenu, URL view, reporter)
  - gestion d’erreur utilisateur via `?error=...` sur la même page de retour
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK

## Update 2026-02-20 — Ajustement UI signalement (placement + modal)
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - bouton `Signaler un problème...` déplacé en bas du bloc contenu (série/playlist), plus dans le header
  - bouton revenu au style standard `clib-meta-action-btn` (suppression variante rouge)
  - modale: bouton `Annuler` passé en `btn-outline-color-20` (contraste corrigé)
  - modale: champ de précision affiché en permanence (même pour `Contenu inapproprié`) avec libellé fixe:
    - `Précise les contenus qui posent problème`
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — Signalement: envoi via logique Contact CRM + bouton Envoyer harmonisé
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- Actions réalisées:
  - bouton modal `Envoyer` aligné sur la couleur standard (`btn-color-20`)
  - abandon du flux d’envoi direct `mail_send/mail()` pour le signalement bibliothèque
  - réutilisation de la logique du module contact EC via `crm_contact_ajouter(...)`:
    - persistance `crm_contacts`
    - envoi admin via template Brevo existant (même chaîne que `/extranet/support/script`)
  - message signalement enrichi avec:
    - nom/prénom du contact expéditeur
    - compte client (`client_nom` + `id_client`)
    - thématique concernée (nom + ID + URL)
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK

## Update 2026-02-20 — Fix redirection après signalement
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- Actions réalisées:
  - après envoi réussi du signalement, redirection forcée vers la page view de la thématique signalée (au lieu d’un fallback liste)
  - URL de retour appliquée: `.../extranet/games/library/<seo_slug>/<id>?type=<cotton|community|mine>`
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK

## Update 2026-02-20 — Signalement: pas de redirection, modale de remerciement
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- Actions réalisées:
  - retour à la logique d’envoi mail direct initiale (`mail_send` puis fallback `mail`) dans le mode `content_library_report_issue`
  - ajout d’un mode réponse JSON pour les submit AJAX de signalement
  - submit de la modale signalement passé en AJAX (`fetch`)
  - suppression de la redirection post-submit: la page courante reste affichée
  - ajout d’une modale de confirmation `Merci pour ton signalement` affichée après succès
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — View: aperçu audio aligné à droite (desktop + mobile)
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - alignement des boutons d’aperçu audio inline à droite dans les lignes de contenu (quiz + playlists)
  - ajout de classes dédiées (`clib-content-question-row`, `clib-content-question-text`) pour maîtriser l’alignement côté questions
  - compat mobile:
    - texte passe sur 1re ligne
    - bouton d’aperçu reste aligné à droite sur la ligne suivante
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — View: alignement à droite de tous les aperçus supports
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - extension de l’alignement droite aux aperçus image/vidéo/lien (pas seulement audio)
  - rendu quiz: aperçu support (image, vidéo YouTube, vidéo fichier, lien fallback) intégré sur la ligne de contenu avec alignement droite
  - rendu playlists: fallback `Aperçu indisponible` repositionné inline à droite
  - maintien compat mobile (retour à la ligne propre, bloc aperçu conservé à droite)
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — View: taille miniature vidéo YouTube rétablie
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - augmentation du bloc inline vidéo (YouTube + fichier vidéo) vers largeur fixe 220px pour retrouver la taille précédente
  - maintien du comportement responsive mobile (max-width 220px, largeur fluide sur petit écran)
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — View: mention vidéo conservée + alignement mobile à gauche
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - restauration de la mention d’aide sur l’aperçu vidéo:
    - `Extrait 10s (en jeu, les joueurs ne voient pas le titre de la vidéo)`
  - ajustement responsive:
    - quand les supports passent à la ligne sur mobile, ils s’alignent à gauche (et non à droite)
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — List mobile: onglets source sur une ligne
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- Actions réalisées:
  - ajout d’une règle responsive mobile pour conserver les onglets `Cotton / Communauté / Perso` sur une seule ligne
  - adaptation mobile: `nowrap`, largeur partagée (`flex:1`), padding/typo réduits
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## Update 2026-02-20 — List mobile: libellés onglets raccourcis
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- Actions réalisées:
  - ajout de libellés dédiés mobile pour les onglets source:
    - `Cotton`
    - `Communauté`
    - `Mes playlists` / `Mes séries` (selon le jeu courant)
  - affichage desktop inchangé (libellés complets)
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## Update 2026-02-20 — View: bouton signalement exclu des contenus perso
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - renforcement de la condition d’affichage du bouton `Signaler un problème...`:
    - visible uniquement pour `type=cotton|community`
    - explicitement masqué si le contenu est perso (`$is_mine_item`)
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — Création bibliothèque: image par défaut auto
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_save.php`
- Actions réalisées:
  - ajout d’un helper de post-création pour copier automatiquement une image par défaut sur les thématiques perso créées depuis la bibliothèque:
    - Quiz: `default_cotton_quiz.jpg` -> `<id>.jpg` dans `questions_lots`
    - Playlist (Bingo/Blind): `default_playlist.jpg` -> `<id>.jpg` dans `playlists`
  - fallback de chemin legacy prévu si source non trouvée avec `upload_dir` courant
  - application exécutée juste après création `new_id`
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_save.php` OK

## Update 2026-02-20 — Menu EC `Les jeux`: clic portail + sous-menu auto
- Scope code:
  - `pro/web/ec/ec.php`
- Actions réalisées:
  - clic sur `Les jeux` redirige vers le portail `/extranet/games/library` (hub)
  - sous-menu jeux conservé en ouverture automatique quand l’utilisateur est dans la bibliothèque
  - objectif: éviter l’effet “menu bloqué” tout en gardant la navigation rapide entre jeux
- Vérification:
  - `php -l pro/web/ec/ec.php` OK

## Update 2026-02-20 — Admin: statut `Non publiée` en liste (rollback view)
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - rollback de l’affichage méta `partagée oui/non` ajouté précédemment dans `view`
  - ajout d’un marquage temporaire en `list` pour admin (`id_client=10`) via le bandeau jaune existant:
    - libellé: `Non publiée`
    - condition: onglet `Communauté` + contenu perso auteur (`id_client_auteur>0`) + `flag_share_community!=1`
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — Fix affichage bandeau admin `Non publiée`
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- Cause:
  - `flag_share_community` non sélectionné dans la requête `clib_list_get(...)`, condition UI toujours fausse côté liste
- Correctif:
  - ajout de `c.flag_share_community` dans les champs sélectionnés de la liste (Quiz + Playlists quand colonne disponible)
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## Update 2026-02-20 — View: usage déplacé sous titre/sous-titre
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - retrait des lignes méta `Jouée: x fois` / `Jamais jouée` / `Dernière utilisation`
  - affichage usage aligné carte list, juste sous le descriptif:
    - `Jouée x fois - dernière: ...` (affiché uniquement si `usage_count > 0`)
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — View: actions thématique déplacées dans le bloc méta
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - retrait des boutons icônes `modifier/supprimer la thématique` en haut de fiche
  - ajout dans le bloc des infos méta de:
    - `Modifier les infos`
    - `Supprimer la playlist` (ou `Supprimer la série` en mode Quiz)
  - style harmonisé avec le lien `Modifier le contenu` (`clib-content-edit-toggle`)
  - section contenu inchangée: `Modifier le contenu` conservé
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — View: toggle `Modifier le contenu` en bouton icône
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - remplacement du bouton texte `Modifier le contenu` par un bouton icône (même style que les actions méta)
  - tooltip dédié dynamique:
    - Quiz: `Modifier la série`
    - Playlist: `Modifier la playlist`
  - comportement inchangé: le bouton ouvre l’édition et permet aussi de la refermer (toggle existant conservé)
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — Partage communauté via méta (tous jeux), retrait bypass admin dédié
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `pro/web/ec/modules/jeux/bibliotheque/sources/quiz_series.php`
  - `pro/web/ec/modules/jeux/bibliotheque/sources/playlists.php`
  - `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_edit.php`
  - `pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_save.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - suppression du mode script dédié `content_library_admin_quiz_share_toggle`
  - suppression du CTA bypass admin `Publier/Retirer communauté` en fiche view
  - ajout du paramètre méta `Partager ce contenu avec la communauté Cotton` dans l’éditeur `t_theme_edit` (Quiz/Bingo/Blind)
  - persistance du flag de partage en save méta (`content_library_theme_save`) via `flag_share_community` + `share_community_text_version`
  - sync communauté alignée après save méta:
    - partage activé: sync/publish via flux standard
    - partage désactivé: masquage communauté (`community_items.status='hidden'`)
  - maintien du bypass owner-check admin existant (`id_client=10`) sur l’édition méta/contenu
- Vérifications:
  - `php -l` OK sur tous les fichiers PHP modifiés (script/lib/sources/editor/view)

## Update 2026-02-20 — Menu EC “Les jeux” avec sous-navigation directe
- Scope code:
  - `pro/web/ec/ec.php`
- Actions réalisées:
  - transformation de l’entrée sidebar `Les jeux` en menu déroulant (collapse)
  - ajout de 3 accès directs sans retour portail:
    - `Blindtest` -> `/extranet/games/library?game=blindtest`
    - `Bingo musical` -> `/extranet/games/library?game=bingo`
    - `Cotton Quiz` -> `/extranet/games/library?game=quiz`
  - état actif géré côté menu via `game` et fallback `seo_slug_jeu` (`blind-test`, `bingo-musical`, `cotton-quiz`)
  - ouverture automatique du sous-menu quand l’utilisateur est dans la bibliothèque (ou dans le tunnel avec contexte `from=library`)
- Vérification:
  - `php -l pro/web/ec/ec.php` OK

## Update 2026-02-20 — UI Builder Quiz (liste + fiche)
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Objectif:
  - conserver une seule action principale par carte en liste (`Voir le détail`)
  - préserver l’ajout rapide de séries en mode builder Quiz
- Actions réalisées:
  - liste (`builder=1`): remplacement du bouton plein format `Ajouter/Retirer` par une action secondaire discrète en top-right (`+` / `✓`) avec tooltip et état disabled si sélection pleine (4/4)
  - fiche série: CTA explicite `Ajouter au quiz`, état `Déjà ajoutée`, et action secondaire `Retirer`
  - flux inchangé: popup `Créer mon jeu` puis bascule vers la liste en mode builder, endpoints builder existants inchangés (`content_library_quiz_builder_*`)
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
- Docs mises à jour:
  - `documentation/canon/repos/pro/TASKS.md`
  - `documentation/canon/repos/pro/README.md`

## Update 2026-02-20 — UX Builder (microcopy + limite)
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- Actions réalisées:
  - bandeau builder: titre `Mon Quiz`, compteur `x / 4 séries`, micro-aide (`Ajoute des séries depuis la liste (icône +) ou directement depuis le détail de chaque série.`)
  - liste builder: si sélection pleine (`4 / 4`), icône `+` désactivée avec tooltip `Limite atteinte`
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## Update 2026-02-20 — View: encart unique Programmer/Démo
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - ajout d’un encart unique en haut de la fiche (hors mode builder Quiz) avec:
    - `Utiliser cette playlist/série :`
    - CTA primaire dynamique `Créer un <jeu>`
    - CTA secondaire `Lancer une démo`
    - micro-aide d’usage
  - suppression des anciens boutons dispersés en bas de fiche pour éviter les doublons visuels
  - placement ajusté dans la vue: header+métas -> encart d’usage -> détail contenu
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — View: rollback CTA inline + popup Quiz
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - suppression de la section dédiée “Utiliser cette playlist/série :”
  - CTA `Créer un <jeu>` + `Lancer une démo` réintégrés inline dans l’UI
  - phrase d’aide conservée: `Crée une session avec cette playlist/série, ou lance une démo pour tester rapidement.`
  - Quiz: popup de choix d’ajout d’autres séries conservée (hook `js-quiz-program-form` inchangé)
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — Fix popup Quiz depuis view
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Problème:
  - clic sur `Créer un Cotton Quiz` depuis `view` sans affichage de la popup de choix d’ajout de séries
- Cause:
  - initialisation de la modale exécutée avant présence du noeud modal dans le DOM
- Correctif:
  - init modal lazy au submit (`ensureModalReady`) + binding d’événements au premier usage
  - fallback conservé vers `content_library_quiz_builder_start` si modal indisponible
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — View contenu: preview audio inline + alternance lignes
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - bouton preview audio réduit et déplacé inline sur la ligne question/morceau
  - suppression du texte `Support : Audio/Vidéo/Image` en mode lecture
  - alternance visuelle une ligne sur deux via fond gris léger (`is-alt-row`)
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-20 — Liste: statut transitoire en bas de carte
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- Actions réalisées:
  - ajout d’un statut visuel en bas des cartes `mine` non programmables:
    - `Série à compléter`
    - `Série à valider`
    - `Playlist à valider`
  - placement: à l’intérieur de la carte, en bas du contenu (`card-body`), au-dessus du footer `Voir le détail`
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## Update 2026-02-20 — Communauté: exclusion des contenus de l’auteur
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- Actions réalisées:
  - onglet `communauté`: ajout du filtre `c.id_client_auteur <> id_client` dans:
    - `clib_list_get(...)` (liste items)
    - `clib_rubriques_filtered_get(...)` (liste rubriques)
  - effet: un contenu perso partagé en communauté n’est plus visible dans l’onglet communauté de son auteur
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK

## Décision appliquée
- Abandon de la logique de rotation/versioning/archivage/clone source.
- Règle unique:
  - contenu perso non utilisé par session future/en cours => edit/delete inchangés
  - contenu utilisé => edit/delete refusés avec `CONTENT_LOCKED_IN_USE`

## Actions réalisées
- Rollback versioning source:
  - suppression helpers schema/versioning/rotation dans `ec_bibliotheque_lib.php`
  - suppression redirections “nouvel ID/versioned” dans:
    - `editor/p_theme_save.php`
    - `editor/p_theme_content_ajax.php`
  - suppression filtres `published` injectés par patch dans listing/sélection:
    - `ec_bibliotheque_lib.php`
    - `sources/quiz_series.php`
    - `sources/playlists.php`
    - `sources/quiz_series_content.php`
    - `sources/playlists_content.php`
  - suppression garde-fou `status` ajouté dans `start`:
    - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - suppression purge archives dans cron:
    - `www/web/bo/cron_routine_bdd_maj.php`
  - migration versioning conservée en legacy (non utilisée dans le flux courant):
    - `pro/web/ec/modules/jeux/bibliotheque/scripts/archive_versioning_migration.sql`
- Implémentation verrou backend “in use”:
  - ajout détection usage sessions futures/en cours (count):
    - Quiz: `id_produit` + `lot_ids` (`id_type_produit IN (1,5)`)
    - Bingo: `id_produit -> jeux_bingo_musical_playlists_clients.id -> id_playlist` (`id_type_produit IN (3,6)`)
    - Blindtest: `id_produit` (`id_type_produit=4`)
    - Communauté: `community_item_id -> community_items.id -> source_id`
    - filtre commun: `flag_session_demo=0`, `flag_configuration_complete=1`, `date>=CURDATE()`
  - blocage branché sur:
    - update meta
    - delete meta
    - add/remove/move/update_item contenu
  - règles appliquées:
    - usage par un autre client: blocage edit/delete
    - usage par le créateur uniquement: blocage edit/delete + invitation à supprimer sa session
  - retour erreur métier:
    - `code=CONTENT_LOCKED_IN_USE`
    - message utilisateur contextualisé selon le cas (`autre client` vs `tes sessions`)
  - logs:
    - `CONTENT_EDIT_BLOCKED`
    - `CONTENT_DELETE_BLOCKED`
    - meta: `content_type`, `content_id`, `reason`, `session_count`, `owner_session_count`, `other_client_session_count`
- UX préventive ajoutée (fiche bibliothèque):
  - `Modifier` et `Supprimer` passent par un precheck AJAX (`content_library_theme_precheck`) au clic
  - si bloqué: message d’alerte immédiat, sans lancer la mutation backend
  - `Modifier le contenu` (toggle édition in-page) passe aussi par ce precheck avant ouverture
- UX d’explicitation ajoutée (fiche owner):
  - badge “en cours d’utilisation par X client(s)” affiché quand la thématique est utilisée (sessions futures/en cours hors démo)
  - `X` calculé sur clients distincts (`championnats_sessions.id_client`)
  - variante “ton agenda” si usage créateur uniquement (sans autre client)
  - actions `Modifier` / `Supprimer` / `Modifier le contenu` masquées tant que verrou actif
- Communauté:
  - sync `community_items` sur mutation owner en update in-place (sans archive/new published)
  - suppression source autorisée => item communauté en `hidden`
  - correctif visibilité: listing `community` applique aussi `flag_share_community=1` (et validé), y compris quand la source est jointe via `community_items`
  - compat legacy ajoutée sur la visibilité communauté:
    - Quiz: `id_etat=2`
    - Playlists: `online=1`
    - logique finale: `(règle courante) OR (legacy public)` + `EXISTS community_items.published`
  - alignement DB legacy:
    - `rebuild_community_items_legacy.php/.sql` synchronisent aussi `flag_share_community=1` pour les contenus perso legacy déjà publiés en communauté
    - objectif: aligner les métas fiche avec la visibilité réelle communauté
  - correctif stats d’usage: compteurs fiche/verrou incluent les sessions référencées via `community_item_id`
  - exception admin:
    - `id_client=10` peut modifier/supprimer/éditer le contenu des thématiques communauté (`id_client_auteur>0`)
    - bypass owner-check ajouté dans `sources/*` (métas + contenu)
    - verrou `in_use` inchangé (reste appliqué)
  - transition quiz legacy:
      - en onglet communauté, fallback listing legacy activé pour `id_client=10` afin d’exposer les séries clients non encore partagées
      - correctif appliqué: retrait du filtre global `id_etat=2` en mode transition admin quiz
      - nouveau mode script `content_library_admin_quiz_share_toggle` pour publier/retirer une série quiz
      - publication admin synchronise `flag_share_community` et `community_items`
  - filtres liste communauté:
    - `A la une` affiché à gauche de `Nouveautés`
    - `A la une` défini par défaut en onglet `Communauté`
    - tri utilisé: top 12 par popularité
  - filtres liste perso:
    - filtre `Nouveautés` retiré
    - filtre unique `Thèmes` (par défaut: toutes les séries/playlists)
    - tri affichage: création décroissante (plus récent -> plus ancien)
    - chip `Toutes les séries/playlists` séparé du dropdown `Thèmes`:
      - en `Cotton` / `Communauté`: positionné à droite
      - en `Perso`: positionné à gauche (état par défaut)
  - layout liste cartes:
    - titre mis à `Catalogue des playlists/séries du <jeu>` (sous-titre retiré)
    - grille densifiée à 4 cartes max / ligne sur large
    - bandeau bas léger avec CTA unique `Voir le détail`
    - accès `Créer un jeu` / `Démo` retirés de la carte liste
    - CTA `Voir le détail` restylé selon les boutons des blocs de choix jeu (portail) + icône flèche à droite
  - fiche `view` (métas contenu):
    - compteur retiré du titre `Contenu de la playlist/série` (playlist + quiz)
    - conservation du compteur `x/6` uniquement en création de série quiz (état intermédiaire)
    - ajout dans le bloc méta:
      - `X morceaux` (playlist) ou `X questions` (quiz)
      - `Durée indicative`: playlist calculée sur `30s * nb morceaux`, quiz fixé à `5 min`
    - ajustement création:
      - en mode création perso, `Questions/Morceaux` et `Durée indicative` masqués tant que le contenu n’est pas complet
      - affichage rétabli une fois complet (`>=6` questions pour quiz, contenu playlist complet/validable)
    - ajustement validation perso:
      - tant que le contenu perso n’est pas validé, masquage des métas:
        - `Playlist/Série partagée`
        - `Questions/Morceaux`
        - `Durée indicative`
    - harmonisation libellé:
      - méta `Questions/Morceaux` renommée en `Contenu` (`Contenu: X questions|morceaux`)
  - fiche `view` (image header):
    - réduction de la hauteur d’affichage (220px max au lieu de 340px)
    - conservation du format d’origine (suppression du recadrage `cover`, passage en `contain`)
    - alignement forcé à gauche (`display:block; margin-left:0; margin-right:auto`)

## Vérifications réalisées
- `php -l` OK sur tous les fichiers PHP modifiés (`pro` + `www`).

## Reste à faire (QA manuelle)
- Cas non utilisé: edit/delete OK.
- Cas utilisé (future/en cours): edit/delete refusés + message.
- Vérifier affichage UI du message d’erreur dans les parcours:
  - `p_theme_save` (redirect + query `error`/`error_code`)
  - `p_theme_content_ajax` (JSON `{success:false, code, error}`)
