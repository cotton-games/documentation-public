# Inscription et roster papier — PATCH 1

<!-- AUTO-UPDATE:BEGIN id="paper-roster-contract" owner="codex" -->

### PATCH1B — autorisation bornée pendant la suspension

Lors d’une reprise papier explicite, le grant existant est créé avant l’ensure collectif. Un contexte serveur temporaire permet uniquement le `player_register` canonique du participant attendu. Games relit session/Hub/exécution/focus/génération/fenêtre/expiration et suspension libérée avec jeton valide. Aucun champ client ne remplace les deux contextes serveur. Aucune levée globale du gel : toutes les autres écritures restent bloquées et seul l’ACK moteur normal produit `hub_resumed`. La correction nécessite Global `app_games_hubs_functions.php` **et Games `php/hub_lifecycle.php`** ; pas de WS/marker modifié. [Diagnostic et validation](../../notes/paper-resume-patch1b-2026-09-21.md).



## PATCH1B — reprise officielle papier (21/09/2026, local)

Une reprise officielle papier garantit non seulement la continuité du runtime existant, mais également la convergence **Hub actif → participations moteur → runtime**. Avant le retour de reprise, Global appelle l’injection canonique aussi pour `resume_existing_runtime`. Les reprises avec exécution recréée conservent leur injection existante. Chaque actif admissible passe par le resolver/ensure existant : création si absent, liaison réparée si absente/obsolète, conservation K/D et scores, départ explicite non réactivé. Aucun second pipeline ni socket Player obligatoire. Numérique, démos et sessions définitivement terminées ne reçoivent pas cette nouvelle injection collective ; gardes de suspension/grâce conservées.

Le résultat `injection` expose `examined`, `created`, `existing`, `mapping_repaired`, `excluded`, `failed`, `complete`, ainsi que `failures` (ID Hub + code) et `exclusions` (ID Hub + motif). `mapping_repaired` est un sous-ensemble de `existing`, non une catégorie à additionner. `total_active`, `injected_count`, `already_count`, `failed_count` restent disponibles. Une lecture de population échouée produit un échec de lot, jamais une population vide réputée complète.

`paper_roster_reconciled` confirme uniquement participations/mappings. `runtime_reconciliation=pending` indique que PATCH1 doit encore les lire et publier ; aucun ACK runtime n’est inventé. À réception du bootstrap/reconnexion ou à la maintenance papier suivante (5s + latence, hors suspension), PATCH1 réalise la convergence. En cas d’échec individuel : `ok=true` de reprise peut être conservé, mais `paper_roster_reconciled=false`, `injection.complete=false`, `warning=PAPER_ROSTER_RECONCILIATION_PARTIAL` et message explicite. La reprise suivante réessaie idempotemment sans détruire l’exécution.

Log synthétique `hub_paper_resume_reconciliation` : Hub, session, exécution, six compteurs et `complete`. Diagnostics individuels via l’ensure existant et le bilan retourné. Cette garantie est conditionnée à des ensures réussis et à une lecture/runtime PATCH1 disponible ; un bilan partiel ne constitue pas une réconciliation complète. [Fichiers, tests et limites](../../notes/paper-resume-patch1b-2026-09-21.md).

État PATCH1 : **recette DEV validée selon l’utilisateur** (déploiement non effectué par cet agent). Concerne Quiz, Blind Test individuel et Bingo papier, Games commun et provenance Hub. [Rapport, fichiers, tests et limites](../../notes/paper-roster-patch1-2026-09-21.md).

## Identité

K = `p:UUID` canonique ; D = ID de participation moteur, secondaire. Une sélection historique transporte `participantType`, `sourceTable`, `sourceId`, K, et `id_ep_player` pour un joueur EP. `canvas_validate_participant_source` vérifie table autorisée, ID, relation historique au compte organisateur et cohérence de K ; le nom est relu sur la source. Un nom seul ne confère jamais de provenance. Les preuves EP résolues et le contexte serveur d’injection EP sont distincts des champs navigateur.

Global conserve les équipes sélectionnées dans `games_hubs_players.auth_identity_key=team:<ID>` avec `auth_type=guest` et K dans `player_token`. Les joueurs EP conservent `ep:<ID>` et `id_ep_player`. Les invités conservent `guest:<K>`. Aucun changement de schéma. Une ancienne ligne guest portant **exactement la même K** peut être adoptée lors d’une sélection explicitement validée ; aucun rapprochement par pseudo. La lecture par token conserve l’accès aux équipes guest typées.

L’injection Hub restitue la source typée au `player_register` moteur et conserve le mapping Hub/session. `USERNAME_REFERENCED` reste le refus d’une création libre au nom exactement réservé ; une proximité textuelle ne suffit pas. Remote Hub reçoit `free_guest_allowed` et `free_guest_message`, calculés avec la normalisation PHP canonique, sans seconde normalisation JavaScript.

## Population et bind

Les trois `players_get` live et leurs préloads partagent la lecture active : bonne session, `is_active`, K valide, déduplication par K et identité Hub admise, sans filtre score/socket. `canvas_hub_active_roster` est partagé avec l’admission ; la consultation live ne lance pas la synchronisation commerciale. `includeInactive` reste explicite pour historique/résultats ; les préloads terminés le demandent.

Après `player_register` réussi, y compris `already_active`, Remote envoie `admin_player_register`. Le handler lit les participations persistées, privilégie K, contrôle D fourni et répond `paper_player_bound.state=bound|already_bound|not_found|inactive|conflict`. Il ne crée pas de participation et ne réactive pas un inactif. Les commandes de score ne participent pas à ce bind.

Quiz/BT réutilisent leur hydratation, sérialisent les lectures concurrentes, attachent les K manquantes et conservent les scores runtime existants. Une lecture live couvrante retire les identités absentes de la population persistée/admissible. Bingo partage également son lecteur d’hydratation avec le bind et conserve les grilles déjà mémorisées.

Déclencheurs : bootstrap/reconnexion Organizer, bind explicite et maintenance papier bornée à **5 secondes**, jamais chaque tick. Cette maintenance récupère les participations moteur issues des ajouts Hub tardifs sans socket joueur ; la route Remote Hub assure immédiatement participation/mapping lorsque son focus papier est vivant. Les sessions suspendues/expirées/terminées ne sont pas réactivées par la maintenance. Les lectures invalides ne produisent pas d’autorité de suppression.

## Snapshots Remote et Master

`roster` porte `sessionId`, `executionId` lorsqu’il existe, `generation`, `revision`, `source`, `reconciled`, `authoritative`, éventuellement `removed:[K]`. Les publications Quiz/BT couvrantes et le compteur Bingo après réconciliation portent l’autorité ; un top tronqué et les autres états restent partiels. L’autorité est consommée après la publication réconciliée, pas réutilisée sur un état ultérieur non vérifié.

Une absence supprime uniquement sous autorité explicite, dans la bonne session/exécution et une révision non ancienne. Un retrait explicite utilise les mêmes clôtures d’ordre/contexte. Un snapshot court partiel fusionne les lignes sans supprimer les absentes ; ce n’est pas une union permanente puisque les snapshots réconciliés/removals retirent les identités. Les HTTP Master/Remote prennent un compteur local avant la requête : une réponse revenant après une modification acceptée est rejetée.

Master applique joueurs/classement/compteur dans un seul patch de store. Remote calcule son compteur depuis le roster accepté. Les équipes Blind Test restent une projection distincte, avec compte de membres et `rankingEntriesTotal` ; une lecture d’individus n’écrase pas une projection d’équipes. Le chantier équipes reste désactivé. La protection Bingo vide après fin reste présente. Le comportement historique des listes numériques hors papier est conservé.

Logs : `PAPER_ROSTER_RECONCILED`, `PAPER_PLAYER_BIND`, `PAPER_ROSTER_PROJECTION` ; session/moteur/source/génération/révision, volumes, acceptation/rejet, suppressions et raison ; K/D pour le bind, aucun pseudo ajouté aux nouveaux diagnostics.

## Hors périmètre

Le [PATCH2 score](paper-score-corrections.md) traite séparément K/D, baisse, confirmation live et finalisation. Il réutilise cette hydratation avec une option explicite de relecture autoritaire des scores, notamment dans la maintenance5s ; l’hydratation ordinaire conserve les scores en mémoire. Population/provenance/K/autorité du roster restent inchangées. Bingo D-only winner et activation des équipes Blind Test restent hors périmètre.
<!-- AUTO-UPDATE:END id="paper-roster-contract" -->
