extends RefCounted
## Deterministic production rules; costs and yield are prototype values.
const PREPARE_COST := 60
const SOW_COST := 100
const YIELD_TONS := 3
const GRAIN_PRICE := 450
const CAPACITY_PER_WAREHOUSE := 6

static func capacity(structures: Dictionary) -> int:
 var count := 0
 for value in structures.values():
  if value == true or value == "warehouse":
   count += 1
 return count * CAPACITY_PER_WAREHOUSE

static func can_prepare(stage: int, prepared: bool, job: String, cash: int) -> bool:
 return stage == 0 and not prepared and job == "" and cash >= PREPARE_COST

static func can_sow(stage: int, prepared: bool, job: String, cash: int) -> bool:
 return stage == 0 and prepared and job == "" and cash >= SOW_COST

static func can_harvest(stage: int, job: String, grain: int, structures: Dictionary) -> bool:
 return stage == 2 and job == "" and grain + YIELD_TONS <= capacity(structures)

static func sale_value(tons: int) -> int:
 return maxi(0,tons)*GRAIN_PRICE
