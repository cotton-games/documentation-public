# Audit — affichage session_update Bingo dans `games/web/logs_session.html` (3 fév 2026)

## Constats (lecture code)
- Niveau affiché : `getEffectiveLevel()` (l.176) prend `entry.level` puis `entry.raw.level` puis `raw.clientLevel/effective_level`; l’action-map peut écraser `entry.effectiveLevel` (l.203-238) mais Bingo `session_update` n’a pas de mapping, donc le niveau devrait rester celui du log (info dans l’exemple).
- Meta/fallback : `metaToText()` utilise d’abord `__view.meta`, sinon `buildMetaFallback()` (l.330+) avant `buildInfoMeta`. `buildMetaFallback → buildGenericMeta` (l.366+) lit `action` et `state` via `pickField` sans filtre d’exclusion; d’où les paires `action=start` ou `action=position` même pour des logs INFO.
- `pickField` (l.653+) lit `entry`, `entry.meta`, puis `entry.raw` / `entry.raw.meta`, puis `data[0]`; pour les logs WS, les champs racine `raw.action/raw.state/raw.scope/raw.track_position` sont bien remontés.
- Détection “transport debug” (`isTransportDebug`, l.401) ne s’applique qu’aux niveaux debug; donc l’affichage “debug” vu dans certains cas provient soit du niveau réel du log (`raw.level=debug`), soit d’un mapping action-map (non constaté pour session_update).
- Milestones : `detectMilestone` (l.700+) déclenche pour BT/Quiz si `msg.startsWith('session_update')` + `action=start` + `state=playing` + `index` (key `bt_start_<index>`). L’injection se fait en ordre chrono puis réordonnancement décroissant (l.870+). Le jalon dépend donc de `raw.action` et `raw.index` lus via `pickField`.

## Hypothèses sur “action=position”
- `buildGenericMeta` inclut `action` en tête de liste; si le log reçu porte `action:"position"` (ex : scope=media/position), le fallback Meta affichera `action=position`. Aucune exclusion n’est appliquée à `action` dans ce chemin.
- Pour un log `session_update` attendu avec `action=start`, si un autre `session_update` (scope=media/action=position) partage le même timestamp et passe le filtrage niveau, il peut apparaître juste avant/after et son Meta montre `action=position`.

## Pistes de correction (non implémentées)
1) Forcer les jalons BT/Quiz à ignorer les `session_update` où `scope !== 'state'` pour éviter les entrées media/position (condition supplémentaire dans `detectMilestone`).
2) Dans `buildGenericMeta`, exclure la clé `action` quand `scope === 'state'` et `state==='playing'` afin de privilégier d’autres champs (ou utiliser `track_position` comme numéro de titre si besoin).
3) S’assurer que `getEffectiveLevel` reste `info` : vérifier que les logs concernés ne sont pas remappés par `actions-map.json` et que `raw.level` est bien `info`.

## Emplacements clés
- Niveau affiché : l.176 `getEffectiveLevel`, l.203-238 `applyActionMap` (games/web/logs_session.html).
- Meta fallback qui injecte `action` : l.330-386 `buildMetaFallback → buildGenericMeta`.
- Lecture des champs WS (raw/action/state/index/track_position) : l.653+ `pickField`.
- Jalons BT/Quiz/Bingo : l.700+ `detectMilestone`; insertion ordre chrono puis tri desc : l.870+ (construction `rowsChrono` → tri `(b.sortTs - a.sortTs)`).
