<!-- AUTO-UPDATE:BEGIN id="www-play-program-schedule-20260921" owner="codex" -->
# WWW/Play — horaire programme et sous-titre EP

## Preuves et préparation

[Pro README RAW](https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/canon/repos/pro/README.md), « Etat 2026-07-21 - Dashboard soirée/événement après quick-schedule » et « Update 2026-07-23 - Bibliothèque Hub: ajout depuis Programme et programmation générale » : heure de départ du programme, enregistrée sur la première partie, libellé « À partir de HHhMM ». Code : `ec_start_sessions_day_dashboard_view.php` appelle `app_games_hub_schedule_label_get` ; `app_games_hub_schedule_time_label_get` projette la première heure du programme.

[Journal RAW](https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb&raw=1), sections Septembre/Mars2026 : relecture fraîche identique à la précédente après normalisation CRLF. Rechargements WWW déjà consignés dans le rapport CTA20/09. Aucun nouvel écart ciblé signalé. Routes, jauge et patch probable-only préservés.

## Modifications

`app_session_public_schedule_time_label_get` résout le Hub et son programme entier puis réutilise le helper horaire Pro ; cache requête par session/Hub, ID session historique accepté. Une S2 prévue à21h affiche le début du programme19h30. Pas de retour à l’horaire propre d’une session autonome : sans programme Hub, heure masquée.

Fiches, cartes, historique, widgets WWW/Play et entêtes signin/signup affichent ce libellé. Page EP Hub et cartes WWW Hub utilisent directement les sessions du programme ; plage début/fin retirée. Les dates, SQL, tris et horaires stockés restent inchangés.

Sous-titre Hub : « Préviens l’organisateur de ta participation probable à la soirée. L’accès au jeu se fait sur place en scannant le QR code affiché. » ; variante événement : « à l'événement ». Texte de résultats d’une partie terminée et comportement autonome conservés.

## Bloc de partage retrouvé

`play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php` définit `$render_share_block` : « J’invite mes amis ! », partage natif, Facebook, WhatsApp, mail et copie du lien WWW. Appels après confirmation dans les branches Quiz/individuelle autonomes. La garde `!$session_hub_cta['is_hub']` les masque pour une session Hub depuis le patch CTA. Diagnostic demandé effectué dans ce lot. Complément utilisateur suivant : partage réactivé pour les probables Hub via [le correctif compte/partage](play-hub-account-return-share-2026-09-21.md), sans CTA runtime.

## Fichiers

- `global/web/app/modules/jeux/hubs/app_games_hub_participation_cta.php`
- `play/web/ep/ep_signin.php`
- `play/web/ep/ep_signup.php`
- `play/web/ep/ep_signup_private.php`
- `play/web/ep/modules/widget/NA__ep_widget_sessions_agenda.php`
- `play/web/ep/modules/communication/home/ep_home_history.php`
- `play/web/ep/modules/jeux/cotton_quiz/ep_cotton_quiz_reponses_form.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_player_connect.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_list_bloc.php`
- `play/web/ep/modules/jeux/sessions/ep_sessions_inscription_form.php`
- `play/web/ep/modules/jeux/hubs/ep_hubs_detail.php`
- `play/web/tests/ep_session_hub_cta_test.php`
- `www/web/fo/modules/entites/clients/fr/fo_clients_view_shared.php`
- `www/web/fo/modules/jeux/sessions/fr/fo_sessions_list_bloc.php`
- `www/web/fo/modules/jeux/sessions/fr/fo_sessions_view.php`
- `www/web/fo/modules/widget/fr/fo_widget_cotton_agenda.php`

Docs : README/TASKS Global, WWW, Play ; HANDOFF, CHANGELOG, cette note et index générés. Pas de modification Pro.

## Vérifications et limites

- `php play/web/tests/ep_session_hub_cta_test.php` :315 contrôles, dont S2→heure programme, alias ID historique, événement, absence horaire et autonome.
- `php play/web/tests/ep_hub_probable_capacity_test.php` :16 contrôles verts.
- `php play/web/tests/ep_hub_detail_contract_test.php` :OK.
- Lint16 fichiers PHP ; `git -c core.whitespace=blank-at-eol,blank-at-eof,space-before-tab,cr-at-eol diff --check` (fichiers historiques CRLF préservés) ; `npm run docs:sitemap`.

Pas de navigateur, DB, SSH, déploiement ou restart. Programme fourni par fixtures dans les tests ; rendu visuel réel non recetté. Les APIs éditoriales AI Studio et le BO ne sont pas des surfaces publiques concernées par ce lot.

Rollback : inverser seulement les hunks de ce complément ; baseline incrémentale dans `/tmp/cotton-ui-baseline`, ne pas restaurer les dépôts globalement car patches précédents non committés. Régénérer les index après rollback documentaire.
<!-- AUTO-UPDATE:END id="www-play-program-schedule-20260921" -->
