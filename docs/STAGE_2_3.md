# Stage 2.3: grid construction

Four buildings with deterministic grid footprints:
- Навес 1×1: 250 ₽
- Склад 2×2: 900 ₽
- Мастерская 3×3: 1600 ₽
- Агрокомплекс 4×4: 3000 ₽

Placement validates 16×16 boundaries, occupied cells, roads (rows 7 and 8), and reserved field cells (x 5–8, z 3–6). A transparent green/red preview indicates placement validity, and Escape or the Отмена button cancels construction. Costs are charged only after a valid placement. Mouse and touch placement are supported.

Existing saves with boolean `true` building values remain readable as 2×2 warehouses. New building values are catalog IDs in the same dictionary, so the save format version remains 1.

Tests: `tests/construction.gd` checks all footprints, overlapping structures, roads, fields, prices, cancellation, save/load and old saves. The existing smoke/UI/camera/system tests remain in CI and Android export. Actual phone touch and visual usability tests are still required.

Not in stage 2.3: road connectivity, demolition, building upgrades, production mechanics, or larger-world zoning.
