<!-- AUTO-UPDATE:BEGIN id="hub-capacity-upsell-20260921" owner="codex" -->
# Jauge Hub et upsell — 21/09/2026

Statut : patch local, non déployé. Aucun accès DB, SSH, environnement distant d’exécution, restart ou migration. Documentation RAW et journal AI Studio consultés ; aucun signal de fichier cible modifié hors workspace relevé. Modifications locales antérieures conservées.

## Contrat

L’offre effective est l’autorité commerciale de jauge. `app_client_player_capacity_resolve()` réutilise exclusivement `app_ecommerce_offre_effective_get_context()` ; il ne sélectionne pas une offre alternative. Il distingue offre inactive, jauge absente, référentiel absent, capacité invalide et erreur DB. Aucun fallback commercial silencieux 100/200.

Le Hub accepte au maximum N joueurs actifs. Guests, EP et papier partagent le même compteur. Les probables ne consomment pas de place. `left` libère une place ; une réactivation nécessite une place disponible. Une identité déjà active reprend sans nouveau débit et sans nouvelle résolution commerciale dans l’upsert, en conservant les validations d’identité/pseudo existantes et le renouvellement du retour EP.

Le contrôle réside dans `app_games_hub_player_upsert()` sous `GET_LOCK('hub_admission_<id>', 5)` sur la connexion mysqli du roster : identité relue, capacité fraîche, compteur confirmé, écriture puis relecture. Les départs/unregister utilisent le même verrou. `finally` libère le verrou, y compris sur refus/exception. Le verrou existant de réservation publique des pseudos reste distinct ; aucune suppression de ces protections. La primitive convient au schéma MyISAM déclaré, sans migration. Tous les écrivains doivent partager le même serveur SQL et cette primitive.

Erreur de plein : `HUB_CAPACITY_REACHED`, « La soirée est complète. » ou « L’événement est complet. ». Guest/Remote transmettent le résultat Global ; le retour EP conserve son interface URL et redirige vers la fiche EP Hub avec ce code, affiché comme refus de capacité.

## Snapshots et runtime

Les sessions/runtime utilisent des snapshots techniques synchronisés vers le haut. `app_games_hub_capacity_sync()` met à jour conditionnellement `championnats_sessions.nb_joueurs_max` par `GREATEST`, sans nouvelle colonne Hub. Points : lancement/reprise officiel, ensure de participation papier/numérique, preload Canvas, métadonnées Remote et vérification runtime. Les démos sont exclues de l’offre et gardent 2 ; les sessions autonomes gardent leur snapshot historique.

Canvas expose `hub_capacity_get`, réservé au jeton de service. Il retourne `capacity`, `is_hub`, et, pour le Hub, `active_keys`/`active_count`/`active_identities`. Les clés incluent les mappings legacy des joueurs Hub actifs. Les alias legacy sont dédoublonnés par identité Hub pour le compteur runtime. Le probe transporte la clé joueur pour permettre la reprise d’un admis même à jauge pleine ; le front respecte le booléen `full` calculé par le serveur. Aucun navigateur ne décide la capacité commerciale. Quiz/Blind Test relisent au probe et register ; Bingo au probe et authentification numérique/papier. Une ancienne metadata Organizer/Remote peut encore être reçue, mais le prochain contrôle serveur recharge la capacité canonique avant acceptation. Les échecs du contrôle sont fermés, pas convertis en capacité illimitée.

Les gardes WS restent présentes. Pour un Hub, leur compteur ignore les anciennes identités absentes du roster actif ; les lignes et scores historiques ne sont pas supprimés. Les hydratations non historiques filtrent sur les identités Hub actives. Un ancien participant `left` ne peut pas se réactiver par un simple register runtime ; il doit repasser par une admission Hub explicite. Les adaptateurs PHP vérifient l’admission après résolution/validation de l’identité et avant écriture. Le bridge legacy utilise donc la même jauge ; les drapeaux `skip_hub_register_bridge`/auto-player ne sont pas une exemption commerciale.

L’injection papier reste la sélection des joueurs Hub `active`, puis l’ensure existant ; aucune priorité commerciale au premier poll/ensure. Les démos et sessions autonomes ne deviennent pas des admissions Hub.

## Bingo

`app_games_hub_bingo_capacity_ensure()` compte le stock par playlist/support sous un verrou dédié. Il appelle le générateur existant avec le nombre manquant et un offset de numéro. Le paramètre optionnel de numérotation conserve le comportement historique des autres appels. Seules de nouvelles grilles libres sont insérées : aucune suppression, réattribution ou remise à zéro de score. Relecture du stock après génération ; manque de stock/erreur explicite, retry idempotent même après insertion partielle.

Le contrôle se fait aussi au prochain contrôle runtime, pour une session déjà ouverte. Les grilles historiques attribuées restent conservées. Ce lot garantit l’extension 50→100 ; il ne recycle pas les grilles d’un joueur parti et ne crée pas un mécanisme général de rotation illimitée du stock.

## Tests et limites

- `php global/web/tests/hub_capacity_test.php` : production resolver/upsert et bridge d’admission Canvas, erreurs, EP/guest/Remote, départ, réactivation, upsell, démo/autonome, injection papier, append Bingo. Deux processus PHP concurrents partagent un double SQL stocké en fichier ; `flock` simule la primitive GET_LOCK. Aucun MySQL réel utilisé : la sémantique du serveur installé reste à vérifier lors d’une recette autorisée.
- `node games/web/tests/hub_capacity_runtime_test.cjs` : fonctions réelles register/probe Quiz/Blind Test et authentification Bingo, metadata 50/capacité 100, 51e accepté, identité inactive refusée, papier, démo, autonome. Réponses Canvas simulées, aucun trafic réseau.
- `php global/web/tests/hub_capacity_bingo_grid_test.php` : générateur réel, supports papier/numérique, formats court/long, numéros 51–100, affectations préservées, idempotence ; SQL simulé.
- Régressions réussies : roster/guest/probables/retour EP, CTA EP, lifecycle démo, substitution Quiz, contrat Remote, confirmation papier, settings Hub, bootstrap papier et reset Bingo ; lint PHP/JS et diff-check.
- Échec annexe préexistant : `hub_remote_paper_recovery_test.mjs`, ligne 30 (`modal` undefined). Le test et les deux sources qu’il charge (`hub_transition.js`, `remote-ui.js`) sont identiques à HEAD. Aucun changement hors périmètre pour le masquer.

Ce lot supporte l’upsell de jauge ; le downsell est hors périmètre. Les snapshots ne diminuent pas, aucun joueur n’est évincé. L’admission nouvelle lit toutefois l’offre effective actuelle : pas de droit temporaire/grandfathering ajouté. Aucune suppression de participation, aucune coupure nouvelle des sockets déjà liées lors d’un départ Hub ; la nouvelle admission/reconnexion est contrôlée. Les résultats historiques restent conservés.

La capacité est rafraîchie au prochain contrôle serveur, pas poussée en permanence par webhook. Le contrôle WS dépend du service Canvas disponible et de son jeton existant. Déployer ultérieurement Global/Games avant les moteurs consommateurs, comme un lot compatible ; aucune opération de déploiement n’est effectuée ici. Rollback : retirer le lot capacité ensemble sans toucher aux modifications CTA/routage précédentes ; les snapshots augmentés et les nouvelles grilles restent des données non destructives.
<!-- AUTO-UPDATE:END id="hub-capacity-upsell-20260921" -->
