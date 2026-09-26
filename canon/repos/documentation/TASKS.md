# Tasks — documentation

<!-- AUTO-UPDATE:BEGIN id="documentation-tasks" owner="codex" -->

## 2026-09-26 — Capacités DEV contrôlées de Codex

- [x] Navigation API authentifiée START main puis SITEMAP/README/manifest/HANDOFF develop ; pages ciblées identiques aux copies locales. Journal AI Studio brut consulté ; drift ciblant ces pages : non trouvé.
- [x] Contrat intégré au runbook DEV existant : déploiement, logs, Playwright/auth, boucle bornée, restrictions et attente de preuve DB manuelle ; sécurité et contraintes START/README alignées avec AGENTS.md §7–20.
- [x] Routing transverse ajouté au manifest, README/TASKS documentation et HANDOFF actualisés ; aucune nouvelle page et aucun contrat applicatif modifié.
- [x] Trois sitemaps et 21 INDEX régénérés ; 199 entrées NDJSON et 8 nouveaux liens/ancres vérifiés, deux tests du générateur verts, blocs/IDs préservés, diff check et référence main inchangée. NDJSON/INDEX sans delta.
- [ ] Publication distante sur `develop` non effectuée ; aucune promotion vers `main` prévue dans ce chantier.


**25/09 — Documentation du patch robustesse Hub et du backport.** Canon/README/TASKS/markers/handoff actualisés ; audit historique conservé avec complément ; sitemap/index générés. Aucun changement main ni publication. [Rapport](../../../notes/hub-execution-robustness-backport-2026-09-25.md).

**25/09 — Hub-native, trois jeux : retour prématuré de l’iframe Remote corrigé localement, non déployé.** Traces navigateur Hub355/session28005 : return-document avant registration/runtime-ready, puis joinabilité et starting arrivent sur une iframe déjà repartie au Hub. Le poll historique de présence Master interprétait son absence pendant la préparation anticipée comme un départ. Il attend désormais l’autorisation native d’affichage avant de contrôler cette présence ; après reveal, absence réelle/terminal/quit conservent leurs traitements. Compteur et reveal continuent sur la même iframe. Adaptateur Bingo AL conservé ; aucun changement moteur/Global/START. [Preuves et recette](../../../notes/hub-open-players-foundations-2026-09-24.md#am-trois-jeux-retour-prématuré-du-child-remote-pendant-le-pregame--25092026).

## 2026-09-24 — Accès privé canonique

- [x] Préflight API privée : START main/develop, sitemap et manifest develop ; journal AI Studio brut consulté, aucun conflit ciblé identifié.
- [x] Contrat START/README/manifest : API Contents, COTTON_DOCS_TOKEN dédié, preuve d’abord, no guessing, branches et séparation AI Studio.
- [x] Générateur : chemins et API privées dans NDJSON, index Markdown privés ; champs/liens publics legacy conservés pour les contrôles du workflow inchangé.
- [x] Régénération et validation locale ; lecture privée sur main/develop sans requête au miroir (détails dans le rapport).
- [ ] Publication/promotion documentaire par l’opérateur ; vérifier ensuite le nouveau format distant sur les deux branches.
- [x] Vérifié le 26/09 : `/home/romain/Cotton/AGENTS.md` décrit désormais l’entrée privée et les capacités DEV contrôlées ; aucune modification de ce fichier dans ce chantier.

Aucun changement applicatif, aucun changement du workflow de mirroring. La suppression future du miroir est hors périmètre.
<!-- AUTO-UPDATE:END id="documentation-tasks" -->
