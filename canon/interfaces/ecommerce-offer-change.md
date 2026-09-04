# Changement d'offre — contrat Cotton → Stripe → Cotton

## Statut et périmètre

Ce document décrit le contrat cible d'un chantier futur. Il ne décrit pas une fonctionnalité actuellement livrée et n'autorise aucune mutation d'offre en production.

La première version concerne les clients en propre dont l'offre cible est `12 — Abonnement Cotton illimité`. Les offres déléguées hors cadre sont explicitement exclues.

## 1. Cotton porte l'intention commerciale

Cotton est la source de vérité de l'offre commerciale, de la jauge, de la périodicité proposée, des règles d'éligibilité selon l'usage et la typologie client, du pricing, des remises et des contraintes d'upsell. Un Price ou une Subscription Stripe ne doit jamais être interprété comme la source canonique de cette intention.

Les dimensions modifiables de la V1 sont la jauge et la périodicité. Une évolution est autorisée uniquement si :

- `jauge_cible > jauge_actuelle` ;
- `duree_periode_cible >= duree_periode_actuelle`.

| Évolution | V1 |
|---|---|
| hausse de jauge mensuelle → mensuelle | autorisée |
| hausse de jauge mensuelle → annuelle | autorisée |
| hausse de jauge annuelle → annuelle | autorisée |
| hausse de jauge annuelle → mensuelle | interdite |
| baisse de jauge | interdite |
| périodicité seule, sans hausse de jauge | hors contrat |

Une hausse de jauge ne doit jamais réduire ni interrompre un engagement annuel en cours. L'éligibilité ne se déduit pas d'une simple comparaison de montants Stripe.

## 2. Stripe exécute la décision Cotton

Après validation par Cotton :

1. Cotton calcule et valide le Price cible en réutilisant autant que possible la mécanique moderne de souscription initiale.
2. Cotton demande la modification de la Subscription.
3. Stripe calcule/applique le prorata et active la nouvelle configuration.
4. Stripe devient l'autorité sur la réalité effectivement active et facturée, mais pas sur l'intention commerciale qui a précédé l'appel.

## 3. Stripe confirme, Cotton synchronise

Les webhooks Stripe réingèrent le Price actif, le statut, les montants facturés, le prorata et la période courante. Cette synchronisation confirme l'exécution; elle ne reconstruit pas une nouvelle intention commerciale.

En particulier, un événement `customer.subscription.updated` isolé ne constitue jamais une preuve suffisante d'intention commerciale. La chaîne canonique est donc :

`intention Cotton → projection/exécution Stripe → réalité Stripe confirmée → synchronisation Cotton`.

Le contrat inverse `Stripe Price → offre Cotton` est interdit comme modèle canonique.

## Parcours Pro cible

`Pro Cotton` → `Modifier mon abonnement` → calcul Cotton des évolutions autorisées → affichage jauges/périodicités/pricing/remises → affichage de l'avantage commercial → éventuelle preview de prorata Stripe → confirmation client → ensure/création du Price cible → update de la Subscription Stripe → webhook Stripe → synchronisation Cotton.

L'écran doit afficher le prix de référence, la remise applicable, le prix net, la périodicité et l'économie ou l'avantage pertinent. Le parcours doit rester commercialement lisible et incitatif.

## Customer Portal Stripe

Le Customer Portal Stripe n'est pas le parcours moderne de changement d'offre. Là où cette capacité commerciale est encore active, elle devra être désactivée avant l'ouverture du nouveau parcours Cotton. Le portail peut rester disponible pour ses fonctions non commerciales utiles.

Hypothèse architecturale forte, non démontrée à ce stade : le changement d'offre via le portail ne fonctionne probablement plus correctement parce que le nouveau modèle de souscription a conservé Cotton comme moteur commercial sans remettre le parcours historique de modification au niveau de ce contrat. Cette cause reste à confirmer par un audit du code et de la configuration Stripe avant implémentation.

## Séparation des offres déléguées hors cadre

Pour les offres déléguées hors cadre, le contrat actuel reste inchangé :

- pricing et remise réseau pilotés par Cotton ;
- repricing au renewal piloté par le snapshot contractuel ;
- Prices Stripe inline ou dynamiques possibles ;
- aucune mutation via le Customer Portal standard.

Leur éventuel changement d'offre fera l'objet d'un chantier distinct.

## Gates du futur chantier

- auditer les CTAs et configurations Customer Portal qui autorisent encore un changement commercial ;
- identifier la mécanique moderne de souscription initiale à réutiliser pour pricing, remise et ensure Price ;
- définir la preuve persistante de l'intention Cotton et sa corrélation avec l'update Stripe ;
- définir preview de prorata, idempotence, replay webhook, erreurs et rollback ;
- couvrir la matrice jauge/périodicité et la protection des engagements annuels ;
- maintenir hors scope les offres déléguées hors cadre.
