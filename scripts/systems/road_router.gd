extends RefCounted
const Territory = preload("res://scripts/systems/territory_rules.gd")
const DIRECTIONS := [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]
## A* pathfinding on owned land. Existing roads reduce travel cost.
static func find_route(start: Vector2i, target: Vector2i, extra: Dictionary, roads: Dictionary, blocked: Dictionary = {}) -> Array[Vector2i]:
 var empty: Array[Vector2i] = []
 if not Territory.owned(start,extra) or not Territory.owned(target,extra):
  return empty
 var frontier: Array[Vector2i] = [start]
 var distance: Dictionary = {Territory.key(start):0.0}
 var previous: Dictionary = {}
 while not frontier.is_empty():
  var best := 0
  for i in range(1,frontier.size()):
   if float(distance[Territory.key(frontier[i])]) < float(distance[Territory.key(frontier[best])]):
    best = i
  var current: Vector2i = frontier[best]
  frontier.remove_at(best)
  if current == target:
   var route: Array[Vector2i] = [current]
   while current != start:
    current = previous[Territory.key(current)]
    route.push_front(current)
   return route
  for direction in DIRECTIONS:
   var next: Vector2i = current+direction
   if not Territory.owned(next,extra) or (blocked.has(Territory.key(next)) and next != target):
    continue
   var road: String = str(roads.get(Territory.key(next),""))
   var cost: float = 1.0/Territory.road_multiplier(road)
   var score: float = float(distance[Territory.key(current)])+cost
   var key := Territory.key(next)
   if not distance.has(key) or score < float(distance[key]):
    distance[key] = score
    previous[key] = current
    if not frontier.has(next):
     frontier.append(next)
 return empty
static func travel_time(route: Array[Vector2i], roads: Dictionary) -> float:
 var total := 0.0
 for i in range(1,route.size()):
  total += 1.0/Territory.road_multiplier(str(roads.get(Territory.key(route[i]),"")))
 return total
