# Procédure restaurée — promotion Hub vers main, 09/09/2026

Document reconstitué après suppression accidentelle, à partir de la préparation précédente et des commits Git identifiés. Aucun merge, push, transfert PROD ou redémarrage effectué lors de cette restauration. Les références de la préparation sont conservées ci-dessous. Extension Blindtest/Quiz contrôlée le09/09 pour la copie manuelle prévue le10/09 au matin ; aucune action serveur maintenant.

## État préparé

L’opérateur a confirmé une **copie manuelle après merge** : les merges locaux ne déclenchent pas de déploiement et ne touchent pas les sessions en production.

| Repo | main avant | source hub_soiree préparée | Validation précédente |
| --- | --- | --- | --- |
| Global | 371cd6ca3f2359299425115dc7439141386007e3 | 2546c24d87e33167013d184d882187d5601d2cf5 | Fusion simulée sans conflit |
| Games | 193deb8eb30616018c6de4aa88c3f072874b4dbe | e660eb40d387890e7883b8431a8c0278b8d3498d | Fast-forward possible |
| Pro | c1143b0d585fdc028e5c45a7d64a70fef09aba07 | 536e6c24126263d72767138a7489fdce2513c003 | Fast-forward possible |
| Blindtest | 993900e41c98766f2869702c035d27a286061c52 | 993900e41c98766f2869702c035d27a286061c52 | Déjà sur main, worktree propre, aucun diff |
| Quiz | 66b2646e12e7e20432361e25cccd94c914057178 | 66b2646e12e7e20432361e25cccd94c914057178 | Déjà sur main, worktree propre, aucun diff |

Global nécessite une fusion réelle, pas un reset sur Hub. L’arbre simulé `1a7b394acd0dce84f29273e0287e225b812557ae` conserve les401 chemins de cache PHP QR propres à main ; hors caches, le candidat est identique aux sources Hub testées. Aucun cache à supprimer ou à transférer.

La tentative de changement de branche par Codex avait échoué : `.git/index.lock: Read-only file system`. Les commandes ci-dessous doivent être exécutées dans le terminal de l’opérateur, où les `.git` sont inscriptibles.

## 1. Fusions locales terminées par l’opérateur

**Actualisation après confirmation opérateur : les cinq repos sont sur main et propres.** Games/Pro/Blindtest/Quiz correspondent aux SHA source du tableau. Global main vaut désormais `e6527b811a8ab3c03cdebb1883bd1947c366d21f` ; ses trois fichiers applicatifs correspondent aux empreintes préparées. Les18 empreintes des deux manifestes ont été comparées avec les main actuels : conformes. Aucun push/synch ni copie serveur selon l’opérateur. Aucune fusion supplémentaire à exécuter.

Contrôle disponible demain matin :

```sh
for repo in global games pro blindtest quiz; do
  git -C "/home/romain/Cotton/$repo" status --short
  git -C "/home/romain/Cotton/$repo" rev-parse main hub_soiree
done
```

Si les références diffèrent de cette actualisation ou si le statut n’est pas propre, revoir le delta avant de continuer. Ne pas écraser de modifications locales.

**Historique des commandes de fusion préparées, désormais sans action à effectuer :**

```sh
set -e

git -C /home/romain/Cotton/global switch main
git -C /home/romain/Cotton/global merge --no-edit hub_soiree

git -C /home/romain/Cotton/games switch main
git -C /home/romain/Cotton/games merge --ff-only hub_soiree

git -C /home/romain/Cotton/pro switch main
git -C /home/romain/Cotton/pro merge --ff-only hub_soiree
```

Blindtest et Quiz sont déjà sur main au même commit que Hub : aucune fusion supplémentaire nécessaire. Un diff Git vide ne prouve pas que le serveur PROD est à jour.

Ces commandes n’incluent ni push ni transfert serveur. Après fusion, vérifier `git status`, la branche courante, l’absence de conflit et les empreintes des sources à livrer.

## 2. Manifeste de copie

[CSV des14 fichiers applicatifs, commits et SHA256](hub-main-promotion-2026-09-09.csv).

- Global :3 sources — fonctions Hub, programmation SchedulePlan, suppression individuelle.
- Games :7 sources — reprise Master, Organizer, retour Remote, confirmation papier et terminologie équipes.
- Pro :4 sources — script de programmation, helper brouillon, script Bibliothèque, vue Dashboard.

Les tests restent dans Git mais ne sont pas à transférer en PROD. Aucun fichier WS, configuration serveur, package Node ou migration SQL ne fait partie de ce lot initial Global/Games/Pro. Les correctifs WS Blindtest/Quiz sont traités séparément en section7. Aucun transfert de dossier complet, aucun cache QR, aucune purge ou backfill.

Le manifeste est calculé sur les commits préparés, pas sur une copie serveur. Après fusion, les14 sources de main doivent avoir les mêmes SHA256. Les éventuelles autres différences de Global concernent les caches main conservés. Un nouveau commit impose de recalculer le paquet.

## 3. Préserver les sessions en cours

**Faire les merges maintenant est indépendant de la PROD. Pour la copie manuelle, attendre la fin des parties et commandes en cours.**

Un navigateur déjà chargé conserve normalement son JavaScript, mais les prochains appels PHP, une reprise Master/Remote, une reconnexion ou un rechargement peuvent rencontrer le nouveau code. Global change précisément la reprise d’exécution active et Games doit reconnaître cette reprise pour restaurer Pause sans auto-start. Une copie partielle des fichiers ne garantit donc pas le zéro impact.

Vérifier les sessions réellement actives avec l’exploitation, y compris démos, reprises, commandes et programmations en cours. L’absence de cartes Agenda ou de memberships n’est pas une preuve d’absence de runtime. Aucun contrôle DB/WS PROD ni dispositif de drain n’est disponible dans cette préparation.

Si des sessions doivent impérativement continuer pendant le transfert, qualifier d’abord en DEV les versions mixtes ancien navigateur/nouveau backend et le mécanisme réel de bascule. Les tests locaux ne certifient pas une copie à chaud.

## 4. Copie manuelle ultérieure

1. Vérifier les fichiers effectivement servis en PROD et le journal AI Studio : toute modification externe doit être réconciliée avant écrasement. Les chemins physiques de release PROD ne sont pas attestés ici. Sauvegarder les fichiers remplacés ; noter le nouveau helper Pro `ec_start_schedule_draft_helpers.php`.
2. Attendre la fenêtre sans parties/commandes en cours. Préparer les fichiers complets hors des chemins servis puis, si l’outil le permet, remplacer chaque fichier atomiquement. Cette atomicité par fichier ne rend pas les14 remplacements atomiques ensemble.
3. Livrer **Global**, puis **Games**, puis **Pro**, dans la même fenêtre coordonnée. Dans Pro, poser le nouveau helper brouillon avant ses appelants. Ne pas redémarrer les WebSockets pour ce seul lot PHP/JS. Si les correctifs Blindtest/Quiz doivent aussi être activés, suivre ensuite la section7, pendant la même fenêtre sans sessions.
4. Vérifier les caches pour les prochains chargements : Organizer référence `boot_organizer.js` et `hub_transition.js` avec `CANVAS_ASSET_VER`; Remote UI ajoute filemtime. Vérifier la stratégie/version PROD et OPcache/CDN sans remplacer la config PROD par celle de DEV. Ne pas forcer le rechargement d’un client en partie.
5. Recette : ajout/suppression dernière session/reprogrammation même date et même Hub ; brouillon configuré conservé ; Dashboard Ajouter sur le Hub exact ; confirmation papier et annulation ; reprise active même execution_id, nouvelle génération, Master en Pause, Remote correctement rattachée. Surveiller les erreurs PHP et les logs de réconciliation/compensation.

Aucun restart n’est requis par le lot initial Global/Games/Pro lui-même ; cette affirmation ne couvre pas l’activation de nouvelles sources WS Blindtest/Quiz. Le schéma et les ensures existants n’ont pas été vérifiés sur DB PROD dans cette préparation : absence de migration dans le delta ne constitue pas une preuve de conformité serveur.

## 5. Validation précédente

Les11 commandes suivantes ont passé lors de la préparation, avant suppression du document. Elles ne sont pas déclarées réexécutées lors de sa restauration.

```sh
# depuis games
php web/tests/hub_active_resume_test.php
node web/tests/hub_active_resume_test.mjs
node web/tests/hub_remote_paper_confirmation_test.mjs
node web/tests/hub_remote_paper_recovery_test.mjs
node web/tests/hub_remote_paper_teams_test.mjs
node web/tests/hub_launch_confirmation_test.mjs
node web/tests/hub_remote_return_execution_test.mjs
node web/tests/hub_transition_remote_test.mjs
# depuis global
php web/tests/schedule_plan_empty_hub_test.php
# depuis pro
php web/ec/modules/tunnel/start/ec_start_dashboard_quick_source_hub_test.php
php web/ec/modules/tunnel/start/ec_start_library_hub_add_flow_test.php
```

Dont42 contrôles reprise active,46 récupération,14 confirmation papier,12 terminologie,52 réconciliation et38 source Hub. Syntaxe PHP/JS et diff checks étaient verts. Stockage/transport simulés, aucun test DB/WS connecté ou navigateur PROD. Deux assertions statiques SchedulePlan et une assertion SSR démo avaient des échecs préexistants documentés ; elles ne sont pas déclarées vertes ici.

## 6. Rollback

Préserver le lot cohérent sauvegardé Global/Games/Pro. Si retour nécessaire, fermer les nouvelles entrées pendant la restauration ; conserver le nouveau helper Pro tant qu’un appelant peut encore le charger. Aucun rollback SQL ni purge automatique. Les sessions créées sont des données métier à conserver. Ne pas redémarrer les WS pour revenir sur ces fichiers PHP/JS.

## 7. Blindtest et Quiz — copie/activation WS du10septembre au matin

### Git déjà prêt, état PROD à distinguer

Contrôle actuel : `main == hub_soiree`, worktree propre, pour Blindtest993900e et Quiz66b2646. Les derniers commits modifient chacun `web/server/actions/connection.js`, `web/server/restart_serveur.txt` et un test. Le correctif évite qu’une déconnexion Remote/secondary termine une session pendant la grâce de reconnexion du Master. Le marker cible est `restart 09-09-2026/01` dans les deux dépôts.

L’opérateur confirme que le reste est à jour en PROD et qu’il vient de merger sans synch ni copies serveur. Cette information permet de retenir le dernier correctif de grâce seulement. Le serveur n’a pas été inspecté directement ; un marker ou un SHA Git local ne prouve pas à lui seul la version chargée en mémoire par Node.

[Manifeste WS : quatre fichiers avec SHA256](hub-main-promotion-2026-09-09-ws.csv). L’opérateur confirme le reste à jour en PROD, et le merge sans synch ni copie serveur. Le lot retenu est donc celui du dernier correctif : ces4 fichiers complètent les14 fichiers Global/Games/Pro, soit18 fichiers prévus au total :

| Repo | Si seul le dernier correctif de grâce manque |
| --- | --- |
| Blindtest | `web/server/actions/connection.js`, puis `web/server/restart_serveur.txt` |
| Quiz | `web/server/actions/connection.js`, puis `web/server/restart_serveur.txt` |

Le lot minimal est retenu sur la confirmation de l’opérateur. Au transfert, vérifier ses empreintes et sauvegarder les versions remplacées. Si cette confirmation est contredite par les fichiers serveur, arrêter et recalculer le delta ; ne pas compléter le lot au hasard.

Hors du lot retenu, puisque le reste est confirmé à jour : le commit Blindtest précédent67f6cb0 du08/09 désactive les équipes par `features.js` et les handlers `actions/gameplay.js`, `actions/teams.js`, `actions/wsHandler.js`. Ces quatre sources ne sont pas à recopier dans ce lot. Si leur présence serveur s’avère différente de la confirmation, réévaluer séparément le paquet. Garder `BLINDTEST_TEAMS_ENABLED=false`. Quiz et Blindtest ont aussi des évolutions gameplay/fin Hub plus anciennes : leur présence PROD est ici fondée sur la confirmation opérateur, pas sur le seul dernier commit.

### Séquence sans interrompre une partie

1. Demain matin, confirmer fin des sessions des DEUX jeux, y compris papier, numérique, démos, sessions en Pause, grâce de reconnexion et commandes en cours. Éviter de nouveaux lancements pendant la fenêtre. Ne pas déduire l’inactivité de la seule absence de sockets Master/Remote : la grâce conserve volontairement une session active sans ces connexions.
2. Identifier le compte système et les processus PROD réels. Les fichiers PM2 locaux des deux repos nomment l’app `server`, avec cwd=`web/server`. Ne pas employer `pm2 restart all` ni le seul nom ambigu `server`. Les ports locaux3031/3032 et chemins DEV ne sont pas une identification suffisante de PROD.
3. Vérifier le mécanisme serveur de surveillance/redémarrage avant de copier le marker ou des sources. Les manifests PM2 locaux ne déclarent pas watch et aucun lecteur local du marker n’a été trouvé dans les JS/CJS de web/server ; un automate externe PROD reste possible. Copier le marker en dernier n’empêche pas un watcher externe de réagir dès le premier JS.
4. Sauvegarder les seules sources à remplacer et leur configuration actuelle. Ne pas écraser `.env`, configs, PM2, `node_modules`, logs ou données de session par une copie globale du workspace. Le dernier correctif ne change aucun package ni schéma.
5. Livrer Global/Games/Pro selon la section4 avant d’activer de nouvelles sources WS qui en dépendent. Préparer le lot WS complet hors des chemins servis, poser ses sources et dépendances, puis le marker en dernier, dans la fenêtre sans parties. Si une surveillance automatique redémarre sur copie, utiliser la procédure d’exploitation existante pour éviter une activation avant la fin du lot.
6. Activer chaque version WS une seule fois avec le mécanisme PROD vérifié : restart ciblé du bon processus OU automate existant. Ne pas cumuler les deux. Les CommonJS déjà chargés ne sont pas remplacés par la seule copie ; un restart est normalement nécessaire pour charger le nouveau handler. Ne pas présenter un reload PM2 comme une conservation garantie des sessions.
7. Vérifier état/processus/logs, puis recette Blindtest et Quiz séparément avant réouverture : lancement, déconnexion Master suivie de Remote, reconnexion Master pendant la grâce, conservation de l’exécution/joueurs/scores ; quit explicite toujours terminal. Tester papier et numérique, Hub et hors Hub selon les usages. Blindtest reste individuel, équipes OFF. Contrôler fin de partie et retour Hub.

Pour repérer les processus depuis le bon compte PROD, `pm2 list`, puis `pm2 describe` sur l’ID vérifié ; confirmer notamment le cwd et la commande. Aucun ID/chemin PROD n’est inventé ici et aucune commande de restart générique n’est fournie comme exécutable sans cette vérification.

### Pourquoi attendre la fin des sessions

Dans les deux repos, `web/server/resources/sessions.js` exporte `const sessions = {}`. Les sessions actives sont donc portées par la mémoire du processus. Un restart interrompt les connexions et perd cette mémoire ; les tests ne prouvent aucune reconstruction complète après redémarrage. La grâce de reconnexion de1heure protège une déconnexion client pendant que le processus vit, pas un restart du serveur.

### Tests exécutés pour cette extension

- Blindtest : `node --test tests/primary-grace.test.cjs` →44/44 verts.
- Quiz : même commande →44/44 verts.
- Blindtest : `node --test tests/teams-disabled.test.cjs` →15/15 verts.

Horloge/transport/DB simulés ; aucun processus PROD touché. Aucun merge, push, copie ou restart effectué. Vérification Git et18 empreintes faites sur les main actuels ; périmètre du retard PROD fondé sur confirmation opérateur. Aucun contrôle serveur direct.

### Rollback WS

Attendre/maintenir la fenêtre sans sessions, restaurer le lot WS sauvegardé cohérent, puis activer une seule fois le bon processus avec le mécanisme vérifié. Conserver les dépendances Global/Games compatibles. Un rollback de code ne restaure pas la mémoire d’un runtime détruit ; ne pas tenter ce rollback en pleine partie comme une opération transparente.
