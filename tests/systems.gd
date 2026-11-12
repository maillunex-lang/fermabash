extends SceneTree
const BuildRules = preload("res://scripts/systems/build_rules.gd")
const SaveStore = preload("res://scripts/systems/save_store.gd")
const GameClock = preload("res://scripts/systems/game_clock.gd")
func _initialize() -> void:
 call_deferred("_test")
func _test() -> void:
 var structures := {"2,2":true}
 assert(BuildRules.can_place(Vector2i(10,10),structures))
 assert(not BuildRules.can_place(Vector2i(2,2),structures))
 assert(not BuildRules.can_place(Vector2i(3,3),structures))
 assert(not BuildRules.can_place(Vector2i(-1,0),structures))
 assert(not BuildRules.can_place(Vector2i(15,15),structures))
 assert(not BuildRules.can_place(Vector2i(5,3),structures))
 assert(not BuildRules.can_place(Vector2i(1,7),structures))
 assert(GameClock.day_from_seconds(0) == 1)
 assert(GameClock.year_from_seconds(0) == 1)
 assert(GameClock.year_from_seconds(GameClock.SECONDS_PER_YEAR) == 2)
 var state := {"version":1,"cash":100,"grain":0,"stage":0,"day":1,"progress":0.0,"job":"","structures":structures}
 assert(SaveStore.validate(state))
 assert(not SaveStore.validate({"version":999}))
 var broken := state.duplicate(true)
 broken["cash"] = -1
 assert(not SaveStore.validate(broken))
 broken = state.duplicate(true)
 broken["structures"] = []
 assert(not SaveStore.validate(broken))
 var path := "user://test_save_systems.json"
 assert(SaveStore.write(path,state))
 var loaded := SaveStore.read(path)
 assert(loaded["cash"] == 100)
 assert(loaded["structures"].has("2,2"))
 var file := FileAccess.open(path,FileAccess.WRITE)
 file.store_string("{invalid")
 file.close()
 assert(SaveStore.read(path).is_empty())
 DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
 print("SYSTEM_TEST_PASS")
 quit()
