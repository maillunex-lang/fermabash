extends RefCounted
## Local onboarding prototype only. No user accounts or shared server registry yet.
const DISTRICTS := [
 {"id":"ufimsky","name":"Уфимский район"},
 {"id":"sterlitamaksky","name":"Стерлитамакский район"}
]
const GRID := 12
const START_PLOT := 2
static func district(id: String) -> Dictionary:
 for item in DISTRICTS:
  if item["id"] == id:
   return item
 return {}
static func valid_name(value: String) -> bool:
 var trimmed := value.strip_edges()
 return trimmed.length() >= 3 and trimmed.length() <= 40 and not trimmed.contains("\n") and not trimmed.contains("\r")
static func plot_free(origin: Vector2i, occupied: Array) -> bool:
 if origin.x < 0 or origin.y < 0 or origin.x + START_PLOT > GRID or origin.y + START_PLOT > GRID:
  return false
 for other in occupied:
  if abs(origin.x - other.x) < START_PLOT and abs(origin.y - other.y) < START_PLOT:
   return false
 return true
static func create(name: String, district_id: String, origin: Vector2i, occupied: Array = []) -> Dictionary:
 if not valid_name(name) or district(district_id).is_empty() or not plot_free(origin,occupied):
  return {}
 return {"name":name.strip_edges(),"district_id":district_id,"plot_x":origin.x,"plot_y":origin.y}
static func validate(data: Variant) -> bool:
 if not data is Dictionary:
  return false
 if not data.has("name") or not data.has("district_id") or not data.has("plot_x") or not data.has("plot_y"):
  return false
 if not data["name"] is String or not data["district_id"] is String:
  return false
 if not (data["plot_x"] is int or data["plot_x"] is float) or not (data["plot_y"] is int or data["plot_y"] is float):
  return false
 if float(data["plot_x"]) != float(int(data["plot_x"])) or float(data["plot_y"]) != float(int(data["plot_y"])):
  return false
 return not create(data["name"],data["district_id"],Vector2i(int(data["plot_x"]),int(data["plot_y"]))).is_empty()
