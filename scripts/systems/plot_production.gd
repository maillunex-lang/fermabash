extends RefCounted
## Each purchased field tile has an independent cultivation cycle.
const PREPARE_COST := 25
const SOW_COST := 40
const YIELD_TONS := 3
const GROW_SECONDS := 10.0
static func initial() -> Dictionary:
 return {"stage":0,"prepared":false,"growth":0.0}
static func valid(data: Variant) -> bool:
 if not data is Dictionary:
  return false
 if not data.has("stage") or not data.has("prepared") or not data.has("growth"):
  return false
 var stage: int = int(data["stage"])
 return stage >= 0 and stage <= 2 and float(data["growth"]) >= 0.0 and float(data["growth"]) <= 1.0
static func allowed(data: Dictionary, action: String, money: int, capacity_free: int) -> bool:
 if not valid(data):
  return false
 match action:
  "prepare":
   return int(data["stage"]) == 0 and not bool(data["prepared"]) and money >= PREPARE_COST
  "sow":
   return int(data["stage"]) == 0 and bool(data["prepared"]) and money >= SOW_COST
  "harvest":
   return int(data["stage"]) == 2 and capacity_free >= YIELD_TONS
 return false
static func finish(data: Dictionary, action: String) -> Dictionary:
 var next: Dictionary = data.duplicate()
 match action:
  "prepare":
   next["prepared"] = true
  "sow":
   next["prepared"] = false
   next["stage"] = 1
   next["growth"] = 0.0
  "harvest":
   next = initial()
 return next
static func grow(data: Dictionary, seconds: float) -> Dictionary:
 var next: Dictionary = data.duplicate()
 if int(next.get("stage",0)) == 1:
  next["growth"] = minf(1.0,float(next.get("growth",0.0))+seconds/GROW_SECONDS)
  if next["growth"] >= 1.0:
   next["stage"] = 2
   next["growth"] = 0.0
 return next
