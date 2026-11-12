extends SceneTree
const Rules = preload("res://scripts/systems/production_rules.gd")
func _initialize() -> void:
 call_deferred("_test")
func _test() -> void:
 assert(Rules.capacity({"2,2":true}) == 6)
 assert(Rules.capacity({"2,2":true,"10,10":"warehouse"}) == 12)
 assert(Rules.capacity({"10,10":"shed"}) == 0)
 assert(not Rules.can_sow(0,false,"",200))
 assert(Rules.can_prepare(0,false,"",60))
 assert(not Rules.can_prepare(0,false,"",59))
 assert(Rules.can_sow(0,true,"",100))
 assert(not Rules.can_sow(0,true,"prepare",100))
 assert(not Rules.can_harvest(2,"",4,{"2,2":true}))
 assert(Rules.can_harvest(2,"",3,{"2,2":true}))
 assert(Rules.sale_value(3) == 1350)
 assert(Rules.sale_value(-1) == 0)
 var scene = load("res://scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene._new()
 scene._job("sow")
 assert(scene.job == "")
 assert(scene.cash == 2000)
 scene._job("prepare")
 for i in range(65):
  scene._process(0.1)
 assert(scene.prepared)
 scene._save()
 scene.prepared = false
 scene._load()
 assert(scene.prepared)
 scene._job("sow")
 for i in range(65):
  scene._process(0.1)
 assert(scene.stage == 1)
 assert(not scene.prepared)
 print("PRODUCTION_TEST_PASS")
 quit()
