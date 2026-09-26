# Hub 341 — audit des reprises papier du 21 septembre 2026

<!-- AUTO-UPDATE:BEGIN id="hub341-paper-resume-roster-audit" owner="codex" -->

Audit des copies locales rechargées `games/logs` et `global/logs`, puis lecture du code local. Aucun correctif applicatif, accès DB, appel applicatif distant ou restart. Les heures ci-dessous sont celles des logs ; les access logs indiquent +0200.

## Complément — résultats SQL fournis par l’utilisateur et traces individuelles

Ce complément précise les limites du premier audit ci-dessous. L’utilisateur confirme18 affichés Master/Remote après reprise Quiz. Les deux SELECT fournis pour27925 (Quiz interne1648) montrent20 actifs Hub mais18 participations Quiz, toutes actives, avec18 mappings cohérents. Les absents sont **mustach1132** et **Jiji1133**, sans mapping ni participation Quiz. Il ne s’agit donc pas, pour ces deux identités, de participations inactives filtrées ou d’une perte lors de la réhydratation. Remo12 et HubBot-007 sont présents ; les échecs historiques repérés pour eux n’identifiaient pas les absents actuels.

Recherche ciblée dans les logs courants Games/Global par identifiants Hub et clés :

- `games/logs/error_log:43526`,17:35:05 : mustach1132 passe par `hub_remote_player_bridge_requested`, source runtime, session Blind Test27926 ; mapping1585 créé. Le bridge termine avec `eligible_for_future_injection=true`.
- `games/logs/error_log:43570`,17:36:06 : tentative d’accès/injection de1132 dans Bingo27927 avec `join_source=launch`.
- `games/logs/error_log:43613`,17:36:32 : Jiji inséré dans Bingo (`PLAYER_REGISTER_UPSERT mode=inserted`), puis bridge runtime Hub341 et mapping1593 pour27927.
- Aucune tentative vers Quiz27925 pour1132/1133 retrouvée dans les fragments conservés. Ce constat n’est pas une preuve d’absence historique absolue, compte tenu des troncatures.

Ces traces documentent des inscriptions via les jeux suivants, après le lancement Quiz17:29:21. Associées aux résultats DB et au retour anticipé de la reprise, elles étayent fortement le scénario : identités disponibles au Hub, mais jamais rattrapées dans le Quiz repris. L’heure exacte de création de leur ligne Hub n’est pas prouvée par le bridge (il annonce `already_active`). Aucune erreur initiale Quiz individuelle n’est démontrée pour ces deux joueurs. Pas de nouvelle requête DB exécutée par l’agent ; résultats fournis par l’utilisateur uniquement.

## Complément — clients numériques et bots : parcours confirmé dans le code

La distinction pertinente est client actif / inscription sans client, pas compte numérique / identité papier. Hub Play interroge `active_launched_session` (`games/web/modules/app_hub_view_helpers.php:12717`, reprogrammation3500ms après traitement). Le handler à3128 appelle le resolver joueur ; Global appelle `app_hub_player_resolve_session_access` à10681 pour la session active. Ce resolver assure une participation papier à9394, ou numérique à9435, avant toute autorisation de redirection. Un échec interdit la redirection ; un départ explicite de session n’est pas réactivé automatiquement.

Les bots appellent le même endpoint pour chaque identité (`games/web/includes/bots/hub_bots.js:53`). Ils continuent à le faire en papier, mais n’attachent un client de jeu que si `!access.is_paper`. Leur rattrapage papier passe donc par le polling HTTP Hub, sans nécessiter de socket Player Quiz. Cela confirme le chemin capable de produire les inscriptions individuelles observées après reprise.

Un joueur numérique actif sur Hub Play dispose ainsi d’un mécanisme d’inscription individuel indépendant de l’injection collective. Ce défaut particulier d’absence de rattrapage collectif ne suffit pas à l’exclure durablement si son client appelle le endpoint et que l’ensure réussit. Ce n’est pas une garantie globale : page fermée, identité non résolue, départ explicite ou ensure refusé restent des cas distincts. Les20 inscrits Hub ne constituent pas automatiquement20 joueurs numériques présents.

## Conclusion et niveau de preuve

Le Hub compte effectivement 20 joueurs actifs pendant les reprises tardives. Le code présente une lacune : la reprise d’une exécution existante retourne avant l’injection des joueurs actifs du Hub. La réconciliation périodique PATCH1 relit les participations persistées du jeu ; elle ne crée pas les participations manquantes depuis le Hub. Un inscrit Hub absent de la session peut donc rester absent malgré cette réconciliation.

Les logs montrent aussi le début de deux événements d’échec d’injection Blind Test. Leur contenu est tronqué avant le motif. Cela étaye un problème Hub → participation, mais ne prouve pas que ces deux joueurs constituent exactement les absents de chaque affichage 18/19 signalé. Les listes et compteurs WS au moment de ces affichages ne figurent pas dans les copies Games/Global. La version effectivement chargée par les services n’est pas vérifiée par cet audit.

## Chronologie vérifiable

| Heure | Observation | Preuve locale |
| --- | --- | --- |
| 17:29:21 | Premier lancement Quiz 27925 : 3 inscrits sélectionnés | `games/logs/error_log:43172` |
| 17:33:50 | Premier lancement Blind Test 27926 : 6 inscrits sélectionnés | `games/logs/error_log:43410` |
| 17:36:06 | Premier lancement Bingo 27927 : 7 inscrits sélectionnés | `games/logs/error_log:43568` |
| 17:40:51 | Hub : `active_players_count=20`, `active_players_list_count=20` | `games/logs/error_log:44095` |
| 17:41:52 | Reprise Blind Test : `resume_existing_runtime`, Hub toujours à 20 | `games/logs/error_log:44241`, `44244` |
| 17:43:23–17:46:48 | Plusieurs reprises du même Blind Test | `games/logs/error_log:44493`, `44692`, `44809`, `44899`, `44957`, `45064` |
| 19:02:40 | Reprise Quiz : `resume_existing_runtime` | `games/logs/error_log:53769` |
| 19:02:55 | Hub toujours à 20 actifs / 20 dans sa liste | `games/logs/error_log:53812` |

Les 20 joueurs n’étaient donc pas tous présents aux lancements initiaux. Après ces trois lancements, aucun nouvel événement complet `hub_launch_injectable_players_selected` du Hub341 n’est visible dans les logs courants analysés. L’absence d’événement seule ne suffit pas, car des lignes sont tronquées ; le retour anticipé du code confirme le chemin sans injection lors d’une reprise existante.

## Inscriptions individuelles et troncature

- Joueur Hub1131 : 20 événements complets `hub_paper_participation_register_start` dans Blind Test, de17:33:54 à17:35:13. À17:34:37, la ligne43481 se termine par `[hub_paper_player_injection_faile`.
- Joueur Hub1140 : à17:46:47, la ligne45062 se termine par `[hub_paper_player_injection_fa` après le début d’inscription dans Blind Test27926.
- À la reprise Quiz, les joueurs1134 à1139 présentent chacun trois débuts d’inscription, entre19:02:44 et19:03:17 (par exemple lignes53773,53839,53871 pour1134). Un début répété ne prouve pas à lui seul un échec : une vérification idempotente peut également se répéter.
- Les lignes43415,43422,43481,43537,45062,53771,53871,53879 mesurent2047octets hors saut de ligne. Plusieurs s’arrêtent au milieu d’un nom d’événement. Le motif SQL/métier et le résultat final sont donc irrécupérables dans ces lignes.

Les erreurs `ANOTHER_SESSION_ACTIVE` à17:44:59 et17:45:10 concernent des tentatives de lancer Quiz pendant que Blind Test est actif. Elles ne démontrent pas une perte de joueurs.

Les agrégats de fin affichent `players_total=20` pour Bingo puis Blind Test (lignes44072 et45183). Ce champ compte les joueurs du Hub dans le rebuild (`app_games_hubs_functions.php:7009`) : il ne prouve pas20 participants live dans chaque jeu. De même, `mapping_without_result_count=0` ne prouve pas que chaque inscrit Hub possède un mapping.

Global confirme les appartenances des sessions au Hub341 (par exemple `global/logs/error_log:440` pour27926), mais ses logs disponibles ne contiennent pas les listes WS ni le motif tronqué côté Games.

## Mécanisme dans le code local

1. `global/web/app/modules/jeux/hubs/app_games_hubs_functions.php:10453` : reprise officielle avec `$can_reuse_runtime_execution`, puis retour à10466. L’appel `app_games_hub_session_inject_active_players` se situe après ce retour, à10487.
2. Cette injection parcourt les actifs Hub à9749 et appelle le resolver d’accès/ensure pour chacun. Elle dispose donc de la population manquante à la simple hydratation moteur.
3. `games/web/includes/canvas/php/blindtest_adapter_glue.php:1166` : `players_get` lit `blindtest_players`, filtre `is_active` pour le live, puis valide/déduplique les identités et leur admission Hub. Aucun INSERT de participation.
4. `blindtest/web/server/actions/registration.js:996` : toutes les5secondes, la réconciliation appelle l’hydratation ; celle-ci lit `CanvasAPI.playersGet` à745. Elle peut rétablir un joueur déjà persisté et admissible, pas un joueur uniquement inscrit au Hub.

Conséquence : une lecture complète de18 participations du jeu n’est pas une preuve de réconciliation des20 inscrits Hub. Les contrôles d’ordre/autorité de snapshot PATCH1 ne réparent pas cette étape amont.

## Suite ciblée

Pour attribuer exactement les absents, recouper le jeu/l’heure de l’affichage avec les logs moteur `PLAYERS_HYDRATE_DONE`, `PLAYERS_HYDRATE_ROW_SKIPPED`, `PAPER_PLAYER_BIND`, les listes K/D, puis le résultat non tronqué de l’ensure Hub. Vérifier pour chaque identité la participation du jeu, son activité et son mapping ; ne pas déduire une collision de nom, un départ ou une limite de capacité des seuls compteurs.

Correctif recommandé, non appliqué dans cet audit : une reprise papier doit réconcilier les inscrits Hub admissibles avec les participations avant de déclarer le roster prêt, exposer les échecs individuels et préserver les départs explicites, les scores et les sessions terminées. Ajouter une preuve de couverture Hub → jeu ; ne pas compléter artificiellement le compteur ni réactiver tous les historiques.

Vérification reproductible sans DB : extraire les événements JSON `hub_master_full_reload_profile`, `hub_launch_injectable_players_selected`, `hub_focus_relaunch_requested` avec `hub_id/id_hub=341`, et inspecter les lignes indiquées. Pour vérifier la troncature : `python3 -c 'from pathlib import Path; a=Path("../games/logs/error_log").read_bytes().splitlines(); print([(n,len(a[n-1])) for n in (43481,45062)])'` depuis documentation ; attendu2047 pour les deux lignes de cette copie.

Fichiers modifiés : cette note, TASKS Games/Global, HANDOFF et index générés. Risque applicatif nul pour cet audit documentaire. Rollback : retirer uniquement les ajouts de cet audit puis régénérer les index, en préservant PATCH1/PATCH2/PATCH3 et les autres travaux locaux.

<!-- AUTO-UPDATE:END id="hub341-paper-resume-roster-audit" -->
