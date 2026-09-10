# Hub vide conservé et réutilisé — cas 805 / 148

CORRIGÉ LOCALEMENT — NON DÉPLOYÉ. Code Global/Pro sur `hub_soiree`, documentation sur `develop`. Aucun accès DB, SSH, serveur DEV/PROD ou navigateur ; aucune migration, purge, livraison ou relance.

## Preuves et discipline préalable

Sources RAW consultées avant patch :

- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/START.md — « Statut actuel », « Discipline de génération », promotion documentaire.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt — navigation agent-first.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md — « Update triggers », « Routing rules ».
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/global/README.md — « Update 2026-07-28 - Service quick-add Hub: cutoff de reactivation », contrat QR continuation.
- https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md — « Update 2026-09-02 - Contrat atomique métier Quick Schedule », « Déplacement et suppression cohérents d'un Hub », « Dashboard/Archives Hub: membership canonique et reactivation ».

Journal AI Studio : l’URL opérateur `documentation/general/0_ROADMAP.md` retourne une enveloppe HTML sans `mode=raw` ; avec ce paramètre, le journal Markdown est lisible. La référence alternative `documentation/client/0_ROADMAP_journal_travaux.md` retourne 403. Le START consulté renvoie désormais au journal general. Aucune mention de modification externe des fichiers ciblés identifiée dans le journal accessible. Les entrées Pro auth/contacts et ecommerce repérées ne concernent pas ce correctif. Le contenu de la référence 403 reste non vérifié ; aucun token d’accès recopié dans cette note.

La règle précise de réconciliation transparente d’un Hub actif vide était **non trouvée dans la documentation** : décision produit explicitement fournie pour ce chantier. Les règles temporelles, le caractère canonique des memberships et les routes sont confirmés par le code local courant.

## Cause et chemin revalidés

La suppression individuelle `app_session_delete_canonical` inactive le membership puis supprime la session, sans supprimer le Hub. L’Agenda est construit depuis les sessions. Le probe Bibliothèque exige une session membre active/configurée compatible ; il ignore donc la racine vide. Le plan arrive sans cible et l’ancien `app_schedule_plan_target_hub_resolve` refuse toute racine active avec `DATE_OCCUPIED`.

Routes réelles :

| Entrée | Contrat d’écriture | Résolution |
| --- | --- | --- |
| Home, Agenda | `generated_program`, `source=home|agenda` | SchedulePlan commun, cible initialement 0 |
| Récurrence | un `generated_program` par occurrence | Même commit ; pas de changement du filtrage/calendrier des occurrences |
| Bibliothèque générale | `fixed_content`, session technique précréée | Probe UX conservé ; réconciliation centrale lorsque cible 0 |
| Bibliothèque Hub explicite | `fixed_content`, cible explicite | Identité du Hub validée ; aucun second Hub |
| Ajouter depuis Dashboard Hub | service `app_programming_quick_hub_create_from_dashboard_preparation` → proposition | Source Hub explicite autoritaire, chemin distinct déjà corrigé ; suite dédiée conservée |

`source` est une provenance, pas une quatrième intention SchedulePlan. Le quick-add Hub n’est pas migré vers le commit SchedulePlan dans cette passe. Aucun rendu Agenda modifié.

## Contre-épreuve DEV667 et comparaison Git — reprise après audit

Sources locales relues sans écriture à la demande de l’opérateur : `pro/logs/access_log` et `error_log` rechargés. Global/logs s’arrête à18:18:04, avant ces essais. À19:18:47, session27770/Hub311 créée pour le7octobre ; après retour Agenda, succès à19:19:05 sur le10septembre avec session27771 et nouveau Hub312. Le succès ne prouve donc pas une réutilisation. À19:25:34, création session27772/Hub313 pour le11septembre, retour Agenda après le POST de19:25:41, puis refus fixed_content DATE_OCCUPIED à19:25:54 sur la même date, retour id_hub=0. Routes Bibliothèque générales identiques dans les traces ; rendu des CTA et corps POST non disponibles. État SQL des suppressions/brouillons non lu directement. À19:00:11, un Quick Schedule source Agenda avait aussi refusé le9septembre.

Comparaison isolée des commits, sans confondre le patch local non commité : Pro main c1143b0 / Hub217053a ; Global main371cd6c / Hubc2ea04c. Helpers Bibliothèque, commit SchedulePlan, suppression individuelle et bootstrap Global identiques entre les branches. Pro217053a corrige le quick-add Dashboard avec source explicite, pas cette réconciliation ; le contexte fixed explicite existe depuis7fb26a6 dans les deux branches. Exécution en mémoire des fonctions originales main et HEAD : les deux dates09/09 et20/09, soirée/événement, donnent DATE_OCCUPIED sans cible et TARGET_HUB_READY avec cible explicite. Aucun correctif commité du cas vide automatique identifié. L’opérateur a ensuite autorisé la poursuite du patch.

La fixture DEV667 du nouveau test programme un brouillon fixed, supprime individuellement sa session puis programme un second brouillon à la même date : les deux commits utilisent Hub313, une seule racine subsiste, le second brouillon est configuré. Il s’agit de données simulées ; l’ID27773 de cette fixture n’est pas un ID confirmé par les logs.

## Contrat de réutilisation

Sans cible explicite, Global lit toutes les racines actives du client à cette date, y compris `deleting`. Plusieurs racines donnent `MULTIPLE_HUBS_REQUIRE_CHOICE`, aucune sélection par ordre d’ID. Une racine unique doit correspondre exactement au client, à la date, au contexte et à l’événement ; elle doit être active, non supprimante, et sans aucun membership actif brut, même si sa session serait filtrée ou manquante. Une soirée réellement occupée ou un contexte incompatible conserve `DATE_OCCUPIED`. Une session officielle configurée sur cette date sans membership reste également une occupation réelle ; le correctif ne masque pas un programme legacy non rattaché.

Le garde temporel canonique quick-add utilise la politique préparation Dashboard : avant/ouvert autorisés, cutoff J+1 à midi Europe/Paris interdit. « Terminé » dérivé d’anciennes sessions n’est pas une interdiction permanente ni un flag à réinitialiser. Le dernier démarrage par token de session fait autorité, comme le lecteur canonique d’exécution : terminé autorise, exécution non close refuse ; un ancien marqueur non clos antérieur au dernier démarrage terminé ne ressuscite pas une exécution. Un marqueur sans identité exploitable refuse. Une commande Remote non QR pending/claimed/processing bloque. Un simple focus `active_session_id` n’est pas une preuve d’exécution ; il n’est pas effacé.

Joueurs, probables, participations, lots, branding, publication, résultats et historiques restent attachés au même Hub ; aucune remise à zéro. Une commande QR terminée ne bloque pas. Les commandes Remote orphelines du Hub148 purgé restent hors périmètre.

Pour un contexte événement sans ID initial, la racine unique admissible fournit son événement avant les callbacks de préparation. Ces callbacks conservent désormais cet ID. Le writer reçoit le même Hub et un `target_hub_id` réconcilié ; aucun nouveau pivot ou Hub de substitution.

## Verrous et limites de l’atomicité

SchedulePlan acquiert `schedule_day_<client>_<date>` avant idempotence/résolution et le conserve jusqu’à la fin et aux compensations. La suppression individuelle emploie le même verrou et relit la session après acquisition. Le commit prend aussi le verrou canonique existant `games_hub_delete_<id>` puis revalide la cible, et répète le prédicat automatique avant écriture. Les verrous MySQL de connexion sont libérés par `finally`, sans attente bloquante (`GET_LOCK(..., 0)`), avec `SCHEDULE_BUSY` en cas de contention. Les appels internes de compensation peuvent être réentrants sur la même connexion.

La provenance source est exclue du hash métier pour conserver les clés antérieures au patch. La reprise writing_plan restaure sa cible et son événement avant la résolution automatique, même si une session a déjà été écrite. Le replay réussi conserve son résultat. Deux nouvelles commandes SchedulePlan sur date vide ne peuvent pas traverser simultanément le resolver/writer : une gagne, l’autre reçoit busy puis, au retry, voit l’état effectif. Un échec après création de racine peut laisser une racine vide conservée, réutilisable ensuite. Cela ne constitue pas une transaction SQL : MyISAM, interruption du processus et writers legacy ne participant pas à ces verrous restent les limites existantes. Le quick-add explicite Hub garde son propre contrat ; les tests de contention concernent SchedulePlan et la suppression canonique, pas tous les writers historiques.

## Brouillon Bibliothèque

`session_init` crée et vérifie `championnats_sessions` avant le wizard/commit. Le fixed writer ne déclare pas cette création dans une liste distincte de ressources possédées ; ses IDs de retour peuvent désigner une ressource désormais configurée. Il ne faut donc pas employer sa compensation générique destructrice.

La Bibliothèque enregistre juste après création une preuve côté session PHP : ID du brouillon, client et hash de son identité. La compensation fixed est limitée à cette preuve, au token exact et au client, avec une suppression conditionnelle atomique : hors démo, produit 0, configuration 0, aucun membership même inactif. Aucun critère global de date vide, aucune purge d’anciens brouillons, aucune cascade de session officielle.

Le wrapper du commit compense le brouillon non configuré après refus définitif, sous le verrou de date, y compris un refus avant writer. Busy/conflit idempotent conserve le brouillon pour la tentative potentiellement en cours. Après compensation, retour Bibliothèque avec son message d’erreur existant : l’ancien token supprimé ne sert plus au retry. La preuve est retirée au succès/retour après compensation. Une nouvelle sélection recrée un brouillon. Le compensateur est idempotent ; preuve absente, ressource configurée ou rattachée : conservation. Une configuration effective suivie d’un échec de membership reste à diagnostiquer/récupérer, jamais à supprimer comme simple brouillon. Une session PHP expirée ne permet pas de prouver la propriété d’un ancien brouillon.

Logs : `schedule_plan_target_hub_reconciled` (client/date/Hub/contexte/source/raison), `schedule_plan_draft_compensated` (client/session/hash commande/raison), conservation après configuration via `schedule_plan_compensation_preserved`. Aucun token dans les nouveaux logs.

## Validation locale exécutée

Depuis `global` :

```sh
php web/tests/schedule_plan_commit_behavior_test.php
php web/tests/schedule_plan_empty_hub_test.php
php web/tests/programming_quick_hub_service_contract_test.php
php web/tests/temporal_window_state_test.php
php web/tests/schedule_plan_commit_contract_test.php
```

Comportement existant vert ; nouveau test **52 contrôles verts** : fixture client805/Hub148, trois cycles Home/Agenda/fixed utilisant le vrai commit et le vrai deleter individuel, replay, memberships inactifs, même racine, lignes sources Agenda, annexes/historique conservés, cutoff, exécution ouverte, commande pending, propriétaire/contexte, contention simulée, verrou suppression globale, brouillon automatiquement compensé après DATE_OCCUPIED, idempotence, protection préexistant/configuré, événement conservé avant prepare. Sont aussi couverts le replay sans métadonnée source, la reprise événement avec session déjà écrite et la reproduction fixed du client667. Le test comportement existant couvre aussi racines multiples, véritable occupation, création, compensation générée et reprise interrompue.

Quick Hub et fenêtre temporelle verts. Le test statique `schedule_plan_commit_contract_test.php` conserve **deux échecs préexistants** (« Dashboard consumes an existing Hub read-only », « remaining Dashboard write is explicitly bounded to legacy migration »), reproduits sur des copies HEAD isolées dans `/tmp/cotton-schedule-head` avant nos modifications. Aucun affaiblissement de ce test.

Depuis `pro/web/ec/modules/tunnel/start` :

```sh
php ec_start_dashboard_quick_source_hub_test.php
php ec_start_library_hub_add_flow_test.php
php ec_start_quick_schedule_ui_test.php
php ec_start_sessions_day_dashboard_test.php
php ec_start_dashboard_quick_parameters_test.php
```

Toutes vertes, dont 38 contrôles source Hub. Le contrat statique Bibliothèque compte désormais aussi le nouveau bloc d’enregistrement de preuve (quatre occurrences, auparavant trois). Lint PHP et `git diff --check` sur les fichiers applicatifs modifiés : verts. Sitemap/index générés via `DOCS_BRANCH=develop npm run docs:sitemap`.

Les writers catalogue/auth et le stockage sont des doubles explicites. Les lignes Agenda sont vérifiées sur la source de données simulée, pas un rendu navigateur. Les verrous sont simulés, pas un stress test à deux connexions MySQL. Les tests n’ont jamais lu ou modifié la DB réelle du client805.

## Recette opérateur et rollback

Sur DEV après livraison séparément autorisée : programmer une partie, relever Hub/session, supprimer individuellement la dernière, vérifier Agenda vide puis reprogrammer via Home et Bibliothèque ; même Hub, nouveau membership, données annexes conservées. Vérifier également événement, QR historique, heure cutoff, ambiguïté, refus et compensation de brouillon ; deux connexions concurrentes ajout/suppression. Mesurer le coût du scan des marqueurs game_events sur le volume réel : il ne concerne que les racines vides mais aucun benchmark DB n’est disponible ici.

Rollback : retirer uniquement ce patch Global/Pro, en conservant les autres travaux `hub_soiree`. Aucune migration à inverser. Le retrait réintroduit le refus sur Hub actif vide ; aucun nettoyage de données n’est inclus. Les anciens brouillons30247/30249/30251/30253 et commandes Remote21/22 ne sont pas traités.

## Fichiers applicatifs et tests de ce patch

- Global `web/app/modules/jeux/programmation/app_programming_recommendations_functions.php` : prédicat, résolution, verrouillage, reprise/idempotence et compensation fixed.
- Global `web/app/modules/jeux/sessions/app_sessions_functions.php` : verrou partagé de suppression individuelle.
- Global `web/tests/schedule_plan_commit_behavior_test.php` : doubles SQL/verrous/suppression adaptés ; `web/tests/schedule_plan_empty_hub_test.php` : 52 contrôles de régression.
- Pro `web/ec/modules/jeux/bibliotheque/ec_bibliotheque_script.php` : enregistrement de la preuve de création.
- Pro `web/ec/modules/tunnel/start/ec_start_schedule_draft_helpers.php` : compensation bornée ; `ec_start_script.php` : callbacks fixed, provenance et événement conservé.
- Pro `web/ec/modules/tunnel/start/ec_start_library_hub_add_flow_test.php` : contrat du nouvel enregistrement de preuve.
