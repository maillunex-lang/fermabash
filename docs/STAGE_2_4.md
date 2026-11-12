# Stage 2.4: first agricultural production cycle

Implemented a complete single-field prototype loop:
1. Prepare soil (60 game ₽; tractor task).
2. Sow wheat (100 ₽; requires prepared soil).
3. Wait for crop growth.
4. Harvest with combine (3 t; requires free storage).
5. Store grain (6 t per warehouse).
6. Sell grain (450 ₽/t).

The original simple prototype's fixed six-second tasks and ten-second crop growth remain for rapid testing. These are not realistic agronomy timings. Game time remains seven real days per year, and no offline server simulation is implemented yet.

Rules live in `scripts/systems/production_rules.gd`, while the existing scene manages task progress and visuals. `prepared` is saved as an optional field in version-1 saves; older saves default to unprepared soil. Active `prepare` tasks are accepted by the save validator. Buildings remain compatible with earlier saves.

Tests cover job preconditions, costs, storage capacity, crop production, sales, active tasks, and save/load. No real-world device test, crop selection, field ownership, machinery inventory, or MMO synchronization yet.
