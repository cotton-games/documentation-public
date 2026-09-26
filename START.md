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

## Accès documentaire privé canonique

La source canonique est **`cotton-games/documentation`**, dépôt privé. Les agents disposant d’un accès GitHub authentifié le lisent directement via **GitHub API Contents**, au format raw. Codex utilise le token dédié fourni par la variable d’environnement **`COTTON_DOCS_TOKEN`**, uniquement pour les requêtes GitHub nécessaires à la lecture de cette documentation.

Ne jamais afficher ni écrire la valeur du token dans les fichiers, exemples, comptes rendus, logs ou commits. Ne jamais l’ajouter aux URLs ni activer de trace des headers.

Headers requis (variable à résoudre en mémoire) :

```text
Authorization: Bearer $COTTON_DOCS_TOKEN
Accept: application/vnd.github.raw+json
X-GitHub-Api-Version: 2022-11-28
```

Point d’entrée : https://api.github.com/repos/cotton-games/documentation/contents/START.md?ref=main

Toute page identifiée se lit par son chemin dans le dépôt privé : `https://api.github.com/repos/cotton-games/documentation/contents/<PATH>?ref=<BRANCH>`. Encoder les segments du chemin et choisir explicitement la branche. Un lien seul ne fournit pas l’authentification ; ajouter les headers ci-dessus. En cas d’accès refusé, signaler cet échec sans supposer le contenu ni basculer silencieusement vers un miroir.

## Parcours (sans supposition) / How to navigate (no guessing)

1) Lire **`START.md` sur `main`** comme point d’entrée stable, conformément à `AGENTS.md`.
2) Choisir explicitement la branche des lectures suivantes selon le besoin :
   - **Chantier de préparation : basculer vers `develop`** pour `SITEMAP.ndjson`, `README.md`, `DOCS_MANIFEST.md`, `HANDOFF.md` et les docs de travail. Cette bascule après START sur main est autorisée ; elle ne promeut aucun contenu vers main.
   - **Référence publiée PROD : rester sur `main`** pour ces mêmes documents, en conservant les travaux non déployés explicitement signalés.
3) Respecter l’ordre : **START → SITEMAP.ndjson → README → DOCS_MANIFEST → HANDOFF**, puis carte repo et pages ciblées par le routing. Pour la préparation :
   - https://api.github.com/repos/cotton-games/documentation/contents/SITEMAP.ndjson?ref=develop
   - https://api.github.com/repos/cotton-games/documentation/contents/README.md?ref=develop
   - https://api.github.com/repos/cotton-games/documentation/contents/DOCS_MANIFEST.md?ref=develop
   - https://api.github.com/repos/cotton-games/documentation/contents/HANDOFF.md?ref=develop
4) Résoudre un chemin réellement présent dans le sitemap ou une page ouverte, sans le deviner. Si l’entrée fournit `path` / `api_url`, utiliser son URL API privée en vérifiant la branche choisie.
5) **Compatibilité avec les anciens index de main :** si l’entrée ne contient que `title` / `url`, récupérer le chemin exact indiqué par `title` lorsqu’il s’agit d’un chemin, ou par le suffixe de l’URL après la branche (sans query/fragment, en décodant les segments). Lire ce chemin via l’API privée sur la branche choisie, **sans requête à l’URL publique**. Pour un lien relatif, le résoudre depuis le document ouvert. Un chemin ambigu ou absent ne doit pas être inventé.
6) Suivre le manifest et ne lire que les pages nécessaires. Mettre à jour uniquement les blocs `AUTO-UPDATE` lorsqu’ils existent ; conserver leurs IDs.

## Comparer `develop` vs `main` / Compare `develop` vs `main`

Pour un audit d’écart, lire **le même chemin documentaire identifié** dans le dépôt privé avec `?ref=main` puis `?ref=develop`. Signaler toute absence sur une branche. Conclure « Écart documentaire develop>main » ou « Aligné documentaire main=develop » selon les preuves ; un alignement documentaire ne prouve aucun déploiement applicatif.

Les deux branches peuvent diverger volontairement. Une correction du contrat d’accès sur main ne justifie ni une copie des contenus fonctionnels de develop ni une promotion globale.

## Règle preuve d’abord (obligatoire) / Proof-first rule (mandatory)

Citer **l’URL API exacte sans secret, le chemin, la branche et la section/heading** consultés. Si l’information n’est pas trouvée dans les pages ouvertes : répondre **`non trouvé`**, en précisant les pages consultées. Ne jamais présenter un contenu de develop comme l’état publié de main.

## Compatibilité legacy / transition

`cotton-games/documentation-public` est uniquement un miroir **legacy / transition**, jamais une source canonique, une entrée obligatoire ni un chemin de navigation prioritaire pour les agents authentifiés. Les anciennes URLs restent disponibles pour compatibilité.

Les URLs publiques des anciens sitemaps/index de main, ainsi que les citations publiques historiques des notes et journaux, sont **legacy / transition**. Les anciennes indications « single entrypoint » ou « raw obligatoire » dans ces surfaces legacy sont remplacées par le présent contrat START : les chemins servent à résoudre les lectures privées, pas à imposer le miroir. Cette correction ciblée ne migre pas leur générateur et ne change pas leur format.

## Contraintes Codex

Codex dispose de capacités DEV contrôlées : déploiement via `deploy-dev.sh`, lecture des logs via `fetch-dev.sh` et recettes Playwright approuvées. Le [runbook DEV](canon/runbooks/dev.md#capacités-dev-contrôlées-de-codex--26092026) définit les wrappers, surfaces, états hors Git et la boucle autonome lorsqu’une tâche demande explicitement implémentation + validation DEV. Aucun accès direct hors outils approuvés, SSH, PROD, suppression distante, infrastructure, accès DB direct automatisé ou écriture DB automatisée. Aucun mécanisme DB read-only automatisé approuvé : fournir le SQL exact à l’opérateur et attendre son résultat manuel. L’accès documentaire GitHub n’accorde aucun accès applicatif.

## Discipline de génération / Generation discipline
- Avant tout patch évolutif, consulter le journal global AI Studio en mode raw pour détecter d’éventuels écarts hors workspace local, afin de recharger depuis les serveurs les scripts/dossiers potentiellement modifiés avant audit ou patch : `https://global.cotton-quiz.com/ai_studio/hub/api/public_reader.php?f=documentation%2Fgeneral%2F0_ROADMAP.md&token=C4BOQcmxkXAT0JfWajhb`
- Le token AI Studio reste indépendant de `COTTON_DOCS_TOKEN` ; ne jamais envoyer le token GitHub au lecteur AI Studio. Si le lecteur renvoie une enveloppe HTML, consulter le Markdown brut embarqué dans `const raw`.
- Ne jamais éditer `SITEMAP.md` ou un `INDEX.md` généré à la main : régénérer via le générateur.  
  Never edit `SITEMAP.md` or generated `INDEX.md` manually: regenerate via the generator.
- Toute URL publiée contenant `...` est invalide et doit être corrigée (générateur/CI doit bloquer).  
  Any published URL containing `...` is invalid and must be fixed (generator/CI should block this).
