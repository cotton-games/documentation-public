# Remises 2026 — acquisitions propres des affiliés — 10/09/2026

Patch local destiné à DEV, non déployé. L’opérateur confirme la source locale à jour ; la vérification du script serveur avant PROD reste obligatoire. Aucun accès DB, Stripe ou serveur pendant cette passe.

## A. Fichiers modifiés

Global :

- `web/app/modules/ecommerce/app_ecommerce_functions.php` : scope canonique, lecture partagée du contexte, refus pending, signup, transmission de durée illimitée et protection SQL des snapshots.
- `web/app/modules/ecommerce/widget/app_ecommerce_bloc_offre_tarifaire_abn.php` : contexte d’acquisition et propriétaire explicites en preview.

Pro :

- `web/ec/modules/ecommerce/offres/ec_offres_form_step_1.php` : suppression du seul bloc V&B.
- `web/ec/modules/ecommerce/offres/ec_offres_script.php` : création/checkout, suppression du coupon legacy, refus conservateurs et ordre Price/snapshot.
- `web/ec/modules/ecommerce/offres/ec_offres_form_step_2.php` : messages de refus de reprise.
- `web/ec/modules/compte/offres/ec_offres_include_detail.php` : propriétaire exact pour le scope de preview.
- `web/ec/modules/compte/client/ec_client_script.php` : routage signup par type de règle.
- `web/ec/ec_remises_2026_own_checkout_test.php` : nouveau test transverse hors connexion.

WWW :

- `web/bo/www/modules/ecommerce/remises_2026/bo_remises_2026_functions.php` : ciblage des affiliés non-sièges.

Documentation : voir J. Aucun changement du handler Stripe, du barème réseau ou des fonctions de renouvellement.

## B. Scope

Ancien guard : `id_client_reseau > 0` interdisait tout affilié. Le helper existant `app_ecommerce_discount_scope_is_standard_unlimited_subscription_checkout` vérifie désormais le catalogue12/typeABN/paiement périodique, un acheteur identifié non-siège, propriétaire égal à cet acheteur et délégation explicitement zéro. Un flag de contexte différent de zéro, une délégation (y compris auto-délégation legacy), un support, un siège ou des champs indispensables absents restent refusés.

Les appelants chargent le client côté serveur. Le nouveau lecteur de contexte complète la qualification d’acquisition, sans devenir un moteur de remise : aucune sélection de règle ou de prix n’y est dupliquée. L’arbitrage de gagnante, les fenêtres de commande et le matching pipeline/typologie restent ceux du moteur générique.

## C. V&B

Suppression exacte des 20 lignes du bloc V&B : commentaire, condition ID92, titre, promesse de doublement de jauge et HTML associé. Variables partagées, conteneur, slug, flag de commande et widget commun conservés. Aucun doublement n’est ajouté dans la création ni la validation ; la jauge sélectionnée reste transmise telle quelle. Catalogue10 et historique inchangés. Le retrait de la promesse met fin à la consigne manuelle dans ce parcours, sans mutation des jauges déjà attribuées.

## D. Legacy5%

Suppression de la branche de création dynamique `client-5PERCENTOFF-timestamp`, ciblée affiliation1774 ou acheteur1294 : plus de coupon à vie ajouté, de remplacement indépendant de `discounts`, de multiplication du prix ni d’écrasement du libellé/pourcentage par cette branche.

Les coupons, subscriptions, schedules et sessions Stripe historiques ne sont ni recherchés ni modifiés. Un achat propre LiveStation sans règle applicable reste au prix de référence normal ; avec règle, une seule gagnante2026 alimente snapshot et Stripe.

## E. Runtime

- Preview : le futur propriétaire est l’acheteur chargé par le lecteur partagé ; les contextes invalides affichent une erreur et ne déclenchent pas la remise propre.
- Step1 : un contexte valide en session reste délégué même sans token explicite dans le POST ; un contexte présent mais expiré/incomplet/invalide ne crée aucune offre propre. Le marqueur expiré est conservé après lecture pour ne pas transformer le POST suivant en achat propre.
- Step2 : contrôle propriétaire, état2/pending, absence de subscription, délégation et cohérence avec le contexte ; tout refus intervient avant la préparation Stripe. Une délégation persistée doit passer le validateur réseau existant, même si aucun contexte de session n’est présent.
- Détail : qualification de l’offre et de son propriétaire, avec refus d’un spectateur différent. Les snapshots historiques ne sont pas recalculés par cette preview de checkout.
- Reprise2026 : le reset vers la référence précède maintenant le Price Stripe, puis la gagnante est résolue et appliquée une fois. Cela évite un Price déjà net auquel on ajouterait encore un coupon.
- Les writes de reset/application sont conditionnés à `id_etat=2`, délégation zéro et absence de subscription ; une relecture refuse une offre devenue active/attachée pendant la préparation. Les échecs de reset, coupon ou snapshot empêchent l’ouverture d’un checkout sans la remise annoncée.
- Durée illimitée : les deux résolveurs passent explicitement zéro au plan d’exécution après normalisation, au lieu de laisser `null` devenir la durée par défaut. Les métadonnées annoncent alors coupon sans limite, durée0 et aucun schedule. Durées finies et exception annuelle conservées.

## F. BO et signup

Le filtre BO partagé ne conserve que l’exclusion des sièges. Il est réutilisé pour candidats manuels, autorisation d’ajout, sélection en masse et ciblage automatique. Le BO ne préjuge pas de la future délégation ; le runtime reste responsable de l’acquisition. Pipeline et typologie spécifiés se combinent avec AND.

Le rattachement signup2026 accepte les affiliés non-sièges, dans les limites existantes des règles manuelles actives. Le script classe d’abord via `app_ecommerce_discount_rule_is_remises_2026` : un échec2026 ne tombe plus dans `ecommerce_remises_clients` legacy. Les véritables règles legacy conservent leur chemin.

## G. Réseau

La chaîne déléguée demeure catalogue → pricing réseau selon volume actif → prix net Cotton → `price_data` Stripe. Aucun coupon2026 ou réseau additionnel. Barème, calcul du volume, cadre/hors-cadre, snapshots contractuels, renouvellement et synchronisation Invoice non modifiés. Tests existants de ces contrats exécutés en complément des payloads checkout délégués simulés Beer’s Corner/LiveStation.

## H. Anciennes pending

Refus `checkout_legacy_discount_pending` si le libellé contient `PERCENTOFF` ou `Coupon Stripe`, ou si une offre propre porte un pourcentage positif sans `id_remise`. Cette dernière règle est volontairement conservatrice et peut également refuser une ancienne remise manuelle non rattachée à une règle. Aucun recalcul ou nettoyage implicite ; message demandant une nouvelle préparation aux conditions actuelles.

Offre active/terminée ou avec subscription : refus `checkout_offer_not_pending`. Propriétaire ou délégation incohérents : refus explicite. Les tests vérifient absence de nouveaux coupons, de payload et de writes sur ces reprises.

## I. Tests et validation commerciale

Depuis `/home/romain/Cotton` :

```sh
php pro/web/ec/ec_remises_2026_own_checkout_test.php
php global/web/tests/ecommerce_network_delegated_contract_renewal_test.php
php global/web/app/modules/ecommerce/app_ecommerce_network_delegated_contract_support_test.php
php pro/web/ec/ec_stripe_network_delegated_renewal_contract_test.php
php global/web/tests/ecommerce_stripe_subscription_period_test.php
php global/web/tests/ecommerce_stripe_invoice_period_test.php
php pro/web/ec/ec_stripe_subscription_period_contract_test.php
```

Résultats : **429 contrôles** dans le nouveau test, **six tests existants OK**. Les logs d’échec de coupon/snapshot dans le nouveau test correspondent aux pannes volontairement injectées. `php -l` sur les neuf fichiers PHP ajoutés/modifiés et `git diff --check` sur les repos concernés : OK.

Le test extrait les fonctions de production sans bootstrap applicatif et exécute le vrai script PRO step1/step2 avec doubles de dépendances DB/Stripe. Il couvre standard, V&B, LiveStation et autre affiliation, sans/avec règle, mensuel/annuel, durée0/12mois, reprise2026, délégations1294/1774 au net, siège, support, auto-délégation, contexte invalide/expiré, refus pending/historique et échecs de préparation. Les blocs réels de qualification du widget/détail sont exécutés ; les fonctions BO et le branchement signup sont exercés avec des fixtures.

Les assertions vérifient gagnante, `id_remise`, référence, net, libellé, pourcentage, coupon unique, métadonnées Stripe, choix schedule et snapshot de ligne de commande. Les fixtures renvoyées par le double DB ne certifient pas l’exécution MySQL des requêtes ni les données actuellement déployées. Le rendu intégral des pages et le webhook complet ne sont pas exécutés par le nouveau test ; les contrats existants du webhook/réseau et le helper réel de snapshot commande sont vérifiés séparément.

Recette connectée DEV restant à faire par l’opérateur : cibler un affilié non-siège dans le BO, contrôler preview/pending, ouvrir un checkout test, payer, recevoir les webhooks et vérifier commande/facture et éventuel schedule. Comparer tous les champs ci-dessus, puis refaire sans règle et en délégation. Tester aussi le message de refus d’une ancienne pending. Aucune de ces opérations n’a été exécutée pendant ce patch.

## J. Documentation

- `canon/repos/{global,pro,www}/README.md` et `TASKS.md` : nouveau contrat et recette restante.
- `notes/plan_migration_reseau_branding_contenu.md` : acquisition propre versus pricing délégué, suppression legacy, non-rétroactivité.
- `canon/interfaces/ecommerce-offer-change.md` : séparation avec le chantier futur de changement de subscription.
- `HANDOFF.md`, `CHANGELOG.md` et le présent rapport.
- `npm run docs:sitemap` : sitemap texte/Markdown et index régénérés par le script officiel, sans édition manuelle.

## K. Limites, risques résiduels et retour arrière

La recette authentifiée DEV de bout en bout reste nécessaire : les tests sont hors connexion et ne certifient ni données réelles ni réception de webhooks. Vérification du script et des sources coordonnées avant PROD convenue avec l’opérateur. Déployer ensemble les appelants et helpers Global/Pro/WWW ; les nouveaux appels requièrent la nouvelle base Global.

Les anciennes pending remisées sans règle exigent une intervention explicite pour préparer une nouvelle commande. Un ancien lien de paiement Stripe déjà émis n’est pas révoqué par ce patch, conformément à la non-rétroactivité ; seule une nouvelle préparation dans Cotton passe par les nouveaux guards.

Retour arrière du code : restaurer ensemble les fichiers applicatifs de cette passe depuis leur version précédente ; aucune migration à annuler. Cela rétablirait aussi les anciennes exclusions et le coupon automatique : décision métier à prendre explicitement. Le retour arrière du code ne réécrit pas les données ni les subscriptions créées entre-temps.

| Cas | Résultat du patch vérifié localement |
| --- | --- |
| V&B achat propre | Remises2026 possible, aucun ancien avantage V&B dans le parcours |
| LiveStation achat propre | Remises2026 possible, aucun coupon réseau5% |
| Autre affilié achat propre | Remises2026 possible |
| Siège réseau | Hors scope Remises2026 |
| Offre déléguée | Pricing réseau Cotton, net transmis sans coupon |
| Support réseau | Hors scope standard |
| Subscription historique avec coupon | Inchangée ; reprise comme nouvelle pending refusée |

**Aucun déploiement effectué. Aucune donnée PROD/DEV modifiée. Aucun abonnement Stripe existant modifié.**
