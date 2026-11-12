extends RefCounted
## Pure placement rules. The client and a future authoritative server can share these constraints.
const GRID_SIZE := 16
const BUILDING_SIZE := 2
const BUILDING_COST := 900

static func can_place(cell: Vector2i, structures: Dictionary) -> bool:
 for x in range(cell.x, cell.x + BUILDING_SIZE):
  for z in range(cell.y, cell.y + BUILDING_SIZE):
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
    if x >= bx and x < bx + BUILDING_SIZE and z >= bz and z < bz + BUILDING_SIZE:
     return false
 return true
