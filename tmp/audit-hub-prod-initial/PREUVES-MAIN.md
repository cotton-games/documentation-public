# Preuves code PROD — branches main du workspace

## pro — web/ec/modules/tunnel/start/ec_start_sessions_day.php:50–112

Commit `f5af07280eed17210353956060b52f11c9b68dd8`

```php
50: if (!$day_date_is_valid) {
51:     $day_notice = "Cette date n'est pas disponible dans ton agenda.";
52: } elseif ($day_is_network_head) {
53:     $day_notice = "Cette vue par date n'est pas disponible pour l'agenda réseau.";
54: } else {
55:     $bdd_table = 'championnats_sessions';
56:     $bdd_champs_nom = 'id, id_championnat_saison, id_operation_evenement, id_type_produit, id_produit, date, MONTH(date) AS mois_session, YEAR(date) AS annee_session, heure_debut, flag_session_weblive, flag_session_privee, flag_controle_numerique, descriptif_court, id_securite, lot_ids, nb_joueurs_max';
57:     $bdd_filtre = 'id_client=' . (int) $_SESSION['id_client']
58:         . " AND date='" . $GLOBALS['mysqli']->real_escape_string($day_date) . "'"
59:         . ' AND flag_session_demo=0 AND flag_configuration_complete=1';
60:     $bdd_ordre = 'date ASC, heure_debut ASC';
61:     $day_sessions = module_get_liste($bdd_table, $bdd_champs_nom, $bdd_filtre, $bdd_ordre, '');
62:     if ($day_temporal_mode === 'past') {
63:         $day_sessions = app_sessions_filter_by_archive_state($day_sessions, 1);
64:     } elseif ($day_temporal_mode === 'upcoming') {
65:         $day_sessions = app_sessions_filter_by_archive_state($day_sessions, 0);
66:     }
67:     if (!empty($day_sessions) && function_exists('ec_start_agenda_sessions_sort')) {
68:         ec_start_agenda_sessions_sort($day_sessions, ($day_temporal_mode === 'past') ? 1 : 0);
69:     } elseif (!empty($day_sessions)) {
70:         usort($day_sessions, function ($session_a, $session_b) {
71:             $key_a = trim((string) ($session_a['date'] ?? '') . ' ' . (string) ($session_a['heure_debut'] ?? ''));
72:             $key_b = trim((string) ($session_b['date'] ?? '') . ' ' . (string) ($session_b['heure_debut'] ?? ''));
73:             if ($key_a === $key_b) {
74:                 return ((int) ($session_a['id'] ?? 0)) <=> ((int) ($session_b['id'] ?? 0));
75:             }
76:             return strcmp($key_a, $key_b);
77:         });
78:     }
79:     if (empty($day_sessions) && !in_array($day_temporal_mode, array('today', 'upcoming'), true)) {
80:         $day_notice = "Aucune session accessible n'est programmée à cette date.";
81:     }
82: }
83: 
84: $day_is_dynamisation_context = (($day_wording['context_key'] ?? '') === 'public_place');
85: if (
86:     $day_date_is_valid
87:     && in_array($day_temporal_mode, array('today', 'upcoming'), true)
88:     && !$day_is_network_head
89:     && !$day_is_dynamisation_context
90:     && (int) ($day_client_detail['id_solution_usage'] ?? 0) === 2
91:     && function_exists('app_evenement_pivot_ensure_for_day')
92: ) {
93:     $day_session_ids = array();
94:     foreach ($day_sessions as $day_session_item) {
95:         $day_session_id = (int) ($day_session_item['id'] ?? 0);
96:         if ($day_session_id > 0) {
97:             $day_session_ids[] = $day_session_id;
98:         }
99:     }
100:     $day_operation_evenement_ensure = app_evenement_pivot_ensure_for_day(
101:         (int) $_SESSION['id_client'],
102:         $day_date,
103:         $day_session_ids,
104:         array('allow_empty' => empty($day_session_ids))
105:     );
106:     if ((int) ($day_operation_evenement_ensure['id_operation_evenement'] ?? 0) > 0 && (int) ($day_operation_evenement_ensure['attached_count'] ?? 0) > 0) {
107:         foreach ($day_sessions as $day_session_index => $day_session_item) {
108:             if ((int) ($day_session_item['id_operation_evenement'] ?? 0) <= 0) {
109:                 $day_sessions[$day_session_index]['id_operation_evenement'] = (int) $day_operation_evenement_ensure['id_operation_evenement'];
110:             }
111:         }
112:     }
```

## pro — web/ec/modules/tunnel/start/ec_start_sessions_day_helpers.php:106–131

Commit `f5af07280eed17210353956060b52f11c9b68dd8`

```php
106:     function ec_start_day_wording_get($client_detail)
107:     {
108:         $client_detail = ec_start_day_client_detail_get($client_detail);
109:         $context_key = 'fallback';
110:         $label = 'animation';
111:         $cta = "Voir l'animation";
112:         $title_prefix = 'Animation';
113: 
114:         if ((int) ($client_detail['id_solution_usage'] ?? 0) === 2) {
115:             $context_key = 'business_use';
116:             $label = 'événement';
117:             $cta = "Voir l'événement";
118:             $title_prefix = 'Événement';
119:         } else {
120:             $chr_typology_ids = array(1, 4, 5, 6, 8);
121:             if (in_array((int) ($client_detail['id_typologie'] ?? 0), $chr_typology_ids, true)) {
122:                 $context_key = 'public_place';
123:                 $label = 'soirée';
124:                 $cta = 'Voir la soirée';
125:                 $title_prefix = 'Soirée';
126:             }
127:         }
128: 
129:         return array(
130:             'context_key' => $context_key,
131:             'label' => $label,
```

## global — web/app/modules/operations/evenements/app_evenements_functions.php:156–219

Commit `5ec94b28a99830e4ccfb7e85b9e0d27234d6a344`

```php
156: function app_evenement_pivot_slug_get($id_client, $day_date)
157: {
158: 	$id_client = (int) $id_client;
159: 	$day_date = trim((string) $day_date);
160: 	if ($id_client <= 0 || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $day_date)) {
161: 		return '';
162: 	}
163: 
164: 	return 'cotton-event-' . $id_client . '-' . str_replace('-', '', $day_date);
165: }
166: 
167: function app_evenement_pivot_detail_is_managed($event_detail, $id_client = 0)
168: {
169: 	$event_detail = is_array($event_detail) ? $event_detail : array();
170: 	$slug = trim((string) ($event_detail['evenement_seo_slug'] ?? $event_detail['seo_slug'] ?? ''));
171: 	if (!preg_match('/^cotton-event-(\d+)-(\d{8})-*$/', $slug, $matches)) {
172: 		return false;
173: 	}
174: 
175: 	$event_client_id = (int) ($event_detail['id_client'] ?? 0);
176: 	if ((int) $id_client > 0 && $event_client_id !== (int) $id_client) {
177: 		return false;
178: 	}
179: 
180: 	$slug_date = substr($matches[2], 0, 4) . '-' . substr($matches[2], 4, 2) . '-' . substr($matches[2], 6, 2);
181: 	$date_debut = trim((string) ($event_detail['date_debut'] ?? ''));
182: 	$date_fin = trim((string) ($event_detail['date_fin'] ?? ''));
183: 	if ($date_debut !== '' && $date_debut !== '0000-00-00' && substr($date_debut, 0, 10) !== $slug_date) {
184: 		return false;
185: 	}
186: 	if ($date_fin !== '' && $date_fin !== '0000-00-00' && substr($date_fin, 0, 10) !== $slug_date) {
187: 		return false;
188: 	}
189: 
190: 	return true;
191: }
192: 
193: function app_evenement_pivot_detail_matches_day($event_detail, $id_client, $day_date)
194: {
195: 	$event_detail = is_array($event_detail) ? $event_detail : array();
196: 	$id_client = (int) $id_client;
197: 	$day_date = trim((string) $day_date);
198: 	if ($id_client <= 0 || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $day_date)) {
199: 		return false;
200: 	}
201: 
202: 	$target_slug = app_evenement_pivot_slug_get($id_client, $day_date);
203: 	$event_slug = trim((string) ($event_detail['evenement_seo_slug'] ?? $event_detail['seo_slug'] ?? ''));
204: 	if ($target_slug === '' || $event_slug !== $target_slug) {
205: 		return false;
206: 	}
207: 
208: 	$date_debut = trim((string) ($event_detail['date_debut'] ?? ''));
209: 	$date_fin = trim((string) ($event_detail['date_fin'] ?? ''));
210: 	if ($date_debut !== '' && $date_debut !== '0000-00-00' && substr($date_debut, 0, 10) !== $day_date) {
211: 		return false;
212: 	}
213: 	if ($date_fin !== '' && $date_fin !== '0000-00-00' && substr($date_fin, 0, 10) !== $day_date) {
214: 		return false;
215: 	}
216: 
217: 	return ((int) ($event_detail['id_client'] ?? 0) === $id_client);
218: }
219: 
```

## global — web/app/modules/operations/evenements/app_evenements_functions.php:642–676

Commit `5ec94b28a99830e4ccfb7e85b9e0d27234d6a344`

```php
642: function app_evenement_ajouter($id_client, $evenement_nom, $evenement_descriptif_court, $evenement_descriptif_long, $date_debut, $date_fin, $flag_evenement_demo, $flag_evenement_prive, $flag_connexion_joueur_pseudo, $naming_lieu, $naming_adresse, $lien_url, $lien_libelle, $options = array())
643: {
644: 	$options = is_array($options) ? $options : array();
645: 
646: 	// id_securite
647: 	$id_securite 		= uniqid() ; // $id_securite = session_id() . uniqid() ;
648: 	
649: 	// Code PIN associé à cet événement
650: 	$pin_code_count = 1;
651: 	while ($pin_code_count > 0) 
652: 	{
653: 	    $pin_code 		= make_pin_code(6);
654: 		$sql 			= "SELECT COUNT(*) FROM operations_evenements WHERE code_operation_evenement='" . $pin_code . "'";
655: 		$result 		= $GLOBALS['mysqli']->query($sql);
656: 		$row 			= $result->fetch_row();
657: 	    $pin_code_count = $row[0] ;
658: 	}
659: 
660: 	$id_securite.= $pin_code_count ;
661: 
662: 	// Attributs seo
663: 	// Spécifique : à la création d'un compte 'Gamifier', est créé un événement démo par défaut avec pour nom "Événement démo" ; afin d'éviter la multiplicité de slug semblable, ajout du nom du compte
664: 	if ($flag_evenement_demo==1) 
665: 	{ 
666: 		$app_client_detail 	= app_client_get_detail($id_client); 
667: 		$seo_slug 			= rewrite($evenement_nom . "-" . $app_client_detail['nom']) ;
668: 	}
669: 	else
670: 	{
671: 		$seo_slug = rewrite($evenement_nom) ;
672: 	}
673: 	if (isset($options['seo_slug']) && trim((string) $options['seo_slug']) !== '') {
674: 		$seo_slug = rewrite((string) $options['seo_slug']);
675: 	}
676: 
```

## global — web/app/modules/operations/evenements/app_evenements_functions.php:775–824

Commit `5ec94b28a99830e4ccfb7e85b9e0d27234d6a344`

```php
775: function app_evenement_client_affiliation_ajouter($id_operation_evenement, $id_client)
776: {
777: 	
778: 	$evenement_detail = app_evenement_get_detail($id_operation_evenement);
779: 
780: 	// Création de l'offre client affilié
781: 	$offre_client_id 							= $evenement_detail['id_ecommerce_offre'] ;
782: 	$offre_client_id_erp_jauge 					= $evenement_detail['id_erp_jauge'] ;
783: 	$offre_client_prix_ht 						= 0 ;
784: 	$offre_client_produit_additionnel_prix_ht 	= 0 ;
785: 	$offre_date_facturation_debut 				= '' ;
786: 	$lien_url_paiement_CB 						= '' ;
787: 	$offre_client_remise_nom 					= $evenement_detail['nom'] ;
788: 
789: 	$id_securite_offre_client 					= app_ecommerce_offre_client_gerer($offre_client_id, $offre_client_id_erp_jauge, $id_client, $offre_client_prix_ht, $offre_client_produit_additionnel_prix_ht, $offre_date_facturation_debut, $lien_url_paiement_CB, $offre_client_remise_nom) ;
790: 	$id_offre_client 							= app_ecommerce_offre_client_get_id($id_securite_offre_client) ;
791: 
792: 	// MAJ offre client affilié : id_etat (pour activer l'offre), date_debut, date_fin, nb_animation
793: 	$offre_client_date_debut 					= $evenement_detail['date_debut'] ;
794: 	$offre_client_date_fin 						= $evenement_detail['date_fin'] ;
795: 	$offre_client_nb_animation 					= $evenement_detail['nb_animation'] ;
796: 
797: 	$sql = "UPDATE ecommerce_offres_to_clients SET id_etat=3, id_operation_evenement='" . $id_operation_evenement . "', date_debut='" . $offre_client_date_debut . "', date_fin='" . $offre_client_date_fin . "', nb_animation='" . $offre_client_nb_animation . "', flag_offert=1, prix_ht=0 WHERE id=" . $id_offre_client ;
798: 	$GLOBALS['mysqli']->query($sql);
799: 	if (function_exists('app_ecommerce_reseau_facturation_refresh_from_offer_client'))
800: 	{
801: 		app_ecommerce_reseau_facturation_refresh_from_offer_client((int) $id_offre_client);
802: 	}
803: }
804: 
805: 
806: // ------------------------------------------------------------------------------
807: // Evénément > session > count
808: // ------------------------------------------------------------------------------
809: 
810: function app_evenement_sessions_get_count($id_operation_evenement, $bdd_filtre='')
811: {
812: 	$sql = "SELECT count(id) FROM championnats_sessions WHERE id_operation_evenement = '" . $id_operation_evenement ."'" ;
813: 	if (!empty($bdd_filtre)) { $sql .= " AND " . $bdd_filtre ; }
814: 	// echo $sql ;
815: 	$result = $GLOBALS['mysqli']->query($sql);
816: 	$row = $result->fetch_row();
817: 	return $row[0];		
818: }
819: 
820: // ------------------------------------------------------------------------------
821: // Evénément > joueurs > count
822: // ------------------------------------------------------------------------------
823: 
824: function app_evenement_participants_get_count($id_operation_evenement, $bdd_filtre='')
```

## global — web/app/modules/jeux/sessions/app_sessions_functions.php:2685–2744

Commit `5ec94b28a99830e4ccfb7e85b9e0d27234d6a344`

```php
2685: 	function app_session_ajouter
2686: 	(
2687: 		$id_securite,
2688: 		$id_client,
2689: 		$id_client_contact,
2690: 		$id_offre_client,
2691: 		$id_type_produit,
2692: 		$id_produit_client,
2693: 		$session_date,
2694: 		$session_heure,
2695: 		$flag_session_demo, 
2696: 		$flag_session_privee,
2697: 		$flag_session_weblive,
2698: 		$lien_url_session_weblive,
2699: 		$id_operation_evenement = 0
2700: 	)
2701: 	{	
2702: 		global $conf, $parametre, $l ;
2703: 		
2704: 		$id_championnat_saison 				= app_saison_get_id($session_date) ;
2705: 
2706: 		// Code PIN associé à cette session
2707: 		
2708: 		$pin_code_count = 1;
2709: 		while ($pin_code_count > 0) 
2710: 		{
2711: 		    $pin_code 	= make_pin_code(6);
2712: 			$sql 		= "SELECT COUNT(*) FROM championnats_sessions WHERE code_session='" . $pin_code . "'";
2713: 			$result 	= $GLOBALS['mysqli']->query($sql);
2714: 			$row 		= $result->fetch_row();
2715: 		    $pin_code_count = $row[0] ;
2716: 		}
2717: 
2718: 		// Session rattachée à un événement ?
2719: 		/*
2720: 		$id_operation_evenement = 0 ;
2721: 		if ($id_offre_client>0)
2722: 		{
2723: 			$offre_client_detail  	= app_ecommerce_offre_client_get_detail($id_offre_client);
2724: 			$id_operation_evenement = $offre_client_detail['id_operation_evenement'] ;
2725: 		}
2726: 		*/
2727: 		// 12/06/2024 => id_operation_evenement est passé en paramètre
2728: 
2729: 		// 14/06/2024 : pour une session rattachée à un événement, celle-ci hérite du flag_evenement_prive pour déterminer la valeur de flag_session_privee
2730: 		if ($id_operation_evenement>0)
2731: 		{
2732: 			$app_evenement_detail = app_evenement_get_detail($id_operation_evenement);
2733: 			$flag_session_privee = $app_evenement_detail['flag_evenement_prive'] ;
2734: 		}
2735: 
2736: 		// Spécifique BM
2737: 		// 15/10/2024 : ajout champs "lien_url_sortie_app_1"
2738: 		// 01/05/2024 : à désactiver à terme lorsque BM V5 ouvert pour tout le monde
2739: 		$lien_url_sortie_app_1 	= "" ;
2740: 		$lien_url_sortie_app_2 	= "" ;
2741: 
2742: 		// 08/01/2026 => désactivation // mise en commentaire
2743: 		/*
2744: 		if ($id_type_produit==3 || $id_type_produit==6)
```

## Chaîne active / commentaire — pro web/.htaccess:169–175

```php
169: # ec > tunnel start
170: #---------------------------------------------------------------------
171: 
172: # Transverse. Script (session + jeu)
173: rewrite ^/extranet/start/script$  /ec/do_script.php?t=tunnel&m=start&p=script break;
174: rewrite ^/extranet/start/agenda/mode/script$  /ec/do_script.php?t=tunnel&m=start&p=script break;
175: 
```

## Chaîne active / commentaire — pro web/.htaccess:205–214

```php
205: # Page listing des sessions (agenda des sessions)
206: rewrite ^/extranet/start/games$                                         /ec/ec.php?t=tunnel&m=start&p=sessions_list&flag_archive=0 break;
207: 
208: # Page agenda par date
209: rewrite ^/extranet/start/games/day/?$                                      /ec/ec.php?t=tunnel&m=start&p=sessions_day&day_date= break;
210: rewrite ^/extranet/start/games/day/([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])/?$ /ec/ec.php?t=tunnel&m=start&p=sessions_day&day_date=$1 break;
211: rewrite ^/extranet/start/games/day/([^/]+)/?$                             /ec/ec.php?t=tunnel&m=start&p=sessions_day&day_date=$1 break;
212: rewrite ^/extranet/start/games/day/event/modal/([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])/?$ /ec/modules/tunnel/start/ec_start_sessions_day_event_modal.php?day_date=$1 break;
213: rewrite ^/extranet/start/games/day/event/script$                          /ec/do_script.php?t=tunnel&m=start&p=sessions_day_event_script break;
214: 
```

## Chaîne active / commentaire — pro web/ec/ec.php:10–30

```php
10: 
11: // config.
12: require '../config.php';
13: 
14: // global.cotton > librairies
15: require $conf['global_root'][$conf['server']] . 'global_librairies.php';
16: 
17: $is_cq_admin = ((isset($_SESSION['CQ_admin']) ? (int) $_SESSION['CQ_admin'] : 0) === 1);
18: 
19: if (!empty($_SESSION['id_client_contact'])) 
20: { 
21: 
22: // ec > modules > fonctions
23: require 'modules/compte/authentification/ec_authentification_functions.php';
24: require 'modules/support/installations/ec_installations_functions.php';
25: require_once 'modules/tunnel/start/ec_first_party_helpers.php';
26: 
27: // Récupère paramètres module et page dans l'URL
28: $t = isset($_GET['t']) ? $_GET['t'] : 'communication';  // Type
29: $m = isset($_GET['m']) ? $_GET['m'] : 'home';           // Module
30: $p = isset($_GET['p']) ? $_GET['p'] : 'index';          // Page
```

## Chaîne active / commentaire — pro web/ec/ec.php:85–104

```php
85:     // Offre effective (source unique) : offre propre > réseau actif > inactif
86:     $app_offre_effective_context = app_ecommerce_offre_effective_get_context((int) $_SESSION['id_client']);
87:     $offre_effective_state = isset($app_offre_effective_context['access_state']) ? $app_offre_effective_context['access_state'] : 'inactive';
88:     $offre_effective_inactive_reason = isset($app_offre_effective_context['inactive_reason']) ? $app_offre_effective_context['inactive_reason'] : '';
89:     $network_contract_state = isset($app_offre_effective_context['network']['contract_state']) ? $app_offre_effective_context['network']['contract_state'] : 'none';
90:     $network_support_offer_state = isset($app_offre_effective_context['network']['support_offer_state']) ? $app_offre_effective_context['network']['support_offer_state'] : 'inactive';
91:     $offre_effective_security_id = isset($app_offre_effective_context['effective_offer_security_id']) ? $app_offre_effective_context['effective_offer_security_id'] : '';
92:     $offre_effective_has_access = ($offre_effective_state!=='inactive');
93:     $offre_effective_active_count_total = isset($app_offre_effective_context['active_offer_count_total']) ? (int) $app_offre_effective_context['active_offer_count_total'] : 0;
94: 
95:     // Variables legacy gardées pour compatibilité des includes/menus.
96:     $offre_client_active_count = $offre_effective_has_access ? max(1, $offre_effective_active_count_total) : 0;
97:     $offre_client_payante_active_count = $offre_client_active_count;
98: 
99:     // URL ecommerce [ propose les 2 offres, mais dans un ordre différent, selon l'usage (le cas échéant) ]
100:     // $url_ecommerce = $conf['site_root'][$conf['server']] . "extranet/ecommerce/offers/all/s1/" . $id_erp_jauge ;
101:     // [ MAJ le 09/09/2025 ]
102:     $url_ecommerce = "/extranet/ecommerce/offers" ;
103: 
104:     switch ($app_client_detail['id_typologie']) {
```

## Chaîne active / commentaire — pro web/ec/ec.php:433–445

```php
433:                 case 'client_list':
434:                 case 'compte_joueurs':
435:                 case 'ecommerce_offres':
436:                 case 'compte_factures':
437:                 case 'compte_offres':
438:                     $acces = 0;
439:                 break;
440:             }
441:         }
442: 
443:         if ($acces==1) { require 'modules/'.$t.'/'.$m.'/ec_'.$m.'_'.$p.'.php' ;}
444:         exit();
445:     }
```

## Chaîne active / commentaire — pro web/ec/do_script.php:48–85

```php
48: // Récupère paramètres module et page dans l'URL
49: $t = isset($_GET['t']) ? $_GET['t'] : '';   	// Type
50: $m = isset($_GET['m']) ? $_GET['m'] : '';   	// Module
51: $p = isset($_GET['p']) ? $_GET['p'] : '';  		// Page
52: $l = isset($_GET['l']) ? $_GET['l'] : 'fr';  	// Langue
53: 
54: 	if 	(
55: 			(empty($_SESSION['id_client'])&&($_POST['mode']=='client_ajouter'))||
56: 			(empty($_SESSION['id_client'])&&($_POST['mode']=='client_contact_connecter'))||
57: 			(empty($_SESSION['id_client'])&&($_POST['mode']=='client_contact_reinitialiser_e1'))||
58: 			(empty($_SESSION['id_client'])&&($_POST['mode']=='client_contact_reinitialiser_e3'))||
59: 			(empty($_SESSION['id_client'])&&((isset($_GET['mode']) ? $_GET['mode'] : '')=='client_contact_direct_access'))||
60: 			((isset($_SESSION['id_client_contact']) ? (int) $_SESSION['id_client_contact'] : 0)>0)||
61: 			(
62: 				(isset($_COOKIE['CQ_admin_gate_client_id']) ? (int) $_COOKIE['CQ_admin_gate_client_id'] : 0)>0
63: 				&& (isset($_COOKIE['CQ_admin_gate_client_contact_id']) ? (int) $_COOKIE['CQ_admin_gate_client_contact_id'] : 0)>0
64: 			)
65: 		)
66: 	{
67: 		
68: 		// Définit le repertoire du script à exécuter
69: 		$script = 'modules/'.$t.'/'.$m.'/ec_'.$m.'_'.$p.'.php' ;
70: 		// Appelle le script à exécuter
71: 		require($script);
72: 
73: 		// Redirection vers $url_redir (définie dans le script)
74: 		// exit();
75: 		redir($url_redir);
76: 	}
77: 	else
78: 	{
79: 		redir($conf['site_root'][$conf['server']] .'signin');
80: 	}
81: ?>
```

## Chaîne active / commentaire — pro web/ec/modules/tunnel/start/ec_start_script.php:1471–1535

```php
1471: 	case 'sessions_day_create':
1472: 
1473: 		$day_date = isset($_POST['day_date']) ? trim((string) $_POST['day_date']) : '';
1474: 		$day_context = isset($_POST['day_context']) ? trim((string) $_POST['day_context']) : '';
1475: 		$id_securite_offre_client = isset($_POST['id_securite_offre_client']) ? trim((string) $_POST['id_securite_offre_client']) : '0';
1476: 		if ($id_securite_offre_client === '') {
1477: 			$id_securite_offre_client = '0';
1478: 		}
1479: 		$url_retry = $conf['site_root'][$conf['server']]
1480: 			. 'extranet/start/agenda/mode/' . rawurlencode($id_securite_offre_client)
1481: 			. '?from=agenda';
1482: 		$url_retry_from_post = function_exists('start_script_safe_return_url_from_post_get')
1483: 			? start_script_safe_return_url_from_post_get('retry_url')
1484: 			: '';
1485: 		if ($url_retry_from_post !== '') {
1486: 			$url_retry = $url_retry_from_post;
1487: 		}
1488: 		if ($day_context !== '') {
1489: 			$url_retry = start_script_query_param_append($url_retry, 'day_context', $day_context);
1490: 		}
1491: 
1492: 		if (
1493: 			!function_exists('ec_start_day_date_is_valid')
1494: 			|| !ec_start_day_date_is_valid($day_date)
1495: 			|| !in_array(ec_start_day_temporal_mode_get($day_date), array('today', 'upcoming'), true)
1496: 		) {
1497: 			$url_redir = start_script_query_param_append($url_retry, 'date_error', 'invalid');
1498: 			break;
1499: 		}
1500: 
1501: 		if (
1502: 			function_exists('ec_start_day_creation_date_is_occupied')
1503: 			&& ec_start_day_creation_date_is_occupied((int) $_SESSION['id_client'], $day_date, $start_client_is_gamification_usage)
1504: 		) {
1505: 			$url_redir = start_script_query_param_append($url_retry, 'date_error', 'occupied');
1506: 			break;
1507: 		}
1508: 
1509: 		if ($start_client_is_gamification_usage && function_exists('app_evenement_pivot_ensure_for_day')) {
1510: 			$ensure_result = app_evenement_pivot_ensure_for_day(
1511: 				(int) $_SESSION['id_client'],
1512: 				$day_date,
1513: 				array(),
1514: 				array('allow_empty' => true)
1515: 			);
1516: 			$allowed_statuses = array('created', 'found', 'attached');
1517: 			if (
1518: 				(int) ($ensure_result['id_operation_evenement'] ?? 0) <= 0
1519: 				|| !in_array((string) ($ensure_result['status'] ?? ''), $allowed_statuses, true)
1520: 			) {
1521: 				$ensure_skip_reason = (string) ($ensure_result['skip_reason'] ?? '');
1522: 				if (!in_array($ensure_skip_reason, array('no_sessions', 'create_failed'), true)) {
1523: 					$url_redir = start_script_query_param_append($url_retry, 'date_error', 'event_unavailable');
1524: 					break;
1525: 				}
1526: 			}
1527: 		}
1528: 
1529: 		$url_redir = start_sessions_day_pivot_url_get($day_date);
1530: 		$url_redir = start_script_query_param_append($url_redir, 'created', '1');
1531: 		if (
1532: 			$start_client_is_gamification_usage
1533: 			&& isset($ensure_result)
1534: 			&& (int) ($ensure_result['id_operation_evenement'] ?? 0) <= 0
1535: 		) {
```

## Chaîne active / commentaire — pro web/ec/modules/compte/client/ec_client_script.php:716–740

```php
716: 
717: <?php
718: // Nettoyage le 30/09/2025
719: /*
720: if ($_SESSION['id_operation_evenement']>0)
721: {
722: 	app_evenement_client_affiliation_ajouter($_SESSION['id_operation_evenement'], $id_client);
723: 	unset($_SESSION['id_operation_evenement']);
724: 
725: 	// MAJ fiche client : le canal d'acquisition est "Inscrit par le biais d'une opération / événement" (id_acquisition_canal=6)
726: 	// Outre le suivi du canal d'acquisition, ce champ permettra de distinguer les envois d'emails transactionnels, différents s'il s'agit d'un INS classique ou d'un INS via l'invitation à participer à un événement
727: 	$id_acquisition_canal = 6 ;
728: 	app_client_acquisition_canal_modifier($id_client, $id_acquisition_canal) ;
729: }
730: elseif ($_SESSION['id_remise']>0)
731: {
732: 	// Gestion, notamment, des remises réseaux
733: 	app_ecommerce_remise_client_ajouter($_SESSION['id_remise'], $id_client) ;
734: 	unset($_SESSION['id_remise']);	
735: } 
736: else 
737: {
738: 	// Client sans remise, création de la remise de bienvenue [ date de fin = J+7 après date de session du jeu offert ]
739: 	// Désactivé le 06/09/2023 suite à la mise en ligne de la nouvelle offre
740: 	// $id_remise_bienvenue 	= 14 ;
```

## Chaîne active / commentaire — global web/global_librairies.php:17–34

```php
17: require 'app/modules/crm/parrainages/app_parrainages_functions.php';
18: require 'app/modules/data/statistiques/app_statistiques_functions.php';
19: require 'app/modules/ecommerce/app_ecommerce_functions.php';
20: require 'app/modules/entites/clients/app_clients_functions.php';
21: require 'app/modules/entites/clients_branding/app_clients_branding_functions.php'; // A SUPPRIMER A TERME
22: require 'app/modules/entites/clients_contacts/app_clients_contacts_functions.php';
23: require 'app/modules/entites/joueurs/app_joueurs_functions.php';
24: require 'app/modules/entites/utilisateurs/app_utilisateurs_functions.php';    
25: require 'app/modules/general/parametres/app_parametres_load.php';
26: require 'app/modules/general/branding/app_branding_functions.php';
27: require 'app/modules/jeux/bingo_musical/app_bingo_musical_functions.php';
28: require 'app/modules/jeux/blind_test/app_blind_test_functions.php';
29: require 'app/modules/jeux/cotton_quiz/app_cotton_quiz_functions.php';
30: require 'app/modules/jeux/sessions/app_sessions_functions.php';
31: require 'app/modules/jeux/sessions_branding/app_sessions_branding_functions.php'; // A SUPPRIMER A TERME
32: require 'app/modules/operations/evenements/app_evenements_functions.php';
33: require 'app/modules/operations/evenements_branding/app_evenements_branding_functions.php'; // A SUPPRIMER A TERME
34: require 'app/modules/qr_code/app_qr_code_place_generator.php'; 
```

