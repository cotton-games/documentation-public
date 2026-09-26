# Corrections de score papier — Quiz / Blind Test

<!-- AUTO-UPDATE:BEGIN id="paper-score-corrections" owner="codex" -->
État : PATCH 2 local du 21/09/2026, non déployé. PATCH 1 validé en recette DEV selon l’utilisateur ; son identité et son roster restent le socle. [Rapport, preuves, tests et limites](../../notes/paper-score-patch2-2026-09-21.md).

## Identité et intention

`update_score` avec `remote_action=paper_score_update` sélectionne la correction explicite ; la session persistée doit être papier et non terminée. Le chemin gameplay conserve `GREATEST`. K=`player_id=p:UUID` est prioritaire exclusivement ; D=`playerId`/`player_db_id` fourni avec K doit correspondre à la même participation. Sans K, D résout la participation existante par son ID DB, puis restitue K explicitement. Le runtime compare D seulement à `playerDbId`. Conflit → `IDENTITY_CONFLICT`/`identity_conflict`, absence → `PLAYER_NOT_FOUND`/`not_found`, inactif → `PLAYER_INACTIVE`/`inactive`. Aucune insertion ni réactivation depuis un score.

## Persistance et retries

`request_id` (identique à `event_id` dans la Remote) reste stable pour une correction. Le helper PHP commun verrouille la session puis la participation, affecte exactement le score entier non négatif, relit la valeur et inscrit le reçu dans `game_events` (`action=paper_score_correction`) dans la même transaction. Le pré-enregistrement générique d’événement est contourné uniquement pour ces intentions de score. Pas de nouvelle table ni migration. Un même request ID rejoué rend le reçu d’origine sans écrire, même après une correction plus récente ou après la fin. Un request ID réutilisé pour une autre demande est refusé.

Réponse confirmée : `persisted=true`, `result=persisted`, `request_id`, `requested_score`, `confirmed_score`, `currentScore`, `player_id` K, `playerId` D, `requiresResync=true`. Une relecture non conforme refuse la correction et annule la transaction. `expected_score` optionnel permet un refus `SCORE_CONFLICT` ; la Remote sérialise ses HTTP au lieu d’estimer cet ancien score depuis un snapshot potentiellement ancien.

## Confirmation live

L’HTTP ne dépend d’aucun ACK WS. La Remote affiche « Score enregistré », conserve un indicateur discret « synchronisation en attente » et envoie `admin_set_score` avec le même request ID. Le runtime relit la participation via `remote_action=paper_score_read`, puis utilise l’hydratation PATCH 1 avec `reconcileScores=true`. Il ne fait jamais confiance au score ancien contenu dans une commande `persisted=true`. Un participant absent de mémoire peut être lié uniquement par le lecteur roster existant et ses gardes d’admission/activité.

Résultat WS `paper_score_correction_result` : `sessionId`, `request_id`, `result=applied|already_applied|superseded|not_found|inactive|identity_conflict|score_conflict|runtime_unavailable`, plus K/D et `confirmed_score` en succès. `superseded` signifie que l’état relu contient une autre valeur plus récente que celle du message. Réponse ancienne : ne clôture pas une nouvelle correction Remote. L’HTTP confirmé avance aussi le curseur PATCH1 pour rejeter les polls commencés avant la correction. En l’absence de réponse, l’indicateur reste visible ; retry corrélé toutes les5s et au clic, conservé en `sessionStorage` par jeu/session. Une incertitude HTTP conserve le même request ID et bloque une nouvelle correction jusqu’à confirmation ; un refus métier explicite permet une nouvelle saisie.

Les corrections runtime sont sérialisées par session. La maintenance papier PATCH 1 relit maintenant explicitement les scores persistés toutes les5s, sauf état suspendu/expiré/terminé/finalisation. L’hydratation roster ordinaire continue de conserver les scores en mémoire. Aucune nouvelle identité, source de calcul ou politique de roster.

## Finalisation

La Remote attend les HTTP engagés et refuse de finaliser si une persistance reste inconnue ; un WS absent ne remet pas en cause une persistance confirmée. Le moteur recharge roster et scores confirmés avant le classement canonique, capture `paper_score_snapshot` (K→score), puis appelle le `session_update` terminal existant.

Le bridge prend le même verrou de session que les corrections et compare intégralement les scores actifs persistés avec ce snapshot avant d’écrire statut/podium. Une correction concurrente acceptée entre relecture et finalisation fait refuser l’écriture par `PAPER_RECONCILIATION_REQUIRED` ; le moteur revient à `awaiting_score_validation`. Une correction arrivant après le commit terminal est refusée. Pas de recalcul parallèle en PHP, pas d’écrasement des scores persistés. Le compteur final papier compte les participations, même sans socket.

## Podium Hub Master (trois moteurs)

Le resolver de présentation conserve le podium exploitable de la session terminée sélectionnée, au lieu de le remplacer par le mode automatique de podium général lorsque toutes les sessions sont terminées ou suspendues. Modes explicites `hub_podium` et `hub_idle` et focus runtime vivant conservés. Ajouter une session prête n’est plus nécessaire pour cette présentation. Une fois le Hub terminé, fermer le podium général garde l’accueil jusqu’au prochain choix ; sélectionner une session terminée (carte, navigation ou intention Remote) revient immédiatement au mode `session` et affiche son podium disponible. L’initialisation passive conserve `hub_idle`. Aucun lancement, réouverture du Hub ou changement du focus runtime. La sélection/règle est commune, sans condition papier ni numérique.

Quiz/BT : `podium_json` terminal normalisé, repli historique depuis les scores si absent. Bingo : podium issu de `bingo_phase_winners` ; sa fin marque `phase_courante=999`, sans fabriquer des gagnants depuis le roster. Cette correction d’affichage ne modifie aucun winner Bingo.

## Observabilité

Événements bornés sans pseudo : `paper_score_correction_requested`, `paper_score_persisted`, `paper_score_runtime_applied|paper_score_runtime_failed`, `paper_score_reconciled`, `paper_finalize_reconciliation`. Le dernier indique le rechargement complet des corrections persistées ; ce n’est pas un compteur DB durable des ACK manquants. Sur rendu Master : `hub_session_podium_presentation` (session sélectionnée, mode/raison, terminé, podium disponible).

Limites : concurrence SQL vérifiée par structure transactionnelle et doubles PDO, pas par un vrai serveur MySQL ; pas de recette réseau/auth/navigateur. Les saisies de Remotes indépendantes sont ordonnées par leurs commits ; la causalité UI est garantie dans une Remote, et les retries d’une action déjà acceptée ne réécrivent jamais. Livraison coordonnée Games/Quiz/BT nécessaire ; les anciens finalizers papier sans snapshot sont explicitement refusés. Aucun changement Bingo D-only winner, équipes BT ou modèle équipe Hub.
<!-- AUTO-UPDATE:END id="paper-score-corrections" -->
