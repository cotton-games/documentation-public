# PATCH1B — réconciliation des inscrits Hub à la reprise papier

<!-- AUTO-UPDATE:BEGIN id="paper-resume-patch1b-report" owner="codex" -->

### Correction de recette — suspension pendant la reprise (21/09/2026)

Les reprises réelles21:19:14 et21:19:54 du Hub341 sélectionnent20 actifs (`games/logs/error_log:73564`, `73683`), mais le dispatcher refuse des inscriptions avec `HUB_SESSION_SUSPENDED` (exemples73565–73567). La première version PATCH1B avait testé un dispatch simulé : la garde Canvas réelle n’était pas couverte. Le bilan récapitulatif n’est pas visible dans ces logs tronqués ; la sélection20 et les refus sont, eux, explicites.

Correction locale : Global émet le grant de reprise avant l’ensure collectif et installe un contexte serveur temporaire, retiré/restauré en `finally`. Games autorise uniquement `player_register` issu de cet ensure avec les deux contextes serveur concordants (reprise + participant), session papier officielle non terminée, focus/Hub/exécution/génération courants, fenêtre ouverte, absence d’expiration, suspension libérée et jeton de reprise valide. Les champs navigateur ne constituent pas cette autorité. Les scopes historiques alternatifs ne sont pas admis dans cette exception.

Aucun `hub_resumed` anticipé : la suspension reste vraie jusqu’à l’ACK normal du moteur. Score, phase, grille, fin, reset et inscriptions ordinaires restent bloqués pendant la suspension, même si un contexte de reprise existe. Le pipeline d’inscription et PATCH1 restent uniques.

Le test emploie maintenant le vrai `game_api_dispatch`, la vraie garde `canvas_hub_suspended_write` et le vrai générateur de grant, avec I/O simulées. Le cas suspendu/libéré échoue sur la version PATCH1B précédente, puis passe avec la correction. Vérifications supplémentaires : contexte nettoyé, champs navigateur forgés, mauvais joueur/session/Hub/exécution/génération/jeton, départ non libéré, numérique/démo/terminé, focus/fenêtre/provenance/expiration invalides, autres actions toujours bloquées. Les fixtures de reprise suspendue alimentent les vraies maintenances3 moteurs.

**Livraison de cette correction : deux fichiers applicatifs**, Global `web/app/modules/jeux/hubs/app_games_hubs_functions.php` et Games `web/includes/canvas/php/hub_lifecycle.php`. La livraison Global seule ne suffit plus. Aucun fichier WS ni marker modifié, aucun restart requis par ce lot. Aucun déploiement/DB réelle exécuté par l’agent.



Implémentation locale du21/09/2026. Aucun déploiement, restart, SSH, navigateur ou accès DB réel. Le [diagnostic Hub341](hub341-paper-resume-roster-audit-2026-09-21.md) repose sur les copies de logs et les résultats SQL fournis par l’utilisateur :20 actifs Hub,18 participations Quiz27925/1648 ; mustach1132 et Jiji1133 sans participation ni mapping. Leur réparation réelle n’a pas été exécutée.

## Comportement final

Le retour anticipé `resume_existing_runtime` contournait l’injection collective. Global appelle maintenant `app_games_hub_session_inject_active_players` avant ce retour pour le papier officiel. Il utilise le resolver et les ensures existants ; aucune création SQL parallèle ni bind WS ajouté. Numérique et démos ne passent pas par cet appel. Le refus initial d’une session terminée et les gardes de suspension/grâce restent en place.

La boucle collective distingue création, participation existante, réparation d’un mapping, exclusion légitime et échec. Un départ explicite `mapping.status=left` n’est pas réactivé. L’admission reste dans le chemin canonique. Les scores existants et associations sont conservés. Une erreur de lecture des inscrits n’est pas interprétée comme un Hub vide ; une exception individuelle ne bloque pas le traitement des suivants.

La réponse de reprise conserve `ok=true` si l’exécution reste reprenable, indépendamment du succès collectif. `injection.complete` et `paper_roster_reconciled` distinguent succès et échec ; en cas partiel, code `PAPER_ROSTER_RECONCILIATION_PARTIAL` et message invitant à réessayer la reprise. Une reprise recréant l’exécution expose également le caractère partiel de son injection préexistante.

`runtime_reconciliation=pending` est explicite : la réponse confirme la persistance, jamais une réception WS non vérifiée. PATCH1 reste responsable de la lecture active, hydratation et publication par reconnexion/maintenance5s. Aucun socket joueur n’est nécessaire ; un Organizer/runtime disponible et des lectures réussies le restent. Aucun mécanisme concurrent de bind/hydratation n’a été ajouté.

## Bilan

| Champ | Sens |
|---|---|
| `examined` | Actifs Hub examinés dans la population lue |
| `created` | Participations créées par l’ensure canonique |
| `existing` | Participations retrouvées, y compris mappings réparés |
| `mapping_repaired` | Sous-ensemble des existants avec liaison réparée |
| `excluded` | Départs/statuts exclus et refus d’admission reconnus |
| `failed` | Ensures échoués ; ou1 échec de lot si lecture population impossible |

`failures` fournit ID Hub et code ; `exclusions` fournit ID Hub et motif. En succès de lecture, `examined=created+existing+excluded+failed` ; ne pas additionner `mapping_repaired` une seconde fois. Les champs historiques `total_active`, `injected_count`, `already_count`, `failed_count` sont conservés ; les exclusions ne comptent plus comme une injection réussie. Le log `hub_paper_resume_reconciliation` porte l’identité Hub/session/exécution, les compteurs et `complete` pour la reprise existante. Les traces ensure existantes portent les résultats individuels. Les logs FastCGI peuvent toujours subir la troncature constatée ; le bilan structuré retourné constitue une autre source de diagnostic.

## Fichiers applicatifs et tests

Global :

- `web/app/modules/jeux/hubs/app_games_hubs_functions.php` : boucle collective et retours de lancement/reprise.
- `web/tests/hub_paper_resume_reconciliation_test.php` : nouveau test des fonctions réelles avec doubles PDO/mysqli/Canvas et stockage en mémoire ; peut exporter les fixtures produites.
- `web/tests/hub_remote_control_contract_test.php` : ancien libellé « reprise sans injection » corrigé ; assertion de l’injection papier et du résultat partiel.

Games :

- `web/includes/canvas/php/hub_lifecycle.php` : autorisation interne bornée de l’ensure papier en reprise suspendue.
- `web/tests/paper_resume_runtime_test.cjs` : récupère les fixtures du test PHP puis exécute les vraies maintenances PATCH1 Quiz/BT/Bingo sous VM.
- `web/tests/paper_resume_patch1b_suite.mjs` : point d’entrée des validations locales.

Aucun code moteur, handler de score, schéma ni fichier de configuration changé. La garde de suspension PHP reçoit l’exception strictement scoped décrite ci-dessus. Aucun marker WS à incrémenter dans ce lot. Les modifications préexistantes PATCH1/PATCH2/PATCH3 sont conservées.

## Validation

Depuis Cotton :

```sh
node games/web/tests/paper_resume_patch1b_suite.mjs
```

Résultat : **6/6 groupes verts**, incluant :

- 876 contrôles PHP :20/18→20, seconde reprise, scores conservés, mapping absent/obsolète, départ avec participation existante inactive ou absente, refus d’admission, exception individuelle, bilan partiel/retry, erreur de lecture collective, numérique/démo/terminé exclus, suspension non libérée bloquée et reprise libérée, exécution recréée partielle ; chacun sur les3 types de jeu papier.
- Trois moteurs PATCH1 réels sous VM alimentés par le résultat du flux Global : runtime18→20 et publication, sans socket joueur, retry sans doublon ; scores Quiz/BT et grille associée Bingo conservés. Transport Canvas et diffusion réseau simulés.
- Contrat Remote Global, garde runtime expiré213 vérifications et lifecycle/dispatcher suspendu77 vérifications.
- PATCH2 **8/8**, incluant PATCH1 **14/14**.

Lints PHP4 fichiers, syntaxe Node2 fichiers et `git diff --check` validés. Le nouveau test échoue sur la copie Global avant PATCH1B : la reprise laisse18 participations. Ces tests ne constituent pas une validation de vraies transactions SQL, de concurrence interservices ou du déploiement chargé sur DEV.

## Risques, recette restante et rollback

Chaque reprise papier parcourt tous les actifs : coût proportionnel au nombre d’inscrits, avec verrous/contrôles canon existants. Un refus persistant peut nécessiter la résolution de son motif avant un retry réussi. La disponibilité runtime et la latence de PATCH1 restent distinctes du succès de persistance. Le patch ne réactive pas les départs explicitement enregistrés dans les mappings ; il ne reconstruit pas l’historique de départs dont la trace aurait été supprimée.

Recette réelle restante après livraison séparée : reprendre Quiz27925 avec mustach/Jiji admissibles, vérifier20 participations/mappings, puis20 sur Master/Remote ; reprendre une seconde fois et comparer identités/scores. Aucun résultat réel20 n’est annoncé dans ce rapport.

Rollback : retirer uniquement les changements PATCH1B dans Global et les tests/docs associés, sans écraser PATCH1/PATCH2/PATCH3. Pour retirer uniquement la correction de suspension : copies `/tmp/patch1b-suspension-before-global` et `/tmp/patch1b-suspension-before-lifecycle` (temporaires). Copie de la source applicative avant PATCH1B : `/tmp/patch1b-global-before.php` (temporaire ; contient les patches antérieurs). Un rollback de code ne supprime pas les participations déjà créées ; aucune suppression de données nécessaire. Régénérer les index après retrait des entrées documentaires.

Docs mises à jour : contrat papier, bridge, README/TASKS Games/Global, TASKS Quiz/BT/Bingo, HANDOFF/CHANGELOG et index. Routing existant R24. Entrées publiques START/SITEMAP/README/Manifest/HANDOFF et journal AI Studio relus avant patch ; aucun fichier ciblé signalé modifié dans ce journal, sans en déduire une parité distante.

<!-- AUTO-UPDATE:END id="paper-resume-patch1b-report" -->
