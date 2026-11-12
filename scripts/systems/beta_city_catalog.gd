extends RefCounted
## Beta whitelist: eight city centers. Coordinates are approximate reference points,
## not cadastral geometry or settlement boundaries.
const MAX_BETA_CITIES := 10
const CITIES := [
 {"id":"ufa","name":"Уфа","lat":54.7388,"lon":55.9721},
 {"id":"sterlitamak","name":"Стерлитамак","lat":53.6304,"lon":55.9308},
 {"id":"salavat","name":"Салават","lat":53.3617,"lon":55.9246},
 {"id":"ishimbay","name":"Ишимбай","lat":53.4546,"lon":56.0439},
 {"id":"neftekamsk","name":"Нефтекамск","lat":56.0884,"lon":54.2482},
 {"id":"oktyabrsky","name":"Октябрьский","lat":54.4815,"lon":53.4710},
 {"id":"birsk","name":"Бирск","lat":55.4178,"lon":55.5307},
 {"id":"beloretsk","name":"Белорецк","lat":53.9676,"lon":58.4091}
]
const MIN_LAT := 52.8
const MAX_LAT := 56.6
const MIN_LON := 52.8
const MAX_LON := 59.0
static func city(id: String) -> Dictionary:
 for entry in CITIES:
  if entry["id"] == id:
   return entry
 return {}
static func normalized(city_data: Dictionary) -> Vector2:
 if city_data.is_empty():
  return Vector2(-1,-1)
 return Vector2(
  clampf((float(city_data["lon"])-MIN_LON)/(MAX_LON-MIN_LON),0.0,1.0),
  clampf((MAX_LAT-float(city_data["lat"]))/(MAX_LAT-MIN_LAT),0.0,1.0)
 )
static func valid() -> bool:
 if CITIES.size() > MAX_BETA_CITIES:
  return false
 var seen := {}
 for entry in CITIES:
  if seen.has(entry["id"]):
   return false
  seen[entry["id"]] = true
  if normalized(entry) == Vector2(-1,-1):
   return false
 return true
