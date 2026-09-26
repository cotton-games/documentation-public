# Sessions retirées d’un Hub : visibilité WWW et Play

<!-- AUTO-UPDATE:BEGIN id="hub-public-removed-sessions-20260922" owner="codex" -->

## Statut et diagnostic

Correctif du 22/09/2026 dans les worktrees Global, WWW et Play sur `main`. **Déploiement PROD prévu par l’opérateur, confirmation de réalisation attendue.** L’annonce « je vais déployer » indique une intention ; aucune livraison ni recette production n’est encore confirmée. Il est postérieur au lot `hub_soiree` annoncé livré par l’opérateur. `sas_players` et `cast` restent hors PROD.

Les lecteurs publics interrogeaient `championnats_sessions` sans reprendre le filtre de navigation Pro. Une session conservée pour son historique après retrait pouvait donc réapparaître dans un agenda, une fiche établissement ou une ancienne URL. Le service de suppression et les données ne sont pas modifiés.

## Critère partagé

Réutilisation de `app_games_hub_pro_navigation_session_sql` : une session est visible si elle possède une membership active vers un Hub actif, non `deleting`, du même client ; sinon, elle doit n’avoir **aucune membership** et **aucun événement `hub_execution_removed`** corrélé par `id_securite`. Un rattachement actif valide prime sur une ancienne trace de retrait. Membership inactive, racine absente/inactive/en suppression ou propriétaire incohérent ne deviennent pas des sessions autonomes.

La trace durable couvre la suppression physique ultérieure du Hub et de ses memberships. Si toute preuve de provenance a disparu, une ancienne session Hub est indiscernable d’une vraie session autonome : aucun filtrage par date, nom ou client n’est inventé.

## Fichiers et surfaces

- Global `web/app/modules/jeux/sessions/app_sessions_functions.php` : import du helper SQL existant ; filtre dans `app_sessions_get_liste` pour les lectures publiques seules (`publique=1`, `privee=0`), avant regroupement/limite ; nouveau lecteur `app_session_hub_navigation_is_visible` pour les pages individuelles.
- Global `web/tests/hub_public_navigation_test.py` : régression des vrais lecteurs PHP sur fixtures SQLite.
- WWW `web/fo/modules/entites/clients/fr/fo_clients_view_shared.php` : filtre des dates paginées et des sessions à venir, avant LIMIT.
- WWW `web/fo/modules/entites/clients/fr/fo_clients_list.php` : compte et tri d’activité publique cohérents.
- WWW `web/fo/modules/jeux/sessions/fr/fo_sessions_seo.php` : contrôle avant enrichissement/rendu ; ancienne URL retirée redirigée vers `/{langue}/agenda`.
- Play `web/ep/modules/jeux/sessions/ep_sessions_seo.php` : même contrôle ; redirection vers `/extranet/games`.

Le lecteur partagé couvre agendas, widgets, pages jeux/événements, suggestions et archives publiques d’établissement. Les lecteurs mixtes/privés de statistiques, `app_session_get_detail`, l’historique personnel Play et les résultats conservés ne sont pas modifiés. Ce filtre de présentation ne remplace pas les contrôles de publication, d’authentification ou d’admission au jeu.

## Validation locale

Depuis le workspace Cotton :

```sh
python3 global/web/tests/hub_public_navigation_test.py
python3 global/web/tests/hub_pro_navigation_test.py
php play/web/tests/ep_session_hub_cta_test.php
php play/web/tests/ep_hub_detail_contract_test.php
php global/web/tests/session_results_podium_contract_test.php
```

Résultats : 41 contrôles publics / 39 SELECTs, 49 contrôles Pro / 148 SELECTs, 411 contrôles CTA/intégration puis auth organisateur OK, contrats détail Hub et podium OK. Lint des cinq fichiers PHP modifiés OK. Fixtures : standalone, rattachement actif, inactif, trace sans membership, racine orpheline/inactive/en suppression, autre propriétaire, rattachement actif avec ancienne trace, pagination, anciennes URL, suppression physique ultérieure et conservation des lignes historiques.

Aucun serveur, navigateur, SSH, MySQL réel, déploiement ou restart utilisé. Recette restante : retirer une session d’un Hub de test puis vérifier WWW/Play, fiche établissement et anciennes URL ; garder visibles une session autonome et un membre actif ; vérifier l’historique personnel. La performance des sous-requêtes `NOT EXISTS` sur les volumes réels reste à observer, sans migration d’index dans ce lot.

## Livraison et rollback

Livrer Global avant (ou avec) WWW et Play, car leurs lecteurs appellent le helper partagé. Aucun changement de schéma ou de processus WS. Retour arrière : retirer ces ajouts de lecture sur WWW/Play avant Global ; aucune restauration de données nécessaire. Ce rollback réexpose les sessions retirées.

README/TASKS Global/WWW/Play, HANDOFF, CHANGELOG, état de livraison et routage R26 mis à jour dans leurs blocs ; index régénérés par `npm run docs:sitemap`.

## Sources et précautions d’intégration

Sources RAW consultées avant modification : [SITEMAP — How to use](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md), [README — discipline documentaire](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/README.md), [DOCS_MANIFEST — routing](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md), [HANDOFF — actions Hub/Pro](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/HANDOFF.md), [WWW README](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/www/README.md), [Play README](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/play/README.md). [Audit Pro et preuve durable](hub-empty-pro-navigation-2026-09-22.md).

Journal AI Studio relu : modifications externes signalées notamment sur les vues/cartes WWW, `.htaccess`, sitemap et header. Ces fichiers ne sont pas modifiés dans ce lot ; aucun rechargement ciblé nécessaire sur les cinq lecteurs retenus. Aucun commit, merge ou push effectué.

<!-- AUTO-UPDATE:END id="hub-public-removed-sessions-20260922" -->
