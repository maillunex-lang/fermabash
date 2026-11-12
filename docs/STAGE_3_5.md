# Stage 3.5: district-first farm creation (local Android prototype)

New Game now opens a Russian-language onboarding flow: player enters a farm name (3–40 characters), chooses one of **two demo municipal districts** (Уфимский, Стерлитамакский), and selects a free 2×2 start plot on a 12×12 schematic district grid. The plot validator rejects out-of-bounds and overlapping placements, and farm name/district/plot are saved with the farm. The in-game map no longer lists cities or settlements. It shows the selected district and **only this device's local farm**.

**Not yet implemented:** server accounts, authentication, unique names across players, authoritative administrative boundaries, shared land ownership, online list of farms, real geocoordinates, or multiplayer sync. These require server-side authoritative allocation and persistent database transactions. Do not represent this beta as online registration or a real cadastral map. The two district labels are demo coverage, not a complete official list of Bashkortostan districts. No change to the user's previously approved farm land expansion and roads.

Old save format remains accepted; old saves without a farm profile continue as before and do not automatically acquire a district. New Game creates a new save after onboarding. Physical Android testing is still needed.
