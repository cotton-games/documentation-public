# Recette manuelle — Étape 2 `Abonnement réseau`

Date: 2026-03-10
Repo: `www`

## Objectif

Valider la séparation BO:
- `Offre réseau` = hors cadre
- `Abonnement réseau` = négocié / cadre

## Préconditions

- client TdR avec `flag_client_reseau_siege=1`
- au moins un affilié rattaché
- au moins une offre standard sélectionnable comme offre incluse cible

## Cas à vérifier

1. Depuis la fiche client TdR, cliquer `Ajouter une offre`.
2. Vérifier que l’offre `Abonnement réseau` est proposée dans la liste `Offre` pour une TdR.
3. Depuis un client non TdR, vérifier qu’elle n’est pas proposée.
4. Sélectionner `Abonnement réseau`.
5. Vérifier que le formulaire d’ajout standard n’est pas altéré pour ce cas.
6. Enregistrer.
7. Vérifier que la ligne créée redirige vers sa fiche d’édition.
8. Vérifier que l’offre créée apparaît dans la section `Offres` de la fiche client TdR avec le libellé `Abonnement réseau`.
9. Vérifier que l’état initial affiché est `En attente` / `En attente de paiement`.
10. Vérifier que le paramétrage négocié se fait ensuite sur la fiche de l’offre:
   - montant négocié
   - périodicité
   - nb affiliés inclus
   - offre incluse cible
   - jauge cible
11. Ouvrir la vue détail de cette offre.
12. Vérifier que la vue `Offres incluses` n’affiche que les lignes `cadre`.
13. Vérifier qu’aucune ligne hors cadre n’apparaît dans cette vue.
14. Passer l’offre à `Active` via l’édition standard.
15. Vérifier que l’abonnement devient effectif et que les offres incluses gardent une lecture cohérente.
16. Revenir sur la page `Offre réseau`.
17. Vérifier qu’elle continue d’afficher uniquement les lignes hors cadre.
18. Vérifier qu’un abonnement réseau non payé n’est jamais présenté comme effectif sur sa vue détail.
