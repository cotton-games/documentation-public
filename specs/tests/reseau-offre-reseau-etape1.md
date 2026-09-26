# Test manuel — Étape 1 BO `Offre réseau`

## But

Vérifier que la page BO historique `reseau_contrats` ne pilote plus le contrat cadre et ne montre plus que les offres affiliées hors cadre portées par la TdR.

## Préconditions

- une tête de réseau avec au moins:
  - une offre déléguée hors cadre active;
  - une offre déléguée hors cadre terminée ou non active si disponible;
  - un affilié avec offre propre;
  - un affilié couvert dans le cadre négocié si disponible.

## Vérifications

1. Ouvrir la fiche client siège puis cliquer sur `Gérer l'offre réseau`.
2. Vérifier que la page affiche `Gestion de l'offre réseau`.
3. Vérifier l'absence des blocs / CTA suivants:
   - `Activer un contrat cadre`
   - `Modifier`
   - `Clôturer ce contrat cadre`
   - `Montant cadre négocié`
   - `Cadre négocié`
   - `Offre support contrat cadre`
4. Vérifier que le tableau s'intitule `Offres affiliées hors cadre`.
5. Vérifier qu'une ligne hors cadre affiche au minimum:
   - affilié;
   - offre;
   - périodicité;
   - statut;
   - période;
   - remise;
   - tarif.
6. Vérifier qu'un affilié avec offre propre n'apparaît plus dans cette table.
7. Vérifier qu'une ligne hors cadre active expose encore l'action `Désactiver`.
8. Vérifier que le bloc `Commander une offre hors cadre` propose seulement des affiliés sans offre active.
9. Vérifier qu'une création depuis ce bloc poste bien une commande directe hors cadre, sans réactiver le cadre négocié.
10. Vérifier qu'une ligne terminée ou inactive reste en lecture seule.
11. Vérifier côté TdR / affilié que `Mon offre` continue à refléter l'activité hors cadre existante.

## Résultat attendu

- la page BO est recentrée en lecture/gestion des offres hors cadre;
- aucun wording ni pilotage contrat cadre / négocié n'est encore présent sur cette vue;
- l'étape 2A reste inchangée fonctionnellement.
