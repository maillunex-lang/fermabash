extends SceneTree
func _initialize() -> void:
 call_deferred("_test")
func _test() -> void:
 var scene = load("res://scenes/Main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene._new()
 var ui = scene.game_ui
 assert(ui.active_tab == "field")
 assert(ui.action_buttons["prepare"].visible)
 assert(not ui.action_buttons["build"].visible)
 scene._ui_action("tab_construction")
 assert(ui.action_buttons["build"].visible)
 assert(not ui.action_buttons["prepare"].visible)
 scene._ui_action("build_shed")
 assert(scene.build)
 assert(ui.main_root.mouse_filter == Control.MOUSE_FILTER_IGNORE)
 assert(ui.actions_panel.mouse_filter == Control.MOUSE_FILTER_STOP)
 var a := InputEventScreenTouch.new()
 a.index = 0
 a.pressed = true
 a.position = Vector2(300,200)
 scene._unhandled_input(a)
 var b := InputEventScreenTouch.new()
 b.index = 1
 b.pressed = true
 b.position = Vector2(400,200)
 scene._unhandled_input(b)
 assert(scene.gesture_multitouch)
 var drag := InputEventScreenDrag.new()
 drag.index = 1
 drag.position = Vector2(455,240)
 drag.relative = Vector2(55,40)
 var old_angle: float = scene.camera_rig.angle
 var old_zoom: float = scene.camera_rig.zoom
 scene._unhandled_input(drag)
 assert(not is_equal_approx(scene.camera_rig.angle,old_angle))
 assert(not is_equal_approx(scene.camera_rig.zoom,old_zoom))
 b.pressed = false
 scene._unhandled_input(b)
 a.pressed = false
 scene._unhandled_input(a)
 assert(scene.build)
 scene._ui_action("cancel_build")
 assert(not scene.build)
 scene._ui_action("tab_field")
 assert(ui.active_tab == "field")
 print("ANDROID_CONTROLS_TEST_PASS")
 quit()
