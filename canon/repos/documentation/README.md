# Dépôt documentation

<!-- AUTO-UPDATE:BEGIN id="documentation-readme" owner="codex" -->

**26/09 — Contrat agent DEV contrôlé.** Centralisé dans le [runbook DEV](../../runbooks/dev.md#capacités-dev-contrôlées-de-codex--26092026) et le [runbook sécurité](../../runbooks/security.md#frontière-dautorisation-codex-dev--26092026), routé par le manifest. Wrappers, logs, surfaces et états Playwright validés manuellement selon l’opérateur ; aucun wrapper/code applicatif modifié, aucun déploiement ni test navigateur effectué pour cette mise à jour sur `develop`.


**25/09 — Robustesse Hub documentée comme patch local non déployé.** [Audit ciblé, contrats effectivement implémentés, validation simulée et comparaison réelle main/develop/pregame](../../../notes/hub-execution-robustness-backport-2026-09-25.md). Ne pas confondre dry-run de backport, validation runtime et livraison PROD.

**25/09 — Hub-native, trois jeux : retour prématuré de l’iframe Remote corrigé localement, non déployé.** Traces navigateur Hub355/session28005 : return-document avant registration/runtime-ready, puis joinabilité et starting arrivent sur une iframe déjà repartie au Hub. Le poll historique de présence Master interprétait son absence pendant la préparation anticipée comme un départ. Il attend désormais l’autorisation native d’affichage avant de contrôler cette présence ; après reveal, absence réelle/terminal/quit conservent leurs traitements. Compteur et reveal continuent sur la même iframe. Adaptateur Bingo AL conservé ; aucun changement moteur/Global/START. [Preuves et recette](../../../notes/hub-open-players-foundations-2026-09-24.md#am-trois-jeux-retour-prématuré-du-child-remote-pendant-le-pregame--25092026).

Source canonique : `cotton-games/documentation` (privé). Contrat d’accès : [START.md](../../../START.md), routing : [DOCS_MANIFEST.md](../../../DOCS_MANIFEST.md).

Les agents authentifiés lisent via GitHub API Contents. Codex utilise `COTTON_DOCS_TOKEN` fourni par l’environnement, uniquement pour les lectures documentaires GitHub, avec les headers Authorization Bearer, Accept `application/vnd.github.raw+json` et X-GitHub-Api-Version `2022-11-28`. Aucune valeur de token dans les fichiers, logs, exemples ou commits ; accès AI Studio indépendant.

Navigation : START main → SITEMAP.ndjson (`repository`, `path`, `branch`, `api_url`) → README → DOCS_MANIFEST → HANDOFF → pages ciblées, sur `develop` pour ce chantier. Aucune supposition de chemin ; citer URL API sans secret, chemin, branche et heading ; information absente : `non trouvé`.

`main` = référence documentaire publiée correspondant à la PROD avec travaux non déployés explicitement signalés ; `develop` = préparation. Une promotion documentaire ne déploie rien.

Génération : `DOCS_BRANCH=develop npm run docs:sitemap` (ou `main`) ; source : `scripts/gen-sitemap.mjs`. Les index Markdown utilisent l’API privée ; `SITEMAP.txt` et le champ NDJSON `url` restent **legacy / transition** pour la compatibilité des consommateurs existants. Le mirroring temporaire reste inchangé.

Avant tout patch évolutif, consulter le journal AI Studio en raw selon START, pour repérer les modifications hors workspace. Codex utilise uniquement les capacités DEV contrôlées du [runbook](../../runbooks/dev.md#capacités-dev-contrôlées-de-codex--26092026) : déploiement/logs via wrappers et recettes Playwright, dans le scope autorisé. SSH/PROD/infrastructure, accès DB direct automatisé et écriture DB automatisée restent interdits ; aucun mécanisme DB read-only automatisé approuvé, SQL exact à soumettre à l’opérateur et résultat manuel à attendre.

Suivi : [TASKS.md](TASKS.md), [inventaire et validation](../../../notes/documentation-private-access-2026-09-24.md).
<!-- AUTO-UPDATE:END id="documentation-readme" -->
