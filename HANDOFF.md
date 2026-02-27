# Handoff — Bibliothèque Pro

Date: 2026-02-20  
Scope: `pro` bibliothèque (`ec_bibliotheque_lib.php` + editor/sources/start) et `www` cron (`cron_routine_bdd_maj.php`).

## Update 2026-02-27 — Pro EC bibliothèque Quiz: champ commentaire compact + aide quiz master
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_content.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - passage du champ `Commentaire` en monoligne (`input text`) sur les formulaires quiz ciblés.
  - ajout d’un retour de ligne après `Bonne réponse` avant les fausses propositions.
  - repositionnement du champ `Commentaire` sous le bloc `Fausse proposition 1/2/3`.
  - retrait de la marge `mb-2` sous la mention “Les fausses propositions sont essentielles pour la version numérique du quiz.”
  - harmonisation des blocs de boutons en `mt-4` avant validation/ajout/enregistrement.
  - ajout d’une aide inline `À l’attention du quiz master.` dans le même style `small text-muted`.
  - comportement fonctionnel inchangé: commentaire toujours facultatif.
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_content.php` OK

## Update 2026-02-27 — Pro EC bibliothèque Quiz: ordonnancement harmonisé des formulaires question
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_content.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - regroupement des champs `Fausse proposition 1/2/3` dans tous les formulaires quiz ciblés.
  - déplacement du bloc `Type support` + champs support en dernière position.
  - harmonisation des libellés (retrait des variantes `Prop.` / `Proposition`).
  - suppression du champ proposition 4 dans les formulaires quiz série perso.
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_content.php` OK

## Update 2026-02-27 — Pro EC bibliothèque Quiz: champ `Commentaire` réintégré dans les formulaires question
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_content.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - ajout du champ `Commentaire` dans:
    - création/édition de question de série perso
    - création d’une question de remplacement en lot temporaire (client/session)
    - modification d’une question de lot temporaire (admin bibliothèque)
  - préremplissage du commentaire en édition.
  - backend inchangé (validation + persistance déjà présentes).
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_content.php` OK

## Update 2026-02-27 — Bibliothèque: logique stricte “en cours” pour `A la une` / `En ce moment`
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - suppression de la fenêtre glissante “J-90 avant début” en bibliothèque.
  - `A la une` et badge `En ce moment` affichent désormais uniquement les contenus réellement dans la période active.
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## Update 2026-02-27 — Bibliothèque: fix déréférencement après édition meta admin
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_save.php`
  - `pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_edit.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - correction du flux d’édition meta admin pour ne plus forcer `flag_share_community=0` sur un contenu non-owner.
  - évite le passage involontaire de la ligne `community_items` en `status=hidden` et la disparition du contenu en liste.
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/editor/p_theme_save.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/editor/t_theme_edit.php` OK

## Update 2026-02-27 — Bibliothèque: bypass admin du lock d’usage actif
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - compte admin (`id_client=10`) autorisé à modifier/supprimer des thématiques Cotton/Communauté même si elles sont en cours d’utilisation.
  - bandeau d’information d’usage conservé en view.
  - comportement non-admin inchangé (blocage maintenu sur contenus en cours d’utilisation).
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-27 — Bibliothèque quiz: correction usage `Lots temporaires` (`T` distinct de `L`)
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - le calcul de `Jouée X fois` est maintenant typé par token quiz:
    - contenu catalogue: `L{id}` (inchangé)
    - lots temporaires: `T{id}` (nouveau mode explicite)
  - sur l’onglet admin `Lots temporaires`, les stats n’héritent plus d’usages des lots catalogue de même id numérique.
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## Update 2026-02-27 — Bibliothèque: pagination list responsive sur mobile
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - ajout d’un wrapper pagination bibliothèque pour gérer la contrainte mobile sans casser le desktop.
  - sur mobile, pagination rendue scrollable horizontalement pour éviter le débordement hors viewport.
  - sur desktop, pagination conservée centrée avec wrapping.
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## Update 2026-02-27 — Quiz `A la une` aligné: priorité “du moment” + badge
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - filtre `A la une` Quiz (`preset=now`, `Cotton`) recalé sur `jour_associe_debut/jour_associe_fin` comme les playlists.
  - badge `En ce moment` activé aussi pour les séries Quiz dans cette fenêtre.
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## Update 2026-02-27 — Bibliothèque: badge `Populaire` retiré des lots temporaires
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - exclusion de l’onglet `temp_lots` du calcul/rendu du badge `Populaire`.
  - maintien du badge sur les onglets catalogue (`Cotton`, `Communauté`, `Mes`) basés sur les stats `L`.
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK

## Update 2026-02-27 — Admin lots temporaires: `Lancer une démo` crée une session mono-lot
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - abandon du flux `session_duplicate` pour le CTA admin `Lancer une démo` en vue lot temporaire.
  - ajout d’un mode script dédié qui crée une session démo quiz puis applique uniquement le token lot temporaire `T{id}`.
  - la démo ne duplique plus les autres séries de la session source.
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK

## Update 2026-02-27 — View admin lots temporaires: retrait du badge de lock d’usage
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - suppression de l’affichage “en cours d’utilisation par X clients / modification impossible” sur la vue lot temporaire admin.
  - le lock d’usage reste actif pour les contenus catalogue standards.
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-27 — List admin lots temporaires: tri plus récent -> plus ancien
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - tri de l’onglet admin `Lots temporaires` ajusté pour afficher d’abord les lots les plus récents.
  - ordre SQL: `t.date_ajout DESC, t.id DESC`.
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK

## Update 2026-02-27 — Modale admin lot temporaire: texte lien support enrichi
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - affichage explicite du lien support question actuel dans la modale admin:
    - `Support question : {url cliquable}`
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-27 — Modale admin lot temporaire: suppression champ proposition 4
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/HANDOFF.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - suppression du champ UI `Prop. 4` (`proposition_4`) dans le formulaire d’édition admin des questions de lot temporaire.
  - alignement avec le flux de remplacement existant (3 fausses propositions visibles).
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-27 — Fix régression agenda quick Quiz papier (lots temporaires)
- Scope code:
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- Constat:
  - en agenda quick quiz papier, la génération produisait parfois `4xL` sans lots temporaires (`T`) car le payload auto transmis à `session_theme` restait multi-lots.
- Action réalisée:
  - dans `session_setting_multi`, auto-pick quiz ajusté selon le support:
    - numérique (`session_flag_controle_numerique=1`): 4 lots catalogue (inchangé)
    - papier (`session_flag_controle_numerique=0`): 1 lot catalogue
  - ce payload mono-lot réactive la régénération attendue dans `start_quiz_v2_apply_lots_to_session(...)` vers `T,T,T,L`.
- Vérification:
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_script.php` OK

## Update 2026-02-27 — Fix régression remplacement lot temporaire (clients non-admin)
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Constat:
  - le recadrage admin “Lots temporaires” avait supprimé le flux de remplacement des questions pour les clients non-admin en contexte session.
- Actions réalisées:
  - garde contexte session assouplie:
    - `clib_quiz_temp_lot_session_edit_context_get(...)` n’est plus bloquée admin-only; la règle session owner quiz papier + lot `T` lié est de nouveau active.
  - backend remplacement:
    - suppression du verrou admin-only sur `content_library_temp_lot_question_replace`.
  - split UI explicite:
    - admin onglet `temp_lots`: bouton `✎` + modal édition (`content_library_temp_lot_question_update`)
    - contexte session utilisateur: bouton `↻` + modal remplacement A/B (`content_library_temp_lot_question_replace`)
  - JS modal:
    - réactivation du toggle formulaire `B) créer/remplacer` pour le flux remplacement.
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-27 — Fix format date `jour_associe` (lots temporaires)
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- Constat:
  - `jour_associe` était écrit en `YYYY-MM-DD` alors que `questions.jour_associe` est `char(5)` (`MM-DD`), causant troncature (`2026-`) et erreurs d’assert post-insert.
- Actions réalisées:
  - ajout helper de normalisation DB `clib_quiz_jour_associe_db_normalize(...)`.
  - application de la normalisation dans les 2 flux:
    - création question de remplacement (client),
    - modification question existante (admin).
  - comparaison post-insert alignée sur le format DB normalisé.
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK

## Update 2026-02-27 — Fix réouverture modale admin lots temporaires (propositions)
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- Constat:
  - après modification d’une question, la réouverture de la modale admin n’affichait pas toujours les propositions saisies.
- Action réalisée:
  - `clib_quiz_temp_lot_questions_get(...)` enrichi pour charger `questions_propositions` et remapper les valeurs en `proposition_1..4` (ordre `ordre ASC, id ASC`).
- Vérification:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK

## Update 2026-02-27 — Bibliothèque PRO: certification admin + onglet Quiz `Lots temporaires`
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - ajout action admin `Certifier ce contenu` sur une fiche bibliothèque en onglet `Communauté`, avec backend dédié `content_library_admin_certify`.
  - promotion communauté -> Cotton sans perte d’auteur:
    - conservation `id_client_auteur` et `nom_auteur`,
    - publication source forcée (`id_etat=2` quiz, `online=1` playlists),
    - mise à jour `community_items.origin='cotton'` + publication active pour remontée côté onglet `Cotton`.
  - correctif filtre communauté:
    - après promotion Cotton, exclusion explicite des contenus promus du listing `Communauté` (y compris fallback admin) via `NOT EXISTS` sur `community_items.origin='cotton'`.
  - ajout onglet admin-only `Lots temporaires` dans la bibliothèque quiz:
    - source dédiée des lots `questions_lots_temp` auto-générés (`Série auto papier :%`) liés aux sessions quiz papier via tokens `T{id}` dans `lot_ids`.
  - maintenance des lots temporaires verrouillée admin-only:
    - UI: flux de correction visible uniquement admin,
    - backend: refus non-admin sur `content_library_temp_lot_question_update`,
    - garde lot maintenable (`Série auto papier :%` + session quiz papier liée).
  - fiche lot temporaire (contexte bibliothèque admin):
    - action par question basculée en vraie édition (`✎`) avec formulaire prérempli,
    - suppression du workflow A/B de remplacement dans cette vue,
    - CTA orienté bibliothèque: `Lancer une démo` + affichage informatif des sessions liées.
  - recadrage navigation/contexte admin bibliothèque:
    - liens d’entrée `Lots temporaires` nettoyés (sans contexte agenda/session),
    - neutralisation du bandeau session (`Série programmée...`, `Retour à la session`) en mode admin bibliothèque,
    - filtre sessions liées: exclusion des sessions démo (`flag_session_demo=0`),
    - modale d’édition: ajout d’un bloc “Support(s) actuel(s)” avec liens existants.
  - fiche session quiz V2: libellé `Voir / Modifier` conservé pour séries temporaires uniquement côté admin.
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK (post-fix filtre communauté)
- QA manuelle:
  - non exécutée dans cet environnement (à dérouler selon matrice admin/non-admin listée dans `canon/repos/pro/TASKS.md`).

## Update 2026-02-27 — Bibliothèque: bypass admin `id_client=10` étendu aux contenus Cotton
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/jeux/bibliotheque/sources/quiz_series.php`
  - `pro/web/ec/modules/jeux/bibliotheque/sources/playlists.php`
  - `pro/web/ec/modules/jeux/bibliotheque/sources/quiz_series_content.php`
  - `pro/web/ec/modules/jeux/bibliotheque/sources/playlists_content.php`
- Constat:
  - le bypass admin existant (`id_client=10`) couvrait les contenus clients/communauté via des filtres `id_client_auteur>0`, mais excluait les contenus Cotton (`id_client_auteur=0`).
- Actions réalisées:
  - extension homogène des filtres admin owner sur la stack bibliothèque:
    - `id_client_auteur>0` -> `id_client_auteur>=0`
  - alignement UI + backend:
    - affichage des actions en view (`can_manage_item`) pour les contenus Cotton
    - contrôles owner backend (load/update/delete/meta/content) compatibles Cotton pour admin
  - non-admin inchangé (filtres `id_client_auteur=<client_id>` conservés)
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/sources/quiz_series.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/sources/playlists.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/sources/quiz_series_content.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/sources/playlists_content.php` OK
- QA manuelle restant à exécuter:
  - admin (`id_client=10`) peut modifier un item `type=cotton` en view bibliothèque
  - admin conserve la capacité de modification en `type=community`
  - non-admin ne gagne aucun droit supplémentaire

## Update 2026-02-27 — Pro ciblé A→E (bibliothèque/home/agenda quiz)
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_list.php`
  - `pro/web/ec/ec.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Actions réalisées:
  - bibliothèque list: ajout du badge `En ce moment` (shape du badge `Populaire`, couleur dédiée) affiché uniquement sur les items Cotton réellement dans la période courante (`preset=now`, date courante vs `jour_associe_debut/fin`).
  - menu latéral INS/CSO:
    - INS CHR (`id_typologie 1/8`): lien `Mon agenda` visible même sans session programmée.
    - lien `Media Kit` masqué pour INS/CSO de typologie particulier/événement (`12`, `2`, `3`) et conservé sur CHR.
  - pivot `start/agenda/mode` (quiz uniquement):
    - carte 1: description mise à jour avec `4 séries de quiz populaires`.
    - carte 2: titre `Choisir mes thématiques`.
  - fiche détail agenda quiz:
    - bouton de remplacement harmonisé en `Remplacer` (quiz/playlist).
    - pour séries auto temporaires (`T{id}`) de quiz papier uniquement: bouton `Remplacer` masqué, bouton suppression conservé (si autorisé).
    - lien de détail renommé en `Voir / Modifier` dans ce cas précis.
- Vérifications:
  - `php -l` OK sur les 5 fichiers `pro` modifiés.
  - QA navigateur non exécutée dans cet environnement.

## Update 2026-02-27 — Fix remplacement série Quiz V2 (hors lot temporaire)
- Scope code:
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `HANDOFF.md`
- Constat:
  - le flux “Remplacer” envoie un payload tokenisé (`L...`/`T...`) pour préserver les slots quiz, mais `start_quiz_v2_apply_lots_to_session(...)` ne parse que des IDs numériques.
  - conséquence: `session_theme` ignore le payload dans ce cas et le remplacement d’une série quiz classique ne s’applique plus.
- Actions réalisées:
  - parsing robuste ajouté dans `start_quiz_v2_apply_lots_to_session(...)`:
    - priorité aux helpers tokens (`qz_lot_tokens_csv_normalize`) si disponibles
    - fallback regex `L/T` + fallback CSV numérique historique
  - conservation de l’ordre des tokens dans `lot_ids` et recalcul sûr de `id_produit`.
- Vérifications:
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_script.php` OK

## Update 2026-02-27 — Fix remplacement lot classique dans session Quiz V2 mixte (`T` + `L`)
- Scope code:
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `HANDOFF.md`
- Constat:
  - en session quiz papier, la régénération auto (`qz_build_paper_auto_lot_ids_csv`) s’appliquait même quand `session_theme` recevait déjà un payload mixte tokenisé.
  - conséquence: le remplacement d’un lot classique dans une session `T... + L...` était écrasé après POST.
- Actions réalisées:
  - gating de la régénération auto papier dans `start_quiz_v2_apply_lots_to_session(...)`:
    - autorisée seulement en sélection simple (pas de token `T`, au plus un token),
    - désactivée pour payloads mixtes explicites afin de conserver les slots remplacés.
- Vérifications:
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_script.php` OK

## Update 2026-02-27 — Fiche session papier: libellé impression harmonisé
- Scope code:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
  - `CHANGELOG.md`
  - `HANDOFF.md`
- Constat:
  - sur `start/game/view`, les liens d’impression papier utilisaient des libellés différents selon le jeu (`feuilles de jeu`, `grilles de jeu`, etc.).
- Actions réalisées:
  - uniformisation du texte visible sur les liens d’impression papier (tous jeux) vers:
    - `Imprimer les feuilles de réponses`
  - aucune modification des URLs/actions d’impression.
- Vérifications:
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php` OK

## Update 2026-02-27 — Fix suppression slot Quiz V2 (`L/T`) en fiche session agenda
- Scope code:
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
- Constat:
  - la suppression `session_quiz_slot_delete` parse uniquement les tokens `L...`; les lots temporaires `T...` sont ignorés, ce qui décale l’index et peut mener à une suppression complète de session.
- Actions réalisées:
  - parsing des slots basé sur tokens `L/T` (helper `qz_lot_tokens_parse` si dispo, fallback regex `([LT])(\\d+)`)
  - suppression par `slot_index` sur la liste réelle des tokens (ordre conservé)
  - reconstruction `lot_ids` avec tokens restants
  - recalcul `id_produit` sécurisé (priorité au premier `L`, fallback existant)
- Vérifications:
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_script.php` OK

## Update 2026-02-27 — Fiche session agenda Blindtest/Bingo: taille bouton `Remplacer`
- Scope code:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- Actions réalisées:
  - harmonisation visuelle du bouton `Remplacer` (playlist) avec les autres actions de la page via largeur compacte (`90px`).
- Vérifications:
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php` OK

## Update 2026-02-27 — Pro bibliothèque Quiz: filtre qualité séries (3 propositions complètes + 1 correcte)
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
- Scope doc:
  - `canon/repos/pro/TASKS.md`
  - `canon/repos/pro/README.md`
- Constat:
  - le listing bibliothèque Quiz devait appliquer un critère qualité minimum des séries avant affichage.
- Actions réalisées:
  - ajout d’un filtre SQL centralisé `clib_quiz_lot_catalog_quality_filter_sql_get(...)`:
    - série avec au moins une question,
    - pour chaque question: réponse correcte non vide + au moins 3 propositions complètes.
  - branchement du filtre dans:
    - `clib_list_get(...)` (cartes de liste),
    - `clib_rubriques_filtered_get(...)` (rubriques proposées).
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - QA navigateur non exécutée dans cet environnement.

## Update 2026-02-27 — Games: Drive timeout sémantique assouplie après premier rendu
- Scope code:
  - `games/web/includes/canvas/core/player/index.js`
- Scope doc:
  - `canon/repos/games/TASKS.md`
  - `canon/repos/games/README.md`
- Constat:
  - la branche Drive est partagée pour tous les formats Drive supportés,
  - la logique restait trop stricte en cas de timeout tardif malgré affichage déjà exploitable.
- Actions réalisées:
  - ajout d’un flag de rendu Drive réussi (`driveHasRenderedSuccessfully`) + heuristique de rendu effectif (`hasLikelyDriveRendered`),
  - distinction explicite des timeouts:
    - `drive-timeout-before-render` (bloquant),
    - `drive-timeout-after-render` (soft error),
  - dissociation `errorReason` / `startedReason` dans `endLoadingForToken` pour conserver l’observabilité sans invalider l’affichage déjà visible (`support/started -> drive-ready`).
- Vérifications:
  - revue diff ciblée sur la branche Drive et le helper central de fin de chargement,
  - validation runtime navigateur non exécutée dans cet environnement.

## Update 2026-02-27 — Games: audit Google Drive multi-support + correctif timeout visuel
- Scope code:
  - `games/web/includes/canvas/core/player/index.js`
- Scope doc:
  - `canon/repos/games/TASKS.md`
  - `canon/repos/games/README.md`
- Constat:
  - la gestion Drive est centralisée dans le player support front (pipeline commun avant branches image/audio/vidéo directes),
  - `drive-timeout` est propagé via `support/error` -> `SUPPORT_ERROR`,
  - le retry Drive rechargeait l’iframe au premier timeout, pouvant provoquer un effet “visible puis disparaît”.
- Actions réalisées:
  - reconnaissance Drive durcie (host Google Drive/Docs explicite + extraction ID structurée),
  - retry Drive modifié en fenêtre de grâce sans reload `iframe.src` avant `drive-timeout`,
  - docs canon `games` mises à jour (README + TASKS) avec le flux et le correctif.
- Vérifications:
  - revue diff ciblée sur `player/index.js`,
  - validation runtime navigateur non exécutée dans cet environnement.

## Update 2026-02-27 — Bibliothèque view: états visuels du bouton audio `Écouter 10s`
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Constat:
  - le bouton d’aperçu audio lançait bien la lecture, mais sans état visuel explicite (`loading`/`playing`) ni arrêt manuel direct.
- Actions réalisées:
  - refonte légère du bouton preview audio (quiz + playlists) avec rendu compact:
    - structure icône+label dédiée pour pilotage d’état JS
    - largeur stabilisée (`min-width`) et zone icône fixe (anti layout shift)
  - machine d’état JS ajoutée:
    - `idle`: play + `Écouter 10s`
    - `loading`: spinner pendant chargement
    - `playing`: stop + `Arrêter`
  - arrêt manuel au clic sur le bouton en état `playing`
  - retour automatique en `idle` sur:
    - fin naturelle
    - timeout de preview
    - erreur de lecture/chargement
  - garantie d’un seul aperçu audio actif à la fois sur la page:
    - démarrage d’un nouveau preview => arrêt propre du précédent (audio local ou YouTube)
  - hardening YouTube:
    - protection contre callbacks API tardifs (nonce) pour éviter un démarrage fantôme après annulation/changement
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
- QA manuelle restant à exécuter:
  - transition visuelle `idle -> loading -> playing` sur audio fichier et YouTube
  - arrêt manuel `playing -> idle`
  - fin 10s et erreur => retour `idle`
  - lancement d’un second aperçu => arrêt du premier

## Update 2026-02-27 — Agenda UI V1: lecture par date renforcée (vs bibliothèque)
- Scope code:
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php`
- Constat:
  - la vue agenda présentait une continuité de cartes proches de la logique catalogue de la bibliothèque; l’entrée temporelle (date/heure) n’était pas prioritaire.
- Actions réalisées:
  - regroupement des sessions en sections par date (`Aujourd'hui`, `Demain`, puis dates explicites), avec compteur de sessions par section
  - jalons temporels de section affichés en uppercase (cohérence visuelle agenda)
  - renforcement de la hiérarchie `Quand` dans la carte:
    - date et heure fusionnées sur une seule ligne (`DATE - HEURE`)
    - ligne date/heure en gras et non-wrap (mobile inclus)
  - réduction du poids visuel des cartes agenda via un scope CSS local (`agenda-v1`) qui diminue la dominance de l’image
  - CTA secondaire carte renommé `Gérer` avec icône de gestion (sliders)
  - suppression du sous-texte de page agenda (itération UX)
  - aucune modification des parcours métier
- Vérifications:
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_sessions_list.php` OK
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_sessions_list_bloc.php` OK
- QA manuelle restant à exécuter:
  - Bibliothèque: rendu inchangé (ou quasi inchangé)
  - Agenda: lecture chrono/date nettement plus évidente
  - desktop + mobile/tablette: absence de régression de lisibilité

## Update 2026-02-27 — Stepper `resume`: masquage bibliothèque directe, maintien agenda
- Scope code:
  - `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`
- Constat:
  - `start_step_4_resume` affichait le stepper pour toute session non démo, sans distinguer l’entrée `agenda` vs `bibliothèque`.
  - dans le flux bibliothèque, `from=library` existait déjà au POST `session_setting`, et `tunnel=agenda` existait déjà pour la variante agenda->bibliothèque mais n’était pas propagé jusqu’au `resume`.
- Actions réalisées:
  - propagation explicite de `tunnel=agenda` dans le formulaire step2 (`ec_start_step_2_setting.php`) quand présent en query.
  - redirection `session_setting` -> `resume` contextualisée (`ec_start_script.php`):
    - `?from=library` pour la bibliothèque directe
    - `?from=library&tunnel=agenda` pour agenda->bibliothèque
  - gating `start_step_4_resume` (`ec_start_include_header.php`):
    - stepper masqué si `from=library` sans `tunnel=agenda`
    - stepper conservé pour agenda (dont agenda->bibliothèque) et autres parcours historiques
- Vérifications:
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_script.php` OK
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_include_header.php` OK
- QA manuelle restant à exécuter:
  - Bibliothèque -> Programmer -> `start/game/resume/` => stepper masqué
  - Mon agenda -> tunnel normal -> `start/game/resume/` => stepper visible
  - autres usages `resume/` => inchangés

## Update 2026-02-24 — Quiz papier quick: remplacement question dans lots temporaires `T{id}`
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
- Actions réalisées:
  - ajout d’un mode script dédié `content_library_temp_lot_question_replace` avec `replace_mode=pick|create`
  - gating backend strict avant toute mutation:
    - contexte session agenda (`context=session`, `nav_ctx=agenda`, `id_securite_session`)
    - session owner courant
    - quiz papier (`id_type_produit in (1,5)` + `flag_controle_numerique=0`)
    - présence de lots temporaires `T*` dans `lot_ids` et appartenance du `T{id}` affiché à la session
  - option A (pick):
    - sélection alternative “mêmes critères” alignée axes picker V2 source
    - exclusions source + intra-lot + `excluded_ids` globaux quand disponibles
    - fallback ajouté pour cas “Cette semaine dans l’histoire”:
      - si aucun candidat strict et source avec `jour_associe`, élargissement de la recherche sur le seul axe `jour_associe`
      - exclusions intra-lot conservées (source + questions déjà dans le lot)
  - option B (create):
    - validation réutilisée via `clib_theme_content_payload_validate('quiz','add', ...)`
    - création question avec `id_etat` source + classification modifiable utilisateur (`id_univers`, `id_rubrique`)
    - defaults classification = question source
    - validation serveur classification:
      - univers/rubrique existants
      - cohérence rubrique->univers obligatoire
    - `id_points` / `difficulte` non repris depuis la source (pipeline standard quiz perso)
    - pas de gestion de `date_fin_validite` dans ce flux (hors scope)
    - `jour_associe` conditionnel:
      - source avec `jour_associe`: préfill date du jeu (date session), modifiable mais borné serveur à ±5 jours
      - source sans `jour_associe`: non applicable et insertion sans jour associé
    - assertion post-insert (univers/rubrique/jour_associe) + purge de la question créée en cas de mismatch
  - mutation lot temporaire atomique:
    - lock row `questions_lots_temp` (`FOR UPDATE`)
    - re-read JSON `question_ids`
    - remplacement à l’index source exact + anti-doublon + update JSON
  - UI view `T{id}`:
    - bouton de remplacement allégé en icône seule `↻` (visible uniquement si gating autorisé)
    - placement de l’icône sur la ligne question dans une zone dédiée (évite le chevauchement du texte sur plusieurs lignes)
    - aperçu support affiché sur la même ligne dans une colonne dédiée à droite
    - alignement vertical centré des éléments de ligne (icône / question / aperçu)
    - modale 2 actions (pick/create), libellés finalisés:
      - `A) Remplacer par une nouvelle question existante (mêmes critères)` + CTA `Remplacer`
      - `B) Créer une question de remplacement`
      - formulaire B masqué par défaut + ouverture via CTA `Ajouter une question`
      - submit B via CTA `Créer et remplacer`
      - suppression du bouton “Fermer le formulaire”
      - suppression du champ `Fausse proposition 4 (facultative)`
      - `Univers`/`Rubrique` passés en dropdown éditables
      - `Rubrique` filtrée/rechargée en fonction de l’univers sélectionné
      - reset rubrique si incompatibilité après changement d’univers
      - champ `Jour associé` affiché uniquement si applicable (source avec `jour_associe`), avec bornes UI min/max ±5 jours
      - mention d’aide affichée uniquement formulaire ouvert, en italique
      - champs support conditionnels au type choisi:
        - `Aucun`: pas de champs support
        - `Image`: champ upload image
        - `Audio`: champ lien YouTube Music
        - `Vidéo`: champ lien YouTube + bornes début/fin
  - feedback bandeau `Question remplacée.`
  - logs structurés:
    - `QUIZ_PAPER_TEMP_REPLACE_OK`
    - `QUIZ_PAPER_TEMP_REPLACE_ERR`
    - `QUIZ_PAPER_TEMP_REPLACE_PICK_EMPTY`
    - `QUIZ_PAPER_TEMP_REPLACE_CREATE_ERR`
    - `TEMP_LOT_REPLACE_CREATE_START`
    - `TEMP_LOT_REPLACE_CREATE_INSERT_OK`
    - `TEMP_LOT_REPLACE_CREATE_INSERT_ERR`
    - `TEMP_LOT_REPLACE_CREATE_DAY_OUT_OF_RANGE`
    - `TEMP_LOT_REPLACE_CREATE_ASSERT_MISMATCH`
    - `TEMP_LOT_REPLACE_WRITE_OK`
    - `TEMP_LOT_REPLACE_WRITE_ERR`
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK

## Update 2026-02-24 — Lots temporaires Quiz: simplification fiche + naming agenda
- Scope code:
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php`
  - `pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php`
- Actions réalisées:
  - bibliothèque `view` (lots temporaires `quiz_temp_lot`):
    - ajout d’un helper de fallback image par défaut (`default_cotton_quiz.jpg`) pour afficher un visuel aussi sur les lots temporaires
    - titre simplifié en `<nom série> (auto)` (suppression du préfixe “Série auto-générée —”)
    - sous-titre simplifié (suppression du préfixe `Série auto papier :`)
    - métadonnées simplifiées:
      - `Niveau: Facile`
      - `Auteur: Cotton`
      - `Contenu: 6 questions`
      - `Durée indicative: 5 min`
    - retrait des lignes `Date d'ajout` et `Mode: Lecture seule`
    - cas spécial `Cette semaine dans l'histoire`: affichage de `Date de référence: jj/mm/aaaa` (date de session quiz quand contexte agenda/session présent)
  - fiche session agenda (Quiz V2):
    - suppression du badge `Auto`
    - ajout du suffixe `(auto)` directement dans le nom des séries temporaires (ex: `Cette semaine dans l'histoire (auto)`)
- Vérifications:
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_lib.php` OK
  - `php -l pro/web/ec/modules/jeux/bibliotheque/ec_bibliotheque_view.php` OK
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_sessions_view.php` OK

## Update 2026-02-24 — Step2 setting: harmonisation UI/UX programmation
- Scope code:
  - `pro/web/ec/modules/tunnel/start/ec_start_include_header.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php`
- Actions réalisées:
  - header step2:
    - suppression de l’icône roue crantée devant le titre
    - titre remplacé par:
      - `Programmation rapide {jeu}` en mode `from=agenda&mode=quick`
      - `Programmation {jeu}` hors mode agenda quick
    - sous-titre remplacé par: `Choisis le format et les dates de tes sessions`
  - layout step2:
    - container principal des paramètres élargi en `col-12 col-md-12 col-lg-12 col-xl-12`
  - labels:
    - `Version du jeu` en `fw-bold` + espacement bas (`mb-3`)
    - `Programmation` en `fw-bold` + espacement bas (`mb-3`)
  - mode de programmation multiple (agenda quick):
    - `Récurrence` déplacée à gauche de `Dates libres`
    - `Récurrence` active par défaut (`schedule_mode=recurrence`)
    - bloc récurrence affiché par défaut / bloc dates libres masqué par défaut
  - auto-sélection jour:
    - `recurrence_weekday` prérempli avec le jour courant serveur
    - `monthly_weekday` aligné sur le même comportement
- Vérifications:
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_include_header.php` OK
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php` OK

## Update 2026-02-24 — Agenda pivot: reprise “prog rapide” après flux bibliothèque
- Scope code:
  - `pro/web/ec/modules/tunnel/start/ec_start_script.php`
  - `pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php`
- Contexte:
  - flux observé: `Agenda > Ajouter > Choix jeu > Choisir une thématique > Bibliothèque > Back (pivot) > Programmation rapide`
  - le flux `library` purge volontairement la session pré-initialisée; au retour pivot, le clic `prog rapide` repartait sur le choix du jeu.
- Actions réalisées:
  - ajout d’un helper backend `start_agenda_quick_session_init(...)` dans `ec_start_script.php`:
    - recrée une session standard non-démo pour le jeu ciblé (`seo_slug_jeu`) avec les règles existantes de mapping `id_type_produit` (Quiz/Bingo/Blind).
  - adaptation du fallback `case 'agenda_mode_select'` (`agenda_mode=quick`):
    - si la session fournie n’est plus valide mais que le jeu est connu, création immédiate d’une nouvelle session puis redirection directe vers:
      - `/extranet/start/game/setting/{id_securite_session}?from=agenda&mode=quick`
    - fallback inchangé vers `/start/game/choose/...` uniquement si le jeu n’est pas résolu ou si la création session échoue.
  - conservation de la logique de purge session côté flux `agenda_mode=library` (verrou inchangé).
  - pivot agenda:
    - conservation des boutons avec `stretched-link` sur les 2 cartes (`Programmer par date(s)` / `Choisir une thématique`).
- Vérifications:
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_script.php` OK
  - `php -l pro/web/ec/modules/tunnel/start/ec_start_agenda_mode.php` OK

## Update 2026-02-23 — Audit calendrier multi-dates (agenda quick)
- Scope audit:
  - `pro/web/ec`
  - assets EC partagés (`global/web/includes/extranet`)
- Objectif:
  - vérifier l’existant réutilisable pour une saisie multi-dates en mode “agenda quick” sans réimplémentation from scratch.

### 1) Inventaire libs datepicker (JS/CSS) + chargement
- `flatpickr` (lib active côté EC):
  - CSS chargés dans `pro/web/ec/ec.php:317` et `pro/web/ec/ec.php:318`
  - JS chargés dans `pro/web/ec/ec.php:1085`, `pro/web/ec/ec.php:1086`, `pro/web/ec/ec.php:1087`
  - init globale dans `global/web/includes/extranet/js/includes_main.js:338` à `global/web/includes/extranet/js/includes_main.js:365` sur `.flatpickerdatetime`
- `jQuery UI`:
  - seul le CSS est chargé dans `pro/web/ec/ec.php:314`
  - aucune init `.datepicker(...)` trouvée dans `pro/web/ec` (donc pas de datepicker jQuery UI actif côté EC)
- Autres libs (`pikaday`, `litepicker`, `air-datepicker`, `bootstrap-datepicker`) :
  - aucune occurrence d’usage dans `pro/web/ec`
  - présence d’un vendor `fullcalendar` en assets partagés (`global/web/includes/extranet/vendor/fullcalendar`) mais non chargé/consommé par `pro/web/ec`

### 2) Occurrences d’initialisation multi-date / multiple / range / inline
- Flatpickr global (config commune):
  - `global/web/includes/extranet/js/includes_main.js:343`
  - options par défaut: `inline: false`, `allowInput: true`, `disableMobile: true`, plugin `confirmDate`
  - `mode: "multiple"` existe uniquement en commentaire (`global/web/includes/extranet/js/includes_main.js:345`)
- EC tunnel start (session setting):
  - mode forcé à `single` dans `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php:52`
  - champ flatpickr avec `data-options` (mode issu de la variable ci-dessus) dans `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php:171`
- EC événements:
  - mode forcé à `single` dans `pro/web/ec/modules/operations/evenements/ec_evenements_form.php:18`
  - champs date début/fin flatpickr dans `pro/web/ec/modules/operations/evenements/ec_evenements_form.php:213` et `pro/web/ec/modules/operations/evenements/ec_evenements_form.php:217`
- Recherche init multi-date/range:
  - aucune occurrence active de `mode: "multiple"`, `mode: "range"`, `multidate: true`, `multipleDates`, `selectMultiple`, `inline: true` dans `pro/web/ec`

### 3) Écrans existants avec sélection multiple de dates
- Écran actif “agenda quick” (équivalent multi-dates):
  - `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php:192` à `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php:233`
  - UI: ajout/suppression dynamique de lignes `session_dates[]` + `session_times[]`
  - JS de gestion des lignes: `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php:520` à `pro/web/ec/modules/tunnel/start/ec_start_step_2_setting.php:556`
  - backend multi-entrées déjà branché: `case 'session_setting_multi'` dans `pro/web/ec/modules/tunnel/start/ec_start_script.php:764` (normalisation et création batch)
- Piste legacy/non branchée explicitement:
  - `pro/web/ec/modules/widget/ec_widget_jeux_sessions_form_mode_calendrier_V3.php:480` mentionne un champ “une ou plusieurs dates”, mais aucun include/require actif trouvé dans `pro/web/ec` pour ce widget.

### 4) Recommandation
- Recommandation principale: **réutiliser le flux existant agenda quick (multi-lignes date/heure)**.
  - Pourquoi: déjà en production, backend déjà compatible batch, zéro dépendance nouvelle, comportement mobile natif fiable.
  - Compat:
    - mobile: oui (inputs natifs `date`/`time`)
    - inline calendar: non (pas de vue calendrier inline)
    - multi-select: oui (via plusieurs lignes)
- Fallback (si besoin d’un vrai “calendar multi-select” en 1 champ):
  - activer Flatpickr `mode: "multiple"` sur un champ dédié, en conservant la stack existante (`ec.php` + `includes_main.js`).
  - exemple minimal:
```html
<input
  type="text"
  name="session_dates_multi"
  class="form-control flatpickerdatetime"
  data-options='{"mode":"multiple","dateFormat":"Y-m-d","minDate":"today"}'>
```
  - Note: ce fallback nécessite un mapping serveur vers `session_dates[]` (et une règle horaire par défaut ou un second input heure), contrairement au flux principal déjà prêt.

### Décision proposée
- **On réutilise X = `agenda quick` multi-lignes existant (`session_dates[]` / `session_times[]`)** pour le step2.
- Pas de modification `TASKS/README` faite à ce stade (conforme consigne).

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
