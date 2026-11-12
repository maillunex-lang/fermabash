extends Node3D
const CELL := 3.0
const SAVE := "user://farm.json"
const BuildRules = preload("res://scripts/systems/build_rules.gd")
const SaveStore = preload("res://scripts/systems/save_store.gd")
const GameClock = preload("res://scripts/systems/game_clock.gd")
const FarmEnvironment = preload("res://scripts/visuals/farm_environment.gd")
const StrategyCamera = preload("res://scripts/camera/strategy_camera.gd")
const GameUI = preload("res://scripts/ui/game_ui.gd")
var elapsed_seconds := 0.0
var cash := 2000
var grain := 0
var day := 1
var stage := 0
var job := ""
var progress := 0.0
var structures := {"2,2":true}
var build := false
var running := false
var world: Node3D
var cam: Camera3D
var hud: Label
var status: Label
var game_ui: CanvasLayer
var tractor: Node3D
var harvester: Node3D
var camera_rig = StrategyCamera.new()
var touch_start := Vector2.ZERO
var touch_moved := false
var touch_count := 0
func _ready() -> void:
 world = Node3D.new()
 add_child(world)
 var sun := DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-55,-30,0)
 sun.light_energy = 1.25
 sun.shadow_enabled = false
 add_child(sun)
 var ambience := WorldEnvironment.new()
 var env := Environment.new()
 env.background_mode = Environment.BG_COLOR
 env.background_color = Color("a6c9db")
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color("e1e8d5")
 env.ambient_light_energy = 0.8
 ambience.environment = env
 add_child(ambience)
 cam = Camera3D.new()
 add_child(cam)
 cam.current = true
 _camera()
 game_ui = GameUI.new()
 add_child(game_ui)
 hud = game_ui.stats
 status = game_ui.message
 game_ui.action_requested.connect(_ui_action)
 _draw()
 _menu()
func _ui_action(action: String) -> void:
 match action:
  "sow": _job("sow")
  "harvest": _job("harvest")
  "sell": _sell()
  "build": _start_build()
  "save": _save()
  "menu": _menu()
  "new": _new()
  "continue": _continue()
  "settings": status.text = "Звук выключен. Настройки появятся позже."
  "quit": get_tree().quit()
func _menu() -> void:
 running = false
 game_ui.show_menu()
func _continue() -> void:
 if FileAccess.file_exists(SAVE):
  _load()
  _close()
 else:
  _new()
func _close() -> void:
 game_ui.hide_menu()
 running = true
func _new() -> void:
 cash = 2000
 grain = 0
 day = 1
 elapsed_seconds = 0.0
 stage = 0
 job = ""
 progress = 0
 structures = {"2,2":true}
 _draw()
 _close()
func _cube(parent: Node3D,pos: Vector3,size: Vector3,color: Color) -> void:
 var mesh := MeshInstance3D.new()
 var m := BoxMesh.new()
 m.size = size
 mesh.mesh = m
 var mat := StandardMaterial3D.new()
 mat.albedo_color = color
 mesh.material_override = mat
 mesh.position = pos
 parent.add_child(mesh)
func _draw() -> void:
 for c in world.get_children():
  c.queue_free()
 for x in range(16):
  for z in range(16):
   var color := Color("7aa55d")
   if z == 7 or z == 8:
    color = Color("666e72")
   elif x >= 5 and x <= 8 and z >= 3 and z <= 6:
    color = Color("8d6841") if stage == 0 else (Color("65b548") if stage == 1 else Color("d4ae47"))
   _cube(world,Vector3((x+0.5)*CELL,-0.1,(z+0.5)*CELL),Vector3(2.94,0.2,2.94),color)
 FarmEnvironment.decorate(world,stage)
 for key in structures:
  var p: Array = key.split(",")
  var x := int(p[0])
  var z := int(p[1])
  _cube(world,Vector3((x+1)*CELL,1.2,(z+1)*CELL),Vector3(5.4,2.4,5.4),Color("d4d5c9"))
  _cube(world,Vector3((x+1)*CELL,2.7,(z+1)*CELL),Vector3(5.8,0.6,5.8),Color("406c7e"))
 tractor = Node3D.new()
 world.add_child(tractor)
 _cube(tractor,Vector3(0,0.8,0),Vector3(2.5,1.2,1.6),Color("d65b2d"))
 _cube(tractor,Vector3(-0.4,1.5,0),Vector3(1.1,0.8,1.3),Color("528b9a"))
 for x in [-0.9,0.9]:
  for z in [-0.8,0.8]:
   _cube(tractor,Vector3(x,0.25,z),Vector3(0.6,0.7,0.4),Color("24292c"))
 tractor.position = Vector3(5,0,23)
 harvester = Node3D.new()
 world.add_child(harvester)
 _cube(harvester,Vector3(0,1,0),Vector3(3,1.7,2.2),Color("d5a02e"))
 _cube(harvester,Vector3(1.9,0.5,0),Vector3(1.3,0.3,4),Color("30383a"))
 harvester.position = Vector3(11,0,23)
func _job(kind: String) -> void:
 if job != "":
  status.text = "Техника занята"
  return
 if kind == "sow":
  if stage != 0 or cash < 100:
   status.text = "Посев невозможен"
   return
  cash -= 100
 elif stage != 2:
  status.text = "Урожай ещё не созрел"
  return
 job = kind
 progress = 0.0
 status.text = "Техника отправлена"
func _start_build() -> void:
 build = true
 status.text = "Выберите свободную клетку"
func _sell() -> void:
 if grain == 0:
  status.text = "Склад пуст"
  return
 cash += grain*450
 grain = 0
 status.text = "Зерно продано"
func _process(delta: float) -> void:
 if not running:
  return
 elapsed_seconds += delta
 day = GameClock.day_from_seconds(elapsed_seconds)
 if job != "":
  progress += delta/6.0
  var machine := tractor if job == "sow" else harvester
  machine.position = Vector3(15+progress*10,0,12+progress*5)
  if progress >= 1.0:
   if job == "sow":
    stage = 1
    status.text = "Посев завершён"
   else:
    stage = 0
    grain += 3
    status.text = "Урожай на складе"
   job = ""
   progress = 0.0
   _draw()
 elif stage == 1:
  progress += delta/10.0
  if progress >= 1.0:
   stage = 2
   progress = 0.0
   status.text = "Пшеница созрела"
   _draw()
 game_ui.update_hud(day,cash,grain,stage,job,progress,build)
func _camera() -> void:
 camera_rig.apply(cam)
func _pick_cell(position: Vector2) -> void:
 var origin := cam.project_ray_origin(position)
 var dir := cam.project_ray_normal(position)
 if abs(dir.y) < 0.00001:
  return
 var p := origin+dir*(-origin.y/dir.y)
 var cell := Vector2i(floori(p.x/CELL),floori(p.z/CELL))
 if cell.x < 0 or cell.y < 0 or cell.x >= 16 or cell.y >= 16:
  return
 if build:
  _build(cell)
 else:
  status.text = "Клетка %d, %d" % [cell.x,cell.y]
func _unhandled_input(e: InputEvent) -> void:
 if not running:
  return
 if e is InputEventScreenTouch:
  if e.pressed:
   touch_count += 1
   touch_start = e.position
   touch_moved = false
  else:
   touch_count = maxi(0,touch_count-1)
   if not touch_moved and touch_count == 0:
    _pick_cell(e.position)
  camera_rig.touch(e)
 elif e is InputEventScreenDrag:
  if e.position.distance_to(touch_start) > 14:
   touch_moved = true
  camera_rig.touch(e)
 elif e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
  _pick_cell(e.position)
 else:
  camera_rig.mouse(e)
 _camera()
func _build(cell: Vector2i) -> void:
 if cash < 900:
  status.text = "Недостаточно денег"
  return
 if not BuildRules.can_place(cell, structures):
  status.text = "Недоступная или занятая клетка"
  return
 cash -= 900
 structures["%d,%d" % [cell.x,cell.y]] = true
 build = false
 _draw()
 status.text = "Склад построен!"
func _snapshot() -> Dictionary:
 return {"version":1,"cash":cash,"grain":grain,"stage":stage,"structures":structures.duplicate(),"job":job,"progress":progress,"day":day,"elapsed_seconds":elapsed_seconds}
func _save() -> void:
 if SaveStore.write(SAVE, _snapshot()):
  status.text = "Сохранено"
 else:
  status.text = "Ошибка сохранения"
func _load() -> void:
 var data: Dictionary = SaveStore.read(SAVE)
 if data.is_empty():
  status.text = "Сохранение отсутствует или повреждено"
  return
 cash = int(data["cash"])
 grain = int(data["grain"])
 stage = int(data["stage"])
 structures = data["structures"].duplicate()
 job = str(data["job"])
 progress = float(data["progress"])
 day = int(data["day"])
 elapsed_seconds = float(data.get("elapsed_seconds", (day-1) * GameClock.SECONDS_PER_YEAR / 365.0))
 _draw()
