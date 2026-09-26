# Cotton Documentation — Point d’entrée stable (START) / Stable entrypoint (START)

Ce fichier est le **point d’entrée unique et stable** pour les agents web IA.  
This file is the **single stable entrypoint** for web AI agents.

## Statut actuel (important) / Current status (important)
- **Convention de vérité : `main` = référence documentaire publiée de la production, avec travaux non déployés explicitement signalés ; `develop` = préparation documentaire.**
  **Truth convention: `main` = published production documentation, including explicitly marked undeployed work; `develop` = documentation preparation.**
- **Statut au 23/09/2026 : `hub_soiree` déployé selon confirmation opérateur ; évolutions propres à `sas_players`, `hub_session_readiness` et `cast` NON DÉPLOYÉES EN PROD.** Lire [l’état de livraison](canon/deployment-status.md), y compris sur `main`. La promotion de la documentation ne déploie aucune fonctionnalité.
- Utiliser `develop` pour préparer/mettre à jour la documentation de changements en cours.  
  Use `develop` to prepare/update documentation for ongoing changes.
- Utiliser `main` pour répondre à la question “que voit la prod maintenant ?”.  
  Use `main` to answer “what is production right now?”.
- Pour tout audit d’écart, comparer systématiquement les **mêmes chemins** entre `main` et `develop`.  
  For any drift audit, compare the **same paths** between `main` and `develop`.

## Accès privé canonique / Canonical private access

La source canonique est **`cotton-games/documentation`**. Tout agent disposant d’un accès GitHub authentifié lit directement ce dépôt privé via **GitHub API Contents**, au format raw. Les chemins documentaires restent la référence indépendamment du miroir.

Pour Codex, le token dédié est fourni uniquement par la variable d’environnement **`COTTON_DOCS_TOKEN`**. L’utiliser exclusivement pour les requêtes GitHub nécessaires à la **lecture** de cette documentation. Ne jamais afficher ni écrire sa valeur dans les logs, comptes rendus, exemples, fichiers ou commits ; ne jamais l’ajouter à une URL ni activer de trace des headers.

Headers requis (notation symbolique, variable à résoudre en mémoire) :

```text
Authorization: Bearer $COTTON_DOCS_TOKEN
Accept: application/vnd.github.raw+json
X-GitHub-Api-Version: 2022-11-28
```

Points d’entrée :
- `main` : https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=main
- `develop` : https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=develop
- Navigation : https://api.github.com/repos/cotton-games/documentation/contents/SITEMAP.ndjson?ref=develop
- Routing : https://api.github.com/repos/cotton-games/documentation/contents/DOCS_MANIFEST.md?ref=develop

Pour toute page identifiée : `https://api.github.com/repos/cotton-games/documentation/contents/<PATH>?ref=<BRANCH>` ; encoder chaque segment du chemin, choisir explicitement `main` ou `develop`. Ces lectures nécessitent les headers ci-dessus ; un lien seul ne transmet pas l’authentification. En cas d’accès refusé, signaler l’échec d’accès sans inventer le contenu ni basculer silencieusement sur le miroir.

## Parcours (sans supposition) / How to navigate (no guessing)

1) Lire `START.md` sur `main` comme entrée stable conformément à `AGENTS.md`, puis choisir la branche des lectures suivantes : `develop` pour la préparation documentaire, `main` pour la référence publiée PROD.
2) Lire `SITEMAP.ndjson` sur la branche choisie ; trouver la page par son champ `path`. Les champs `repository`, `branch`, `api_url` décrivent l’accès canonique. Lire `api_url` avec les headers requis.
3) Respecter l’ordre START → SITEMAP.ndjson → README.md → DOCS_MANIFEST.md → HANDOFF.md, puis la carte repo et les pages ciblées par le routing.
4) Ne jamais supposer un chemin absent du sitemap ou des pages ouvertes. Pour une autre branche, rechercher le même chemin dans son sitemap ; une absence reste une absence.
5) Si l’information n’est pas trouvée : répondre **`non trouvé`** en précisant les pages consultées.

`SITEMAP.md` et les `INDEX.md` sont les vues Markdown complémentaires. `START.md` reste le point d’entrée unique. Mettre à jour uniquement les blocs `AUTO-UPDATE` lorsqu’ils existent ; conserver leurs IDs.

## Comparer `develop` vs `main` / Compare `develop` vs `main`

Lire le **même chemin identifié** via l’API Contents avec `?ref=develop`, puis `?ref=main`. Conclure « Écart documentaire develop>main » ou « Aligné documentaire main=develop ». Ni un alignement ni une promotion documentaire ne prouvent un déploiement applicatif : conserver les exclusions explicites et vérifier l’état de livraison.

## Règle preuve d’abord (obligatoire) / Proof-first rule (mandatory)

Pour toute réponse, citer **l’URL API exacte utilisée (sans secret), le chemin, la branche et la section/heading**. Une information absente donne **`non trouvé`**. Les preuves historiques restent datées ; ne pas présenter une lecture antérieure du miroir comme une vérification privée actuelle.

## Compatibilité legacy / transition

`cotton-games/documentation-public` est un miroir temporaire pour coexistence et recette, **jamais la source canonique ni un prérequis pour les nouveaux prompts**. Les anciennes URLs publiques restent en place. Dans `SITEMAP.ndjson`, le champ `url` est **legacy / transition**, explicitement marqué `url_role: "legacy/transition"` ; utiliser `api_url` pour la lecture privée. `SITEMAP.txt` conserve les liens publics legacy pour les consommateurs existants et les contrôles du workflow inchangé.

Les citations publiques des anciens audits, notes et journaux sont **legacy / transition**, conservées comme preuves historiques, sans valeur de contrat d’accès actuel. Inventaire et validation : [migration d’accès privé](notes/documentation-private-access-2026-09-24.md). Aucun workflow de synchronisation, secret de publication ou dépôt public n’est modifié par ce chantier.

## Contraintes Codex

Codex dispose de capacités DEV contrôlées : déploiement via `deploy-dev.sh`, lecture des logs via `fetch-dev.sh` et recettes Playwright approuvées. Le [runbook DEV](canon/runbooks/dev.md#capacités-dev-contrôlées-de-codex--26092026) définit les wrappers, surfaces, états hors Git et la boucle autonome lorsqu’une tâche demande explicitement implémentation + validation DEV. Aucun accès direct hors outils approuvés, SSH, PROD, suppression distante, infrastructure, accès DB direct automatisé ou écriture DB automatisée. Aucun mécanisme DB read-only automatisé approuvé : fournir le SQL exact à l’opérateur et attendre son résultat manuel. L’accès documentaire GitHub n’accorde aucun accès applicatif.

## Discipline de génération / Generation discipline
- Avant tout patch évolutif, consulter le journal global AI Studio en mode raw pour détecter d’éventuels écarts hors workspace local, afin de recharger depuis les serveurs les scripts/dossiers potentiellement modifiés avant audit ou patch : `https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb`
- Le token AI Studio reste indépendant de `COTTON_DOCS_TOKEN` : ne jamais envoyer le token GitHub au lecteur AI Studio. Si le lecteur renvoie une enveloppe HTML, consulter le Markdown brut embarqué dans `const raw`. Aucun rechargement serveur ne doit être prétendu réalisé sans preuve opérateur.
- Ne jamais éditer `SITEMAP.md`, `SITEMAP.txt`, `SITEMAP.ndjson` ou un `INDEX.md` généré à la main : régénérer via le générateur.
  Never edit `SITEMAP.md` or generated `INDEX.md` manually: regenerate via the generator.
- Toute URL publiée contenant `...` est invalide et doit être corrigée (générateur/CI doit bloquer).  
  Any published URL containing `...` is invalid and must be fixed (generator/CI should block this).
