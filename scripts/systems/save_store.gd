extends RefCounted
## Versioned save validation. Keep game-state serialization independent of the UI.
const VERSION := 1
static func validate(data: Variant) -> bool:
 if not data is Dictionary:
  return false
 if data.get("version", -1) != VERSION:
  return false
 for key in ["cash", "grain", "stage", "day", "progress", "structures", "job"]:
  if not data.has(key):
   return false
 if not data["structures"] is Dictionary:
  return false
 if not data["job"] is String or not data["job"] in ["", "prepare", "sow", "harvest"]:
  return false
 for key in ["cash", "grain", "stage", "day"]:
  if not (data[key] is int or data[key] is float):
   return false
 if data["cash"] < 0 or data["grain"] < 0 or data["day"] < 1:
  return false
 if data["stage"] < 0 or data["stage"] > 2:
  return false
 if not (data["progress"] is int or data["progress"] is float):
  return false
 if data["progress"] < 0 or data["progress"] > 1:
  return false
 return true
static func read(path: String) -> Dictionary:
 if not FileAccess.file_exists(path):
  return {}
 var file := FileAccess.open(path, FileAccess.READ)
 if file == null:
  return {}
 var json := JSON.new()
 if json.parse(file.get_as_text()) != OK:
  return {}
 var parsed: Variant = json.data
 if not validate(parsed):
  return {}
 return parsed
static func write(path: String, data: Dictionary) -> bool:
 if not validate(data):
  return false
 var file := FileAccess.open(path, FileAccess.WRITE)
 if file == null:
  return false
 file.store_string(JSON.stringify(data))
 file.flush()
 return true
