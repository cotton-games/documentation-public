# Dépôt documentation

<!-- AUTO-UPDATE:BEGIN id="documentation-readme" owner="codex" -->

## 26/09/2026 — Contrat DEV contrôlé sur main

Le [runbook DEV](../../runbooks/dev.md#capacités-dev-contrôlées-de-codex--26092026) centralise les capacités locales approuvées de Codex : déploiement DEV ciblé et vérification par taille via `deploy-dev.sh`, logs en lecture seule via `fetch-dev.sh`, Playwright/Chromium et états PRO/PLAY/BO hors Git, boucle autonome bornée pour les tâches demandant implémentation + validation DEV. Le [runbook sécurité](../../runbooks/security.md#frontière-dautorisation-codex-dev--26092026) conserve les interdictions SSH/PROD/infrastructure/DB et de contournement. Aucun mécanisme DB read-only automatisé approuvé ; fournir le SQL exact et attendre la preuve manuelle.

Capacités validées manuellement selon l’opérateur ; ce report documentaire ne déploie aucune fonctionnalité et n’exécute aucune recette. `main` reste la référence publiée avec exclusions explicites ; les divergences fonctionnelles de `develop` sont conservées.

Entrée privée : [START](../../../START.md), routage : [DOCS_MANIFEST](../../../DOCS_MANIFEST.md). Génération sur main : `DOCS_BRANCH=main npm run docs:sitemap`, avec le générateur existant et ses URLs legacy ; les lectures authentifiées résolvent les chemins par l’API privée selon START. Aucun générateur ou workflow modifié.

Suivi : [TASKS](TASKS.md), [HANDOFF](../../../HANDOFF.md). Ces pages de suivi minimales sont ajoutées car absentes de main ; aucun historique develop hors contrat DEV n’est importé.
<!-- AUTO-UPDATE:END id="documentation-readme" -->
