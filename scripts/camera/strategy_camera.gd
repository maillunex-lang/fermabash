extends RefCounted
## Camera interaction state independent from gameplay and construction rules.
var angle := 0.75
var zoom := 35.0
var focus := Vector3(24,0,24)
var tilt := 0.8
var drag_active := false
var last_mouse := Vector2.ZERO
var touches: Dictionary = {}
var gesture_distance := 0.0
var gesture_angle := 0.0
var gesture_center := Vector2.ZERO

func apply(camera: Camera3D) -> void:
 focus.x = clampf(focus.x,-8.0,80.0)
 focus.z = clampf(focus.z,-8.0,80.0)
 zoom = clampf(zoom,12.0,75.0)
 camera.position = focus + Vector3(sin(angle)*zoom,zoom*tilt,cos(angle)*zoom)
 camera.look_at(focus)

func pan(delta: Vector2) -> void:
 var right := Vector3(cos(angle),0,-sin(angle))
 var forward := Vector3(-sin(angle),0,-cos(angle))
 focus += right * (-delta.x*zoom/700.0) + forward * (delta.y*zoom/700.0)

func mouse(event: InputEvent) -> bool:
 if event is InputEventMouseButton:
  if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
   zoom -= 3
   return true
  if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
   zoom += 3
   return true
  if event.button_index == MOUSE_BUTTON_RIGHT:
   drag_active = event.pressed
   last_mouse = event.position
   return true
 if event is InputEventMouseMotion and drag_active:
  pan(event.position-last_mouse)
  last_mouse = event.position
  return true
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode == KEY_Q:
   angle -= 0.18
   return true
  if event.keycode == KEY_E:
   angle += 0.18
   return true
 return false

func touch(event: InputEvent) -> bool:
 if event is InputEventScreenTouch:
  if event.pressed:
   touches[event.index] = event.position
  else:
   touches.erase(event.index)
  _reset_gesture()
  return true
 if event is InputEventScreenDrag:
  var previous: Vector2 = touches.get(event.index,event.position-event.relative)
  touches[event.index] = event.position
  if touches.size() == 1:
   pan(event.position-previous)
  elif touches.size() >= 2:
   var pts := touches.values()
   var a: Vector2 = pts[0]
   var b: Vector2 = pts[1]
   var distance := a.distance_to(b)
   var rotation := (b-a).angle()
   var center := (a+b)*0.5
   if gesture_distance > 0.001:
    zoom *= gesture_distance/maxf(distance,1.0)
    angle += wrapf(rotation-gesture_angle,-PI,PI)
    pan(center-gesture_center)
   gesture_distance = distance
   gesture_angle = rotation
   gesture_center = center
  return true
 return false

func _reset_gesture() -> void:
 gesture_distance = 0.0
 if touches.size() >= 2:
  var pts := touches.values()
  var a: Vector2 = pts[0]
  var b: Vector2 = pts[1]
  gesture_distance = a.distance_to(b)
  gesture_angle = (b-a).angle()
  gesture_center = (a+b)*0.5
