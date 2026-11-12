extends RefCounted
## Deterministic grid placement rules, independent of UI and rendering.
const GRID_SIZE := 16
const BUILDING_SIZE := 2
const BUILDING_COST := 900
const CATALOG := {
 "shed": {"title":"Навес","size":1,"cost":250,"color":"9d8564"},
 "warehouse": {"title":"Склад","size":2,"cost":900,"color":"406c7e"},
 "workshop": {"title":"Мастерская","size":3,"cost":1600,"color":"b16f45"},
 "complex": {"title":"Агрокомплекс","size":4,"cost":3000,"color":"648e62"}
}

static func definition(kind: String) -> Dictionary:
 return CATALOG.get(kind,{})

static func kind_of(value: Variant) -> String:
 # Stage 1 and 2.2 saves store true for an existing 2x2 warehouse.
 if value is String and CATALOG.has(value):
  return value
 return "warehouse"

static func size_of(value: Variant) -> int:
 return int(definition(kind_of(value)).get("size",BUILDING_SIZE))

static func can_place(cell: Vector2i, structures: Dictionary, kind: String = "warehouse") -> bool:
 if not CATALOG.has(kind):
  return false
 var footprint := int(CATALOG[kind]["size"])
 for x in range(cell.x,cell.x+footprint):
  for z in range(cell.y,cell.y+footprint):
   if x < 0 or z < 0 or x >= GRID_SIZE or z >= GRID_SIZE:
    return false
   if z == 7 or z == 8:
    return false
   if x >= 5 and x <= 8 and z >= 3 and z <= 6:
    return false
   for key in structures.keys():
    var parts: PackedStringArray = str(key).split(",")
    if parts.size() != 2:
     return false
    var bx := int(parts[0])
    var bz := int(parts[1])
    var existing_size := size_of(structures[key])
    if x >= bx and x < bx+existing_size and z >= bz and z < bz+existing_size:
     return false
 return true

static func price(kind: String) -> int:
 return int(definition(kind).get("cost",0))
