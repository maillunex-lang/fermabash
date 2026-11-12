extends RefCounted
## Seven real days per in-game year. Simulation authority will move server-side in MMO stage.
const SECONDS_PER_YEAR := 7.0 * 24.0 * 60.0 * 60.0
const DAYS_PER_YEAR := 365
static func day_from_seconds(seconds: float) -> int:
 return 1 + (int(floor(seconds * float(DAYS_PER_YEAR) / SECONDS_PER_YEAR)) % DAYS_PER_YEAR)
static func year_from_seconds(seconds: float) -> int:
 return 1 + int(floor(seconds / SECONDS_PER_YEAR))
