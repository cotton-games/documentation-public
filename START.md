# Cotton Documentation — Point d’entrée stable (START) / Stable entrypoint (START)

Ce fichier est le **point d’entrée unique et stable** pour les agents web IA.  
This file is the **single stable entrypoint** for web AI agents.

## Statut actuel (important) / Current status (important)
- **Convention de vérité: `main` = état prod, `develop` = travail en cours.**  
  **Truth convention: `main` = production state, `develop` = ongoing work.**
- Utiliser `develop` pour préparer/mettre à jour la documentation de changements en cours.  
  Use `develop` to prepare/update documentation for ongoing changes.
- Utiliser `main` pour répondre à la question “que voit la prod maintenant ?”.  
  Use `main` to answer “what is production right now?”.
- Pour tout audit d’écart, comparer systématiquement les **mêmes chemins** entre `main` et `develop`.  
  For any drift audit, compare the **same paths** between `main` and `develop`.

## Comparer `develop` vs `main` / Compare `develop` vs `main`
1) Prendre un chemin doc (ex: `canon/repos/quiz/README.md`).  
2) Ouvrir les 2 URLs RAW :
- Develop: `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/<PATH>`
- Main (prod): `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/<PATH>`
3) Conclure explicitement :
- “Écart develop>main” (changement non encore en prod), ou
- “Aligné main=develop” (déjà en prod).
4) Pour une vue globale des commits entre branches (optionnel):  
https://github.com/cotton-games/documentation-public/compare/main...develop

## Parcours (sans supposition) / How to navigate (no guessing)
1) Ouvrir l’index **agent-first texte** (1 URL/ligne, RAW) / Open **agent-first text index** (1 URL/line, RAW):  
https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.txt  
   Option machine-friendly (NDJSON): https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.ndjson

2) Si besoin d’une vue humaine, ouvrir le **SITEMAP markdown** (RAW):  
https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md

3) Depuis le SITEMAP/texte, ouvrir la **carte repo** du dépôt concerné (lien RAW).  
   From the SITEMAP/text, open the **repo card** of the relevant repository (RAW link).

4) Depuis la carte repo, ouvrir le **manifest des règles de doc / routing**.  
   From the repo card, open the **documentation rules / routing manifest**:  
https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/DOCS_MANIFEST.md

5) Suivre le manifest pour n’ouvrir que les pages nécessaires (liens RAW).  
   Follow the manifest to open only the necessary pages (RAW links).
- Mettre à jour uniquement les blocs `AUTO-UPDATE` quand c’est demandé.  
  Update only `AUTO-UPDATE` blocks when instructed.
- Ne jamais “deviner” une info absente des pages ouvertes.  
  Never “assume” information not present in the opened pages.

## Règle preuve d’abord (obligatoire) / Proof-first rule (mandatory)
Pour toute réponse : **citer l’URL RAW exacte** utilisée **et la section/heading**.  
For every answer: **cite the exact RAW URL(s)** used **and the section/heading**.

Si l’info n’est pas trouvée dans les pages ouvertes : **“non trouvé dans la documentation”**.  
If the information is not found in the opened pages: **“not found in documentation”**.

## Discipline de génération / Generation discipline
- Ne jamais éditer `SITEMAP.md` ou un `INDEX.md` généré à la main : régénérer via le générateur.  
  Never edit `SITEMAP.md` or generated `INDEX.md` manually: regenerate via the generator.
- Toute URL publiée contenant `...` est invalide et doit être corrigée (générateur/CI doit bloquer).  
  Any published URL containing `...` is invalid and must be fixed (generator/CI should block this).
