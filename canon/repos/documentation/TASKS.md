# Tasks — documentation

<!-- AUTO-UPDATE:BEGIN id="documentation-tasks" owner="codex" -->

## 2026-09-26 — Report ciblé du contrat DEV contrôlé sur main

- [x] Préflight API privée et comparaison des mêmes pages main/develop ; README/TASKS/INDEX documentation sur main : non trouvé (404).
- [x] Journal AI Studio brut consulté (HTTP 200), drift ciblant les pages concernées : non trouvé.
- [x] Reporter uniquement le contrat DEV dans START/README/runbooks ; ajouter le routage et le suivi minimal, conserver les historiques main et les exclusions de livraison.
- [x] Trois sitemaps et 21 INDEX régénérés avec le générateur main inchangé ; 55 entrées NDJSON et 12 liens/ancres ajoutés vérifiés, zones/IDs AUTO-UPDATE et historique main préservés, scope et références main/develop inchangées, `git diff --check` vert.
- [ ] Publication main non effectuée : aucun commit/push demandé. Aucun merge ni promotion globale develop → main.

Capacités disponibles selon validation manuelle opérateur ; aucun code/wrapper modifié, aucun déploiement/Playwright/DB/SSH/PROD exécuté. Détails et preuves dans [HANDOFF](../../../HANDOFF.md).
<!-- AUTO-UPDATE:END id="documentation-tasks" -->
