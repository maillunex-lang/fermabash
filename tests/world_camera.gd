extends SceneTree
const StrategyCamera = preload("res://scripts/camera/strategy_camera.gd")
const FarmEnvironment = preload("res://scripts/visuals/farm_environment.gd")
func _initialize() -> void:
 call_deferred("_test")
func _test() -> void:
 var rig = StrategyCamera.new()
 var camera := Camera3D.new()
 root.add_child(camera)
 rig.apply(camera)
 assert(camera.position.length() > 10)
 rig.zoom = 999.0
 rig.focus = Vector3(100,0,-100)
 rig.apply(camera)
 assert(rig.zoom == 75.0)
 assert(rig.focus.x == 56.0)
 assert(rig.focus.z == -8.0)
 rig.zoom = -5.0
 rig.apply(camera)
 assert(rig.zoom == 12.0)
 var initial := rig.focus
 rig.pan(Vector2(80,40))
 rig.apply(camera)
 assert(rig.focus != initial)
 var wheel := InputEventMouseButton.new()
 wheel.button_index = MOUSE_BUTTON_WHEEL_UP
 wheel.pressed = true
 var old_zoom := rig.zoom
 assert(rig.mouse(wheel))
 assert(rig.zoom < old_zoom)
 var world := Node3D.new()
 root.add_child(world)
 FarmEnvironment.decorate(world,2)
 assert(world.get_child_count() > 5)
 var batches := 0
 for child in world.get_children():
  if child is MultiMeshInstance3D:
   batches += 1
 assert(batches >= 3)
 print("WORLD_CAMERA_TEST_PASS")
 quit()
