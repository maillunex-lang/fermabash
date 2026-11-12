extends SceneTree
func _initialize() -> void:
 call_deferred("_test")
func _test() -> void:
 var scene = load("res://scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene._new()
 assert(scene.cash == 2000)
 scene._job("sow")
 assert(scene.cash == 1900)
 scene._job("harvest")
 assert(scene.job == "sow")
 for i in range(400):
  scene._process(0.1)
 assert(scene.stage == 2)
 scene._job("harvest")
 for i in range(70):
  scene._process(0.1)
 assert(scene.grain == 3)
 scene._sell()
 assert(scene.cash == 3250)
 scene._build(Vector2i(2,2))
 assert(scene.cash == 3250)
 scene._build(Vector2i(10,10))
 assert(scene.cash == 2350)
 scene._save()
 scene.cash = 0
 scene._load()
 assert(scene.cash == 2350)
 print("SMOKE_TEST_PASS")
 quit()
