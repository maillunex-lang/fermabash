extends RefCounted
## First region-navigation prototype. These are labels, not verified cadastral geometry.
const REPUBLIC := "Республика Башкортостан"
const DISTRICTS := [
 {"id":"ufa","name":"Уфимский район","settlements":[{"id":"mikhailovka","name":"Михайловка"}]},
 {"id":"sterlitamak","name":"Стерлитамакский район","settlements":[{"id":"naumovka","name":"Наумовка"}]},
 {"id":"birsk","name":"Бирский район","settlements":[{"id":"birsk_city","name":"Бирск"}]}
]
static func district(id: String) -> Dictionary:
 for item in DISTRICTS:
  if item["id"] == id:
   return item
 return {}
static func settlement(district_id: String, settlement_id: String) -> Dictionary:
 var item := district(district_id)
 for place in item.get("settlements",[]):
  if place["id"] == settlement_id:
   return place
 return {}
static func label(district_id: String, settlement_id: String) -> String:
 var d := district(district_id)
 var p := settlement(district_id,settlement_id)
 if d.is_empty() or p.is_empty():
  return REPUBLIC
 return "%s · %s" % [d["name"],p["name"]]
