# Stage 4: local land, independent fields, road logistics

## Implemented
- Expand owned farmland from 16×16 to at most 24×24 tiles, purchasing **only adjacent unowned tiles** for 100 in-game ₽ each. No real-money purchase. Old saves remain supported.
- Build individual independent fields for 80 ₽/tile, with separate preparation (25 ₽), sowing (40 ₽), growth (10 simulated seconds), harvesting (3 tonnes), storage capacity and selling through the existing grain economy. Tap a field tile to select it; the field tab acts on the selected field, or on the original starter field when no new field is selected. Different fields maintain independent state and growth.
- Dirt/gravel/asphalt roads for 40/100/250 ₽/tile, giving travel speed ×1.2/×1.5/×2. Route search uses weighted shortest travel time over **owned tiles** and avoids existing buildings. Field work dispatches a tractor from the original farm road to the selected field. Work begins after it arrives. Old idle road patrol demonstration is no longer used.
- Building placement checks land ownership, roads and fields. New fields/roads cannot overlap starter road, starter field or existing buildings. Purchases and finished agricultural operations autosave. Save file also preserves field states and any in-flight tractor route.
- Tests include separate fields, field state transitions, harvest capacity, pathfinding speed, obstacle detours, persistence, legacy saves, and Android build.

## Boundaries
This stage completes the **local single-player** mechanics of farm land, field operations and road-weighted dispatch. It does not yet provide server-enforced land titles, ownership conflicts between players, shared world coordinates, district cadastral maps, or online accounts. Those require stage 5. Farm area currently capped at 24×24 tiles; arbitrary infinite expansion is not claimed. Road navigation operates on owned land and prefers faster roads, but roads are **not mandatory** for vehicle passage. Machine field-work animation remains the original simple six-second cycle; its travel time is separately simulated. Further phone UX testing remains recommended.
