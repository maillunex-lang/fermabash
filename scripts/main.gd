extends Node3D
const CELL := 3.0
const SAVE := "user://farm.json"
const Territory = preload("res://scripts/systems/territory_rules.gd")
const BuildRules = preload("res://scripts/systems/build_rules.gd")
const SaveStore = preload("res://scripts/systems/save_store.gd")
const GameClock = preload("res://scripts/systems/game_clock.gd")
const FarmEnvironment = preload("res://scripts/visuals/farm_environment.gd")
const StrategyCamera = preload("res://scripts/camera/strategy_camera.gd")
const GameUI = preload("res://scripts/ui/game_ui.gd")
const BetaCityCatalog = preload("res://scripts/systems/beta_city_catalog.gd")
const ProductionRules = preload("res://scripts/systems/production_rules.gd")
const FieldRoute = preload("res://scripts/systems/field_route.gd")
const LivingField = preload("res://scripts/visuals/living_field.gd")
var elapsed_seconds := 0.0
var cash := 2000
var grain := 0
var day := 1
var stage := 0
var prepared := false
var job := ""
var progress := 0.0
var structures := {"2,2":true}
var build := false
var build_kind := "warehouse"
var territory_mode := ""
var extra_land: Dictionary = {}
var field_plots: Dictionary = {}
var roads: Dictionary = {}
var road_kind := "gravel"
var road_vehicle_progress := 0.0
var preview_cell := Vector2i(-1,-1)
var preview: MeshInstance3D
var running := false
var living_field: Node3D
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
var gesture_multitouch := false
func _ready() -> void:
 world = Node3D.new()
 add_child(world)
 living_field = LivingField.new()
 add_child(living_field)
 preview = MeshInstance3D.new()
 add_child(preview)
 preview.visible = false
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
 if action.begins_with("region_city:"):
  var city: Dictionary = BetaCityCatalog.city(action.trim_prefix("region_city:"))
  if not city.is_empty():
   status.text = "Выбран город: " + str(city["name"])
  return
 if action.begins_with("region_district:"):
  game_ui.show_district(action.trim_prefix("region_district:"))
  return
 if action.begins_with("region_settlement:"):
  var parts := action.split(":")
  if parts.size() == 3:
   game_ui.show_settlement(parts[1],parts[2])
  return
 match action:
  "region_map": game_ui.show_regions()
  "region_close": game_ui.hide_regions()
  "region_back": game_ui.show_regions()
  "region_district_list": game_ui._populate_regions()
  "tab_field": game_ui.show_tab("field")
  "tab_construction": game_ui.show_tab("construction")
  "prepare": _job("prepare")
  "sow": _job("sow")
  "harvest": _job("harvest")
  "sell": _sell()
  "build": _start_build()
  "build_shed": _start_build("shed")
  "build_workshop": _start_build("workshop")
  "build_complex": _start_build("complex")
  "cancel_build": _cancel_build()
  "buy_land": _start_territory("land")
  "place_field": _start_territory("field")
  "road_dirt": _start_territory("road_dirt")
  "road_gravel": _start_territory("road_gravel")
  "road_asphalt": _start_territory("road_asphalt")
  "save": _save()
  "menu": _menu()
  "new": _new()
  "continue": _continue()
  "settings": status.text = "Звук выключен. Настройки появятся позже."
  "quit": get_tree().quit()
func _menu() -> void:
 running = false
 game_ui.hide_regions()
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
 prepared = false
 job = ""
 progress = 0
 structures = {"2,2":true}
 extra_land.clear()
 field_plots.clear()
 roads.clear()
 road_vehicle_progress = 0.0
 _cancel_build()
 game_ui.show_tab("field")
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
 for x in range(Territory.MAX_SIZE):
  for z in range(Territory.MAX_SIZE):
   var cell := Vector2i(x,z)
   if not Territory.owned(cell,extra_land):
    continue
   var color := Color("7aa55d")
   if roads.has(Territory.key(cell)):
    color = {"dirt":Color("8c7252"),"gravel":Color("a4a6a0"),"asphalt":Color("424a4d")}[roads[Territory.key(cell)]]
   elif field_plots.has(Territory.key(cell)):
    color = Color("72512f")
   elif z == 7 or z == 8:
    color = Color("666e72")
   elif x >= 5 and x <= 8 and z >= 3 and z <= 6:
    color = Color("8d6841") if stage == 0 else (Color("65b548") if stage == 1 else Color("d4ae47"))
   _cube(world,Vector3((x+0.5)*CELL,-0.1,(z+0.5)*CELL),Vector3(2.94,0.2,2.94),color)
 FarmEnvironment.decorate(world,0)
 for key in structures:
  var p: Array = key.split(",")
  var x := int(p[0])
  var z := int(p[1])
  var kind: String = BuildRules.kind_of(structures[key])
  var size: int = BuildRules.size_of(structures[key])
  var width := float(size)*CELL
  var center := Vector3((x+float(size)*0.5)*CELL,1.2,(z+float(size)*0.5)*CELL)
  _cube(world,center,Vector3(width-0.6,2.4,width-0.6),Color("d4d5c9"))
  _cube(world,center+Vector3(0,1.5,0),Vector3(width-0.2,0.6,width-0.2),Color.html(str(BuildRules.definition(kind)["color"])))
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
 _update_field_visuals()
 _update_machine_position()
func _update_field_visuals() -> void:
 living_field.update_field(stage,prepared,job,progress)
func _update_machine_position() -> void:
 if job == "":
  return
 var machine := harvester if job == "harvest" else tractor
 machine.position = FieldRoute.position_at(progress)
 machine.rotation.y = FieldRoute.heading_at(progress)
func _job(kind: String) -> void:
 if job != "":
  status.text = "Техника занята"
  return
 match kind:
  "prepare":
   if not ProductionRules.can_prepare(stage,prepared,job,cash):
    status.text = "Подготовка поля недоступна"
    return
   cash -= ProductionRules.PREPARE_COST
  "sow":
   if not ProductionRules.can_sow(stage,prepared,job,cash):
    status.text = "Сначала подготовьте поле"
    return
   cash -= ProductionRules.SOW_COST
  "harvest":
   if not ProductionRules.can_harvest(stage,job,grain,structures):
    status.text = "Урожай не созрел или склад заполнен"
    return
  _:
   return
 job = kind
 progress = 0.0
 _update_field_visuals()
 _update_machine_position()
 status.text = "Техника отправлена: %s" % kind
func _start_build(kind: String = "warehouse") -> void:
 territory_mode = ""
 if not BuildRules.CATALOG.has(kind):
  return
 build_kind = kind
 build = true
 preview_cell = Vector2i(-1,-1)
 preview.visible = false
 var item: Dictionary = BuildRules.definition(kind)
 status.text = "%s %d×%d: %d ₽. Выберите клетку" % [item["title"],item["size"],item["size"],item["cost"]]
func _cancel_build() -> void:
 build = false
 territory_mode = ""
 preview_cell = Vector2i(-1,-1)
 if preview != null:
  preview.visible = false
func _update_preview(position: Vector2) -> void:
 if not build:
  return
 var cell := _screen_cell(position)
 preview_cell = cell
 if cell.x < 0:
  preview.visible = false
  return
 var size: int = int(BuildRules.definition(build_kind)["size"])
 var valid := BuildRules.can_place(cell,structures,build_kind) and _footprint_clear(cell,build_kind) and cash >= BuildRules.price(build_kind)
 var mesh := BoxMesh.new()
 mesh.size = Vector3(float(size)*CELL,0.12,float(size)*CELL)
 preview.mesh = mesh
 preview.position = Vector3((float(cell.x)+float(size)*0.5)*CELL,0.18,(float(cell.y)+float(size)*0.5)*CELL)
 var material := StandardMaterial3D.new()
 material.albedo_color = Color(0.2,0.9,0.35,0.6) if valid else Color(0.95,0.22,0.2,0.6)
 material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
 material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 preview.material_override = material
 preview.visible = true
func _start_territory(kind: String) -> void:
 _cancel_build()
 territory_mode = kind
 if kind.begins_with("road_"):
  road_kind = kind.trim_prefix("road_")
 var price := Territory.LAND_PRICE if kind == "land" else (Territory.FIELD_PRICE if kind == "field" else int(Territory.ROAD_PRICES.get(road_kind,0)))
 status.text = "Режим %s: %d ₽ за клетку. Нажмите на участок" % [kind,price]

func _develop(cell: Vector2i) -> bool:
 var k := Territory.key(cell)
 if territory_mode == "land":
  if not Territory.can_buy(cell,extra_land) or cash < Territory.LAND_PRICE:
   status.text = "Участок недоступен или не хватает денег"
   return false
  cash -= Territory.LAND_PRICE
  extra_land[k] = true
 elif territory_mode == "field":
  if not Territory.can_develop(cell,extra_land,structures,field_plots,roads) or cash < Territory.FIELD_PRICE:
   status.text = "Нельзя разместить поле"
   return false
  cash -= Territory.FIELD_PRICE
  field_plots[k] = true
 elif territory_mode.begins_with("road_"):
  var price: int = int(Territory.ROAD_PRICES[road_kind])
  if not Territory.can_develop(cell,extra_land,structures,field_plots,roads) or cash < price:
   status.text = "Нельзя проложить дорогу"
   return false
  cash -= price
  roads[k] = road_kind
 else:
  return false
 status.text = "Участок %d, %d готов" % [cell.x,cell.y]
 _draw()
 return true

func _road_speed_at(cell: Vector2i) -> float:
 return Territory.road_multiplier(str(roads.get(Territory.key(cell),"")))

func _sell() -> void:
 if grain == 0:
  status.text = "Склад пуст"
  return
 cash += ProductionRules.sale_value(grain)
 grain = 0
 status.text = "Зерно продано"
func _road_patrol(delta: float) -> void:
 if job != "" or tractor == null or roads.size() < 2:
  return
 var keys: Array = roads.keys()
 keys.sort()
 var points: Array[Vector2i] = []
 for key in keys:
  var parts: PackedStringArray = str(key).split(",")
  points.append(Vector2i(int(parts[0]),int(parts[1])))
 var links: Array[Vector2i] = []
 for cell in points:
  for direction in [Vector2i(1,0),Vector2i(0,1)]:
   if roads.has(Territory.key(cell+direction)):
    links.append(cell)
    links.append(cell+direction)
 if links.is_empty():
  return
 var segment: int = int(floor(road_vehicle_progress)) % int(links.size()/2)
 var from: Vector2i = links[segment*2]
 var to: Vector2i = links[segment*2+1]
 var speed: float = _road_speed_at(from)
 road_vehicle_progress = fposmod(road_vehicle_progress+delta*speed*0.45,float(links.size()/2))
 var fraction := road_vehicle_progress-floor(road_vehicle_progress)
 tractor.position = Vector3((lerpf(float(from.x),float(to.x),fraction)+0.5)*CELL,0,(lerpf(float(from.y),float(to.y),fraction)+0.5)*CELL)
 tractor.rotation.y = atan2(float(to.x-from.x),float(to.y-from.y))

func _process(delta: float) -> void:
 if not running:
  return
 elapsed_seconds += delta
 _road_patrol(delta)
 day = GameClock.day_from_seconds(elapsed_seconds)
 if job != "":
  progress += delta/6.0
  progress = minf(progress,1.0)
  _update_machine_position()
  _update_field_visuals()
  if progress >= 1.0:
   if job == "prepare":
    prepared = true
    status.text = "Почва подготовлена"
   elif job == "sow":
    prepared = false
    stage = 1
    status.text = "Посев завершён"
   else:
    stage = 0
    prepared = false
    grain += ProductionRules.YIELD_TONS
    status.text = "Урожай на складе"
   job = ""
   progress = 0.0
   _draw()
 elif stage == 1:
  progress += delta/10.0
  _update_field_visuals()
  if progress >= 1.0:
   stage = 2
   progress = 0.0
   status.text = "Пшеница созрела"
   _draw()
 game_ui.update_hud(day,cash,grain,stage,job,progress,build,prepared,ProductionRules.capacity(structures))
func _camera() -> void:
 camera_rig.apply(cam)
func _screen_cell(position: Vector2) -> Vector2i:
 var origin := cam.project_ray_origin(position)
 var dir := cam.project_ray_normal(position)
 if abs(dir.y) < 0.00001:
  return Vector2i(-1,-1)
 var p := origin+dir*(-origin.y/dir.y)
 var cell := Vector2i(floori(p.x/CELL),floori(p.z/CELL))
 if not Territory.within(cell):
  return Vector2i(-1,-1)
 return cell
func _pick_cell(position: Vector2) -> void:
 var cell := _screen_cell(position)
 if cell.x < 0:
  return
 if build:
  _build(cell)
 elif territory_mode != "":
  _develop(cell)
 else:
  status.text = "Клетка %d, %d" % [cell.x,cell.y]
func _unhandled_input(e: InputEvent) -> void:
 if not running:
  return
 if e is InputEventScreenTouch:
  if e.pressed:
   touch_count += 1
   if touch_count == 1:
    touch_start = e.position
    touch_moved = false
    gesture_multitouch = false
   else:
    gesture_multitouch = true
    touch_moved = true
  else:
   touch_count = maxi(0,touch_count-1)
   if not touch_moved and not gesture_multitouch and touch_count == 0:
    _pick_cell(e.position)
  camera_rig.touch(e)
 elif e is InputEventScreenDrag:
  if touch_count > 1 or e.position.distance_to(touch_start) > 14:
   touch_moved = true
  camera_rig.touch(e)
  if build:
   _update_preview(e.position)
 elif e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.pressed and not Input.is_emulating_mouse_from_touch():
  _pick_cell(e.position)
 elif e is InputEventMouseMotion:
  camera_rig.mouse(e)
  _update_preview(e.position)
 elif e is InputEventKey and e.pressed and e.keycode == KEY_ESCAPE and (build or territory_mode != ""):
  _cancel_build()
  status.text = "Строительство отменено"
 else:
  camera_rig.mouse(e)
 _camera()
func _footprint_clear(cell: Vector2i, kind: String) -> bool:
 var size: int = BuildRules.size_of(kind)
 for x in range(cell.x,cell.x+size):
  for z in range(cell.y,cell.y+size):
   var c := Vector2i(x,z)
   if not Territory.owned(c,extra_land) or field_plots.has(Territory.key(c)) or roads.has(Territory.key(c)):
    return false
 return true

func _build(cell: Vector2i) -> void:
 var price: int = BuildRules.price(build_kind)
 if cash < price:
  status.text = "Недостаточно денег"
  return
 if not BuildRules.can_place(cell,structures,build_kind) or not _footprint_clear(cell,build_kind):
  status.text = "Недоступная или занятая клетка"
  return
 cash -= price
 structures["%d,%d" % [cell.x,cell.y]] = build_kind
 _cancel_build()
 _draw()
 status.text = "Постройка завершена!"
func _snapshot() -> Dictionary:
 return {"version":1,"cash":cash,"grain":grain,"stage":stage,"prepared":prepared,"structures":structures.duplicate(),"job":job,"progress":progress,"day":day,"elapsed_seconds":elapsed_seconds,"extra_land":extra_land.duplicate(),"field_plots":field_plots.duplicate(),"roads":roads.duplicate()}
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
 prepared = bool(data.get("prepared",false))
 structures = data["structures"].duplicate()
 extra_land = data.get("extra_land",{}).duplicate()
 field_plots = data.get("field_plots",{}).duplicate()
 roads = data.get("roads",{}).duplicate()
 if not Territory.valid_layout(extra_land,field_plots,roads):
  extra_land.clear()
  field_plots.clear()
  roads.clear()
 _cancel_build()
 job = str(data["job"])
 progress = float(data["progress"])
 day = int(data["day"])
 elapsed_seconds = float(data.get("elapsed_seconds", (day-1) * GameClock.SECONDS_PER_YEAR / 365.0))
 _draw()
