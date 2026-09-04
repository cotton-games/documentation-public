# Tests manuels — Réseau Étape 2A périodicités et affichage `Mon offre`

## Pré-requis
- Une tête de réseau avec contrat cadre et offre réseau support existants.
- Au moins deux affiliés de test rattachés au siège.
- Accès BO `reseau_contrats` et PRO `Mon offre`.

## 1) Cas montant négocié uniquement
- Préparer une TdR avec contrat actif, socle négocié non nul et affiliés inclus dans le cadre, sans aucune ligne hors négociation active.
- Vérifier dans `Mon offre` côté TdR:
  - présence du bloc `Montant négocié pour {n} affiliés : ...`
  - présence du TTC sur ce bloc
  - présence de la période du bloc négocié
  - présence de la liste détaillée des affiliés inclus au format `Affilié — Offre`
  - absence complète des blocs `Coût total mensuel` / `Coût total annuel`
  - absence complète du bloc `abonnements affiliés hors négociation`

## 2) Cas hors négociation uniquement avec mensuel seul
- Préparer une TdR sans affilié inclus dans le cadre et avec au moins une délégation hors cadre active mensuelle payée par la TdR.
- Vérifier dans `Mon offre`:
  - présence de `Coût total mensuel`
  - absence de `Coût total annuel`
  - présence du bloc `{n} abonnements affiliés : {montant agrégé} € HT`
  - présence des lignes détaillées au format `Affilié — Offre — montant — / mois`
  - présence du TTC sur chaque ligne détaillée
  - présence d’une `Période du ... au ...` pour chaque ligne détaillée

## 3) Cas hors négociation uniquement avec annuel seul
- Préparer une TdR sans affilié inclus dans le cadre et avec au moins une délégation hors cadre active annuelle payée par la TdR.
- Vérifier dans `Mon offre`:
  - présence de `Coût total annuel`
  - absence de `Coût total mensuel`
  - présence des lignes détaillées au format `Affilié — Offre — montant — / an`
  - présence d’une `Période du ... au ...` pour chaque ligne détaillée

## 4) Cas hors négociation mixte mensuel + annuel
- Dans le BO `reseau_contrats`, saisir un socle `150.00` en `Mensuel`.
- Activer un affilié hors cadre en `Mensuel`, puis un second en `Annuel`.
- Vérifier en base:
  - `ecommerce_reseau_contrats.id_paiement_frequence = 1`
  - chaque ligne `ecommerce_offres_to_clients` affiliée porte le bon `id_paiement_frequence` (`1` ou `2`)
- Vérifier dans `Mon offre` côté TdR:
  - présence d’un `Coût total mensuel`
  - présence d’un `Coût total annuel`
  - chaque ligne hors négociation affiche `Affilié — Offre — montant — / mois|/ an`
  - chaque ligne hors négociation affiche sa propre période

## 5) Cas mixte
- Préparer une TdR avec:
  - un socle négocié actif et des affiliés inclus dans le cadre
  - au moins une délégation hors cadre active payée par la TdR
- Vérifier dans `Mon offre`:
  - présence des coûts totaux mensuel et/ou annuel selon les lignes actives
  - présence du bloc `Montant négocié pour {n} affiliés`
  - présence du bloc `+ {n} abonnements affiliés hors négociation`
  - absence de total HT fusionné mensuel/annuel sur ce bloc hors négociation
  - séparation visuelle des deux familles de données

## 6) Agrégation séparée sans conversion
- Cas attendu:
  - socle mensuel `150`
  - offre affiliée mensuelle `50`
  - offre affiliée annuelle `500`
- Vérifier:
  - total mensuel affiché = `200` HT
  - total annuel affiché = `500` HT
  - aucune conversion de `500 / 12` n’apparaît dans les vues BO/PRO

## 7) Remise applicable
- Préparer une ligne hors négociation avec une remise commerciale persistée sur `ecommerce_offres_to_clients.remise_pourcentage`.
- Vérifier dans `Mon offre`:
  - affichage de `{x} % remise réseau` sur la ligne détaillée concernée
  - absence de remise sur les lignes non remisées

## 8) Remise non applicable
- Préparer une ligne hors négociation sans remise commerciale persistée.
- Vérifier dans `Mon offre`:
  - absence complète de la mention `remise réseau`
  - ne jamais voir `0 % remise réseau`

## 8bis) Navigation bloc affiliés
- Vérifier dans `Mon offre`:
  - présence du CTA `Gérer mes affiliés`
  - positionnement du CTA au-dessus du bloc `Montant négocié...` quand des blocs réseau sont affichés

## 9) Régression activation support
- Préparer une TdR avec offre réseau support encore `En attente` puis activer au moins une délégation hors cadre payée par la TdR.
- Vérifier:
  - l’offre réseau support passe automatiquement `Active`
  - `Mon offre` n’affiche plus le CTA `Payer et activer`
  - aucune souscription Stripe séparée supplémentaire n’est demandée pour l’offre support

## 10) Cas cadre pur préservé
- Préparer une TdR avec cadre pur, sans aucune délégation hors cadre active payée.
- Vérifier:
  - le comportement attendu du cadre pur reste inchangé
  - une offre support encore `En attente` peut conserver son CTA de premier paiement

## 11) Aucun annuel
- Laisser uniquement le socle et des offres affiliées mensuelles.
- Vérifier:
  - la ligne annuelle reste à `0` ou est masquée selon la vue
  - le total mensuel reste correct

## 12) Aucun mensuel
- Passer le socle en `Annuel` et ne garder que des offres affiliées annuelles.
- Vérifier:
  - le total annuel agrège socle + affiliés annuels
  - le total mensuel reste nul
  - la ligne support du contrat garde la périodicité annuelle du socle

## 13) Résiliation du socle
- Programmer la résiliation / clôture du socle réseau.
- Vérifier dans `Mon offre`:
  - le message rappelle que les offres affiliées déjà engagées restent actives jusqu’à leur propre échéance
  - les lignes affiliées encore actives restent listées avec leur périodicité

## 14) Remise volume
- Créer plusieurs offres affiliées hors cadre pour franchir un palier de remise.
- Vérifier:
  - le pourcentage de remise réseau reste déterminé par le volume actif du réseau
  - le montant net appliqué à chaque ligne reste calculé sur la périodicité de la commande concernée
