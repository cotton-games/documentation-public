# Audit modèle offre réseau (2026-03-06)

## Périmètre audité
- `global/web/app/modules/ecommerce/`
- `global/web/app/modules/entites/clients/`
- `www/web/bo/www/modules/ecommerce/`
- `www/web/bo/www/modules/entites/clients/`
- `pro/web/ec/modules/compte/offres/`
- points d’entrée de rattachement affilié (UTM / signup)

Note de navigation: le chemin demandé `pro/web/ec/modules/account/network/` n’existe pas; l’entrée réelle `/extranet/account/network` route vers `t=compte&m=client&p=list`.
Preuves: `pro/web/.htaccess:116`, `pro/web/ec/ec.php:459`, `pro/web/ec/modules/compte/client/ec_client_list.php`.

## 1) Carte du modèle actuel

### Objets métier existants
- `Client siège réseau` (flag): `clients.flag_client_reseau_siege`.
- `Affiliation` (rattachement): `clients.id_client_reseau`.
- `Offre catalogue`: `ecommerce_offres`.
- `Offre client (achetée/active/en attente)`: `ecommerce_offres_to_clients`.
- `Délégation d’offre`: même table `ecommerce_offres_to_clients`, champ `id_client_delegation`.
- `Capacité joueurs`: `referentiels_clients_erp_jauges.nb_joueurs_max`, propagée sur `championnats_sessions.nb_joueurs_max`.

### Tables/champs clés
- `clients(flag_client_reseau_siege, id_client_reseau)` dans `documentation/dev_cotton_global_0.sql:495-499`.
- `ecommerce_offres(...)` dans `documentation/dev_cotton_global_0.sql:1331-1361`.
- `ecommerce_offres_to_clients(id_client, id_client_delegation, id_offre, id_erp_jauge, id_etat, ...)` dans `documentation/dev_cotton_global_0.sql:1411-1419`.
- `referentiels_clients_erp_jauges(nb_joueurs_max)` dans `documentation/dev_cotton_global_0.sql:2849-2855`.
- `championnats_sessions(nb_joueurs_max)` dans `documentation/dev_cotton_global_0.sql:387-407`.

### Fonctions / flux clés
- Rattachement affilié: `client_affilier($id_client_reseau, $id_client)` fait un `UPDATE clients.id_client_reseau`.
  Preuve: `global/web/app/modules/entites/clients/app_clients_functions.php:543-547`.
- Lien réseau UTM -> session d’affiliation:
  - rewrite: `pro/web/.htaccess:49-52` (miroir `www/web/.htaccess:118-121`).
  - résolution: `module_get_id("clients", $utm_term)` puis `$_SESSION['id_client_reseau']`.
  - preuve: `pro/web/ec/ec_sign.php:255-295`.
- À la création du compte affilié:
  - applique `client_affilier(...)` si session réseau.
  - applique une remise éventuelle `app_ecommerce_remise_client_ajouter(...)` si `utm_code`.
  - preuve: `pro/web/ec/modules/compte/client/ec_client_script.php:121-153`.
- Résolution des offres actives avec fallback délégation:
  - `app_ecommerce_offres_client_get_count` et `app_ecommerce_offres_client_get_liste`.
  - preuve: `global/web/app/modules/ecommerce/app_ecommerce_functions.php:1009-1065`.
- Détail offre client inclut `id_client_delegation`:
  - preuve: `global/web/app/modules/ecommerce/app_ecommerce_functions.php:934-975`.

## 2) Réponses aux 9 questions

### Q1. Notion exploitable d’“offre réseau” distincte de l’offre propre siège ?
Réponse: **partiellement**.
- Il existe une notion de **délégation** (`id_client_delegation`) dans `ecommerce_offres_to_clients`.
- Il n’existe pas d’objet/contrat explicite séparé “offre réseau siège” (table/type dédié).
- La notion historique `offre_client_reseau` est dans du code **désactivé/commenté**.
  Preuve: `global/web/app/modules/ecommerce/app_ecommerce_functions.php:2135-2199`.

### Q2. Inscription affilié via lien/rattachement -> offre associée automatiquement ?
Réponse: **non, pas directement**.
- Le lien réseau rattache le client (`id_client_reseau`) et peut poser une remise (`id_remise`).
- Aucune création automatique d’`ecommerce_offres_to_clients` dans ce flux d’affiliation.
  Preuves: `pro/web/ec/ec_sign.php:255-295`, `pro/web/ec/modules/compte/client/ec_client_script.php:121-153`.

### Q3. Si oui, type, stockage, autonomie commerciale ?
Réponse: **N/A pour l’affiliation seule**.
- Quand un accès “via réseau” existe, il est matérialisé comme une ligne d’offre client avec `id_client_delegation>0` dans `ecommerce_offres_to_clients`.
- C’est une **délégation d’accès** dans la même mécanique que les offres clients, pas un produit commercial réseau autonome.
  Preuves: `documentation/dev_cotton_global_0.sql:1411-1419`, `global/web/app/modules/ecommerce/app_ecommerce_functions.php:1009-1065`, `pro/web/ec/modules/compte/client/ec_client_list.php:141-179`.

### Q4. Distinction propre: offre propre siège / offre réseau siège / offre propre affilié / accès via délégation ?
Réponse: **incomplète**.
- `offre propre affilié` vs `via réseau` est distingué en lecture via `id_client_delegation==0` vs `>0`.
  Preuve: `pro/web/ec/modules/compte/client/ec_client_list.php:141-179`.
- `offre propre siège` vs `offre réseau siège` n’a pas de séparation contractuelle explicite (pas de type/flag métier dédié côté data).

### Q5. Champ/type/relation/table pour max affiliés activables + max joueurs par affilié ?
Réponse: **non pour max affiliés activables**, **oui partiel pour joueurs**.
- Aucun champ/table trouvé pour quota d’affiliés activables (recherche repo/sql sans résultat structurant).
- `max joueurs` existe via `id_erp_jauge -> referentiels_clients_erp_jauges.nb_joueurs_max` puis copie en session.
  Preuves: `documentation/dev_cotton_global_0.sql:2849-2855`, `global/web/app/modules/jeux/sessions/app_sessions_functions.php:233-247,495-505`.

### Q6. Où est portée la limite joueurs max ?
Réponse: **offre client + session**.
- Source contractuelle: `ecommerce_offres_to_clients.id_erp_jauge`.
- Référence: `referentiels_clients_erp_jauges.nb_joueurs_max`.
- Valeur opérationnelle: `championnats_sessions.nb_joueurs_max` (figée à la création, puis MAJ future possible via webhook Stripe).
  Preuves: `documentation/dev_cotton_global_0.sql:1416`, `documentation/dev_cotton_global_0.sql:2849-2855`, `documentation/dev_cotton_global_0.sql:406`, `pro/web/ec/ec_webhook_stripe_handler.php:554-556`.

### Q7. Activation/désactivation d’accès délégué déjà en BO ou global ?
Réponse: **partiel**.
- Global: activation/désactivation d’offre client via `id_etat` et fonctions abonnement existe.
  Preuves: `global/web/app/modules/ecommerce/app_ecommerce_functions.php:699,842-855,1254-1309`.
- BO: champs `id_etat`, `id_client_delegation` exposés dans `offres_clients`.
  Preuves: `www/web/bo/www/modules/ecommerce/offres_clients/bo_module_parametres.php:8-17,35-40`.
- PRO: en délégation, les actions Stripe “gérer/réactiver” sont masquées (`id_client_delegation==0` requis).
  Preuves: `pro/web/ec/modules/compte/offres/ec_offres_include_detail.php:400-417,506-508`.
- Il n’y a pas de pilotage explicite “activer/désactiver affilié X” dans la page réseau PRO actuelle.

### Q8. Lien d’affiliation transporte/résout une offre à diffuser sans hack ?
Réponse: **non**.
- Le lien transporte `utm_term` (siège) et optionnellement `utm_code` (remise), pas un identifiant d’offre réseau à diffuser.
  Preuves: `pro/web/.htaccess:49-52`, `pro/web/ec/ec_sign.php:261-290`.

### Q9. Le modèle permet que la tête de réseau active/désactive individuellement les affiliés depuis PRO sans casser les offres propres ?
Réponse: **pas proprement aujourd’hui**.
- La distinction “offre propre” vs “via réseau” existe en lecture.
- Mais absence de contrat explicite de délégation par affilié (état de délégation dédié + quota) et absence d’actions PRO dédiées de pilotage individuel.
  Preuves: `pro/web/ec/modules/compte/client/ec_client_list.php:141-179`, absence de module `pro/web/ec/modules/account/network/`.

## 3) Verdict

**Nouveau contrat nécessaire** (minimal, adossé au modèle existant).

Raison: le socle actuel couvre affiliation + délégation d’accès, mais pas les 3 invariants demandés en natif:
- identité explicite d’**offre réseau siège** distincte de son offre propre,
- **offre diffusée** traçable et pilotable par affilié,
- **quota d’affiliés activables** contractualisé.

## 4) Contrat minimal proposé

### 4.1 Data (minimum)
- Nouvelle table `ecommerce_offres_reseau_contrats`:
  - `id`
  - `id_client_siege`
  - `id_offre_client_source` (offre active siège qui porte le contrat réseau)
  - `id_offre_diffusee` (optionnel si différente de la source)
  - `nb_affilies_activables_max`
  - `nb_joueurs_max_par_affilie_default` (ou `id_erp_jauge_default`)
  - `id_etat` (actif/inactif)
  - `date_ajout`, `date_maj`
- Nouvelle table `ecommerce_offres_reseau_affilies`:
  - `id`
  - `id_contrat_reseau`
  - `id_client_affilie`
  - `id_offre_client_deleguee` (ligne `ecommerce_offres_to_clients` associée)
  - `id_etat_delegation` (actif/inactif/suspendu)
  - `nb_joueurs_max_override` (nullable)
  - `date_activation`, `date_desactivation`, `id_user_maj`

### 4.2 Métier
- Resolver unique `offre_effective` retourne explicitement:
  - `mode_acces`: `propre|reseau|aucun`
  - `id_offre_client_effective`
  - `id_contrat_reseau` (si réseau)
  - `delegation_active` (bool)
- Règle stricte:
  - offre propre affilié active > délégation réseau > aucun accès.
- Contrôle quota:
  - activation affilié refusée si `COUNT(affiliés actifs) >= nb_affilies_activables_max`.

### 4.3 UI/ops
- PRO réseau: actions par affilié `Activer`, `Désactiver`, `Ajuster jauge joueurs`.
- BO: vue contrat réseau + compteur `actifs / quota`.

## 5) Résumé concret

### Réutilisable immédiatement
- Affiliation (`clients.id_client_reseau`).
- Délégation d’accès existante (`ecommerce_offres_to_clients.id_client_delegation`).
- Résolution lecture propre/via réseau.
- Jauges joueurs via `id_erp_jauge`.

### À créer
- Contrat réseau explicite (source/diffusée/quota).
- État de délégation par affilié pilotable.
- Actions PRO de pilotage individuel.

### Risques métier à éviter
- Confondre affiliation et accès actif.
- Confondre offre propre siège et offre réseau diffusée.
- Piloter la délégation via hacks UTM/remise au lieu d’un contrat explicite.

---

## Addendum 2026-03-06 — Critère réel de la liste affiliés (page réseau PRO)

### Constat code (tranché)
- La liste affichée dans `/extranet/account/network` repose sur:
  - `clients.id_client_reseau = <id_client_siege>`
  - **et** un critère secondaire `clients.id_etat < 3`.
- Requête source (via helper):
  - `pro/web/ec/modules/compte/client/ec_client_list.php`:
    - filtre: `id_client_reseau=' . $_SESSION['id_client'] . ' AND id_etat<3`
    - appel: `module_get_liste(...)`
  - `global/web/lib/core/lib_core_module_functions.php`:
    - `module_get_liste(...)` concatène le filtre tel quel (pas de jointure/filtre implicite supplémentaire).

### Implication métier
- Le critère d’affiliation **canonique** est bien `clients.id_client_reseau`.
- Mais l’UI actuelle ne montre pas tous les affiliés canoniquement rattachés si certains ont `id_etat >= 3`.
- Donc la page peut sembler “pas à jour” après Étape 0 même quand le rattachement a bien été fait.

### Différence à conserver explicitement
- `Affilié` (rattachement): `clients.id_client_reseau`.
- `Actif via réseau` (accès): déterminé séparément par les offres (`id_etat=3` côté offres + `id_client_delegation > 0`).
- Ces deux notions ne sont pas équivalentes.

### Patch minimal proposé (si on veut aligner la liste sur le canon d’affiliation)
- Dans `pro/web/ec/modules/compte/client/ec_client_list.php`:
  - remplacer le filtre liste:
    - de `id_client_reseau=<id_siege> AND id_etat<3`
    - à `id_client_reseau=<id_siege>`
- Option de cohérence UI:
  - faire la même correction dans le widget résumé:
    - `pro/web/ec/modules/widget/ec_widget_client_reseau_resume.php`
  - sinon le compteur widget restera potentiellement différent de la liste.
