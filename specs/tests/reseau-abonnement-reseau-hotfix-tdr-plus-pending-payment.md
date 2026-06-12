# Recette — Hotfix `Abonnement réseau` TdR: entrée BO `+` et `pending_payment` PRO

Date: 2026-03-10

## Préconditions
- une fiche client non TdR disponible;
- une fiche client TdR disponible (`flag_client_reseau_siege=1`);
- une offre catalogue `Abonnement réseau` assurée en SI;
- au moins une offre cible activable pour le paramétrage interne.

## Cas 1 — Client non TdR
- ouvrir la fiche client non TdR;
- dans la section `Offres`, cliquer sur `+`;
- attendu:
  - le comportement historique est inchangé;
  - le formulaire standard `Ajouter une offre` s’ouvre sans menu rapide.

## Cas 2 — Client TdR: menu rapide
- ouvrir la fiche client TdR;
- dans la section `Offres`, cliquer sur `+`;
- attendu:
  - un choix rapide apparaît;
  - les deux entrées visibles sont `Offre propre` et `Offre réseau`.

## Cas 3 — Choix `Offre propre`
- depuis la fiche client TdR, cliquer `+` puis `Offre propre`;
- attendu:
  - le formulaire historique standard `offres_clients` s’ouvre;
  - aucun bloc de paramétrage interne `Abonnement réseau` n’est affiché par défaut.

## Cas 4 — Choix `Offre réseau`
- depuis la fiche client TdR, cliquer `+` puis `Offre réseau`;
- attendu:
  - le formulaire `offres_clients` est prérempli avec le client TdR et l’offre `Abonnement réseau`;
  - le bloc `Paramétrage interne Abonnement réseau` est visible immédiatement;
  - les champs métier affichés correspondent au négocié / cadre, pas au hors cadre.

## Cas 5 — Validation création `Abonnement réseau`
- renseigner le formulaire `Offre réseau`;
- enregistrer;
- attendu:
  - une ligne offre est créée pour la TdR;
  - son état initial est `En attente`;
  - la redirection BO ouvre la fiche d’édition de cette ligne;
  - le paramétrage interne reste visible sur la fiche créée.

## Cas 6 — PRO `Mon offre`: `pending_payment` + Stripe
- connecter le compte PRO de la TdR portant cette ligne `Abonnement réseau` en attente;
- ouvrir `Mon offre`;
- attendu:
  - la carte est libellée `Abonnement réseau`;
  - l’état est `En attente`;
  - le message `Votre abonnement réseau est en attente de paiement.` est visible;
  - le CTA `Payer et activer` est visible et pointe vers le parcours Stripe dédié.

## Cas 7 — Garde-fou hors cadre
- sur `Mon offre`, observer la carte `Abonnement réseau`;
- attendu:
  - aucune ligne hors cadre n’est listée dans cette carte;
  - seules les offres incluses `cadre` peuvent apparaître dans le détail `Abonnement réseau`.
