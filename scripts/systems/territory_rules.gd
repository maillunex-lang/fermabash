extends RefCounted
## Owned land beyond original 16x16; purchases use in-game rubles only.
const START_SIZE := 16
const MAX_SIZE := 24
const LAND_PRICE := 100
const FIELD_PRICE := 80
const ROAD_PRICES := {"dirt":40,"gravel":100,"asphalt":250}
const ROAD_SPEED := {"dirt":1.2,"gravel":1.5,"asphalt":2.0}
static func key(cell: Vector2i) -> String:
 return "%d,%d" % [cell.x,cell.y]
static func within(cell: Vector2i) -> bool:
 return cell.x >= 0 and cell.y >= 0 and cell.x < MAX_SIZE and cell.y < MAX_SIZE
static func owned(cell: Vector2i, extra: Dictionary) -> bool:
 return within(cell) and ((cell.x < START_SIZE and cell.y < START_SIZE) or extra.has(key(cell)))
static func can_buy(cell: Vector2i, extra: Dictionary) -> bool:
 if not within(cell) or owned(cell,extra):
  return false
 for neighbor in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
  if owned(cell+neighbor,extra):
   return true
 return false
static func occupied(cell: Vector2i, structures: Dictionary, fields: Dictionary, roads: Dictionary) -> bool:
 var k := key(cell)
 if fields.has(k) or roads.has(k):
  return true
 for position in structures:
  var parts: PackedStringArray = str(position).split(",")
  if parts.size() != 2:
   return true
  var origin := Vector2i(int(parts[0]),int(parts[1]))
  var size: int = 2
  if structures[position] is String and structures[position] == "shed":
   size = 1
  elif structures[position] is String and structures[position] == "workshop":
   size = 3
  elif structures[position] is String and structures[position] == "complex":
   size = 4
  if cell.x >= origin.x and cell.y >= origin.y and cell.x < origin.x+size and cell.y < origin.y+size:
   return true
 return false
static func can_develop(cell: Vector2i, extra: Dictionary, structures: Dictionary, fields: Dictionary, roads: Dictionary) -> bool:
 if not owned(cell,extra) or occupied(cell,structures,fields,roads):
  return false
 # Existing road and cultivated starter field are reserved.
 if cell.x < START_SIZE and cell.y < START_SIZE:
  if cell.y == 7 or cell.y == 8:
   return false
  if cell.x >= 5 and cell.x <= 8 and cell.y >= 3 and cell.y <= 6:
   return false
 return true
static func road_multiplier(road_kind: String) -> float:
 return float(ROAD_SPEED.get(road_kind,1.0))
static func valid_layout(extra: Dictionary, fields: Dictionary, roads: Dictionary) -> bool:
 for k in extra:
  var p: PackedStringArray = str(k).split(",")
  if p.size() != 2 or not within(Vector2i(int(p[0]),int(p[1]))):
   return false
 for k in fields:
  if roads.has(k):
   return false
  var p: PackedStringArray = str(k).split(",")
  if p.size() != 2 or not owned(Vector2i(int(p[0]),int(p[1])),extra):
   return false
 for k in roads:
  var p: PackedStringArray = str(k).split(",")
  if p.size() != 2 or not owned(Vector2i(int(p[0]),int(p[1])),extra) or not ROAD_PRICES.has(str(roads[k])):
   return false
 return true
