# Cotton Docs — Point d’entrée stable (START) / Stable entrypoint (START)

Ce fichier est le **point d’entrée unique et stable** pour les agents web IA.  
This file is the **single stable entrypoint** for web AI agents.

## Statut actuel (important) / Current status (important)
- **La documentation source est actuellement sur `develop`.**  
  **Source documentation is currently on `develop`.**
- La branche `main` héberge ce `START.md` comme **point d’entrée stable et immuable**.  
  The `main` branch hosts this `START.md` as a **stable, immutable entrypoint**.
- Quand la doc `main` sera prête, ce fichier basculera vers `SITEMAP.md` sur `main`.  
  When the `main` documentation is ready, this file will switch to `SITEMAP.md` on `main`.

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
