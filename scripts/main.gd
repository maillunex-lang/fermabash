extends Node3D
const CELL := 3.0
const SAVE := "user://farm.json"
const PlotProduction = preload("res://scripts/systems/plot_production.gd")
const RoadRouter = preload("res://scripts/systems/road_router.gd")
const Territory = preload("res://scripts/systems/territory_rules.gd")
const BuildRules = preload("res://scripts/systems/build_rules.gd")
const SaveStore = preload("res://scripts/systems/save_store.gd")
const GameClock = preload("res://scripts/systems/game_clock.gd")
const FarmEnvironment = preload("res://scripts/visuals/farm_environment.gd")
const StrategyCamera = preload("res://scripts/camera/strategy_camera.gd")
const GameUI = preload("res://scripts/ui/game_ui.gd")
const FarmRegistry = preload("res://scripts/systems/farm_registry.gd")
const FarmOnboarding = preload("res://scripts/ui/farm_onboarding.gd")
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
var selected_plot := ""
var pending_field_action := ""
var field_group_id := 0
var next_field_group_id := 1
var field_tasks: Array[Dictionary] = []
var active_plot := ""
var travel_route: Array[Vector2i] = []
var travel_index := 0
var travel_fraction := 0.0
var preview_cell := Vector2i(-1,-1)
var preview: MeshInstance3D
var running := false
var farm_profile: Dictionary = {}
var onboarding: CanvasLayer
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
 onboarding = FarmOnboarding.new()
 add_child(onboarding)
 onboarding.confirmed.connect(_farm_confirmed)
 onboarding.cancelled.connect(_farm_cancelled)
 onboarding.close()
 _draw()
 _menu()
func _ui_action(action: String) -> void:
 if action.begins_with("region_district:"):
  game_ui.show_district(action.trim_prefix("region_district:"),farm_profile)
  return
 match action:
  "region_map": game_ui.show_regions(farm_profile)
  "region_close": game_ui.hide_regions()
  "region_back": game_ui._populate_regions(farm_profile)
  "region_district_list": game_ui._populate_regions()
  "tab_field":
   _cancel_build()
   game_ui.show_tab("field")
  "tab_territory": game_ui.show_tab("territory")
  "tab_construction": game_ui.show_tab("construction")
  "prepare": _request_field_action("prepare")
  "sow": _request_field_action("sow")
  "harvest": _request_field_action("harvest")
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
  "new": _begin_new()
  "continue": _continue()
  "settings": status.text = "Звук выключен. Настройки появятся позже."
  "quit": get_tree().quit()
func _begin_new() -> void:
 game_ui.hide_menu()
 onboarding.open()

func _farm_confirmed(profile: Dictionary) -> void:
 farm_profile = profile.duplicate(true)
 onboarding.close()
 _new()
 _save()

func _farm_cancelled() -> void:
 onboarding.close()
 game_ui.show_menu()

func _menu() -> void:
 running = false
 game_ui.hide_regions()
 game_ui.show_menu()
func _continue() -> void:
 if FileAccess.file_exists(SAVE):
  _load()
  _close()
 else:
  _begin_new()
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
 selected_plot = ""
 pending_field_action = ""
 field_group_id = 0
 next_field_group_id = 1
 field_tasks.clear()
 active_plot = ""
 travel_route.clear()
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
    var plot: Dictionary = _plot_state(Territory.key(cell))
    if int(plot["stage"]) == 2:
     color = Color("d8af48")
    elif int(plot["stage"]) == 1:
     color = Color("63a548")
    elif bool(plot["prepared"]):
     color = Color("b48655")
    else:
     color = Color("72512f")
    if selected_plot != "" and _group_of(selected_plot) == _group_of(Territory.key(cell)):
     color = color.lightened(0.35)
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
 if job == "" or active_plot != "":
  return
 var machine := harvester if job == "harvest" else tractor
 machine.position = FieldRoute.position_at(progress)
 machine.rotation.y = FieldRoute.heading_at(progress)
func _job(kind: String) -> void:
 if selected_plot != "":
  _plot_job(kind)
  return
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
 pending_field_action = ""
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
 pending_field_action = ""
 territory_mode = kind
 if kind == "field":
  field_group_id = next_field_group_id
  next_field_group_id += 1
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
  var fresh: Dictionary = PlotProduction.initial()
  fresh["group"] = field_group_id
  field_plots[k] = fresh
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
 _save()
 return true

func _plot_state(key: String) -> Dictionary:
 var value: Variant = field_plots.get(key,PlotProduction.initial())
 if not PlotProduction.valid(value):
  return PlotProduction.initial()
 return {"stage":int(value["stage"]),"prepared":bool(value["prepared"]),"growth":float(value["growth"]),"group":int(value.get("group",0))}

func _group_of(key: String) -> int:
 return int(_plot_state(key).get("group",0))

func _group_cells(key: String) -> Array[String]:
 var result: Array[String] = []
 if not field_plots.has(key):
  return result
 var group: int = _group_of(key)
 for cell_key in field_plots:
  if (group > 0 and _group_of(str(cell_key)) == group) or (group == 0 and str(cell_key) == key):
   result.append(str(cell_key))
 result.sort()
 return result

func _request_field_action(action: String) -> void:
 if not action in ["prepare","sow","harvest"]:
  return
 pending_field_action = action
 territory_mode = ""
 build = false
 status.text = "Нажмите на нужное поле для задания: "+action

func _building_obstacles() -> Dictionary:
 var blocked: Dictionary = {}
 for key in structures:
  var p: PackedStringArray = str(key).split(",")
  if p.size() != 2:
   continue
  var origin := Vector2i(int(p[0]),int(p[1]))
  var size: int = BuildRules.size_of(structures[key])
  for x in range(origin.x,origin.x+size):
   for y in range(origin.y,origin.y+size):
    blocked[Territory.key(Vector2i(x,y))] = true
 return blocked

func _plot_job(kind: String) -> void:
 if not field_plots.has(selected_plot):
  selected_plot = ""
  return
 var cells: Array[String] = _group_cells(selected_plot)
 if active_plot != "" and _group_of(active_plot) == _group_of(selected_plot):
  status.text = "Это поле уже обрабатывается"
  return
 var state: Dictionary = _plot_state(selected_plot)
 var area: int = cells.size()
 var reserved: int = 0
 for task in field_tasks:
  if _group_of(str(task["key"])) == _group_of(selected_plot):
   status.text = "На этом поле уже назначено задание"
   return
  if str(task["action"]) == "harvest":
   reserved += int(task["area"])*PlotProduction.YIELD_TONS
 var available: int = ProductionRules.capacity(structures)-grain-reserved
 var cost: int = (PlotProduction.PREPARE_COST if kind == "prepare" else PlotProduction.SOW_COST if kind == "sow" else 0)*area
 if cash < cost or (kind == "harvest" and available < area*PlotProduction.YIELD_TONS) or not PlotProduction.allowed(state,kind,cash,maxi(0,available)) :
  status.text = "Операция на выбранном поле недоступна"
  return
 var parts: PackedStringArray = selected_plot.split(",")
 var target := Vector2i(int(parts[0]),int(parts[1]))
 var route: Array[Vector2i] = RoadRouter.find_route(Vector2i(0,8),target,extra_land,roads,_building_obstacles())
 if route.is_empty():
  status.text = "К полю нет доступного маршрута"
  return
 cash -= cost
 field_tasks.append({"key":selected_plot,"action":kind,"area":area})
 pending_field_action = ""
 status.text = "Задание назначено полю (%d клеток). В очереди: %d" % [area,field_tasks.size()]
 if job == "":
  _start_next_field_task()
 _save()

func _start_next_field_task() -> void:
 if job != "" or field_tasks.is_empty():
  return
 var task: Dictionary = field_tasks.pop_front()
 var key: String = str(task["key"])
 if not field_plots.has(key):
  _start_next_field_task()
  return
 var parts: PackedStringArray = key.split(",")
 var target := Vector2i(int(parts[0]),int(parts[1]))
 var route: Array[Vector2i] = RoadRouter.find_route(Vector2i(0,8),target,extra_land,roads,_building_obstacles())
 if route.is_empty():
  status.text = "Маршрут к полю недоступен"
  return
 job = str(task["action"])
 active_plot = key
 progress = 0.0
 travel_route = route
 travel_index = 0
 travel_fraction = 0.0

func _travel(delta: float) -> void:
 if travel_route.size() < 2 or travel_index >= travel_route.size()-1:
  travel_route.clear()
  return
 var destination: Vector2i = travel_route[travel_index+1]
 travel_fraction += delta*0.45*_road_speed_at(destination)
 while travel_fraction >= 1.0 and travel_index < travel_route.size()-1:
  travel_fraction -= 1.0
  travel_index += 1
 if travel_index >= travel_route.size()-1:
  tractor.position = Vector3((float(destination.x)+0.5)*CELL,0,(float(destination.y)+0.5)*CELL)
  travel_route.clear()
  status.text = "Техника приступила к работе"
  return
 var origin: Vector2i = travel_route[travel_index]
 destination = travel_route[travel_index+1]
 tractor.position = Vector3((lerpf(float(origin.x),float(destination.x),travel_fraction)+0.5)*CELL,0,(lerpf(float(origin.y),float(destination.y),travel_fraction)+0.5)*CELL)
 tractor.rotation.y = atan2(float(destination.x-origin.x),float(destination.y-origin.y))

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
 var fraction: float = road_vehicle_progress-floorf(road_vehicle_progress)
 tractor.position = Vector3((lerpf(float(from.x),float(to.x),fraction)+0.5)*CELL,0,(lerpf(float(from.y),float(to.y),fraction)+0.5)*CELL)
 tractor.rotation.y = atan2(float(to.x-from.x),float(to.y-from.y))

func _process(delta: float) -> void:
 if not running:
  return
 elapsed_seconds += delta
 if job != "" and active_plot != "" and not travel_route.is_empty():
  _travel(delta)
 day = GameClock.day_from_seconds(elapsed_seconds)
 for plot_key in field_plots.keys():
  var current: Dictionary = _plot_state(str(plot_key))
  if int(current["stage"]) == 1:
   var grown: Dictionary = PlotProduction.grow(current,delta)
   field_plots[plot_key] = grown
   if int(grown["stage"]) == 2:
    _draw()
    _save()
 if job != "" and not (active_plot != "" and not travel_route.is_empty()):
  progress += delta/6.0
  progress = minf(progress,1.0)
  if active_plot == "":
   _update_machine_position()
   _update_field_visuals()
  if progress >= 1.0:
   if active_plot != "":
    var group_cells: Array[String] = _group_cells(active_plot)
    for cell_key in group_cells:
     var old_group: int = _group_of(cell_key)
     var finished: Dictionary = PlotProduction.finish(_plot_state(cell_key),job)
     finished["group"] = old_group
     field_plots[cell_key] = finished
    if job == "harvest":
     grain += PlotProduction.YIELD_TONS*group_cells.size()
    status.text = "Работа на выбранном поле завершена"
    active_plot = ""
   elif job == "prepare":
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
   _save()
   _start_next_field_task()
 elif stage == 1:
  progress += delta/10.0
  _update_field_visuals()
  if progress >= 1.0:
   stage = 2
   progress = 0.0
   status.text = "Пшеница созрела"
   _draw()
 var displayed: Dictionary = _plot_state(selected_plot) if selected_plot != "" else {"stage":stage,"prepared":prepared}
 game_ui.update_hud(day,cash,grain,int(displayed["stage"]),job,progress,build,bool(displayed["prepared"]),ProductionRules.capacity(structures),selected_plot != "")
 if selected_plot != "":
  game_ui.task.text = "Поле %s (%d клеток): %s" % [selected_plot,_group_cells(selected_plot).size(),["Подготовка" if not bool(displayed["prepared"]) else "Готово к посеву","Растёт","Созрело"][int(displayed["stage"])]]
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
  var k := Territory.key(cell)
  selected_plot = k if field_plots.has(k) else ""
  if pending_field_action != "":
   if selected_plot == "" and cell.x >= 5 and cell.x <= 8 and cell.y >= 3 and cell.y <= 6:
    var requested: String = pending_field_action
    pending_field_action = ""
    _job(requested)
   elif selected_plot == "":
    status.text = "Выберите поле, а не пустую землю"
   else:
    _plot_job(pending_field_action)
  else:
   status.text = "Выбрано поле "+k if selected_plot != "" else "Стартовое поле"
  _draw()
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
 elif e is InputEventKey and e.pressed and e.keycode == KEY_ESCAPE and (build or territory_mode != "" or pending_field_action != ""):
  _cancel_build()
  pending_field_action = ""
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
 _save()
 status.text = "Постройка завершена!"
func _route_save() -> Array:
 var result: Array = []
 for cell in travel_route:
  result.append([cell.x,cell.y])
 return result

func _snapshot() -> Dictionary:
 return {"version":1,"cash":cash,"grain":grain,"stage":stage,"prepared":prepared,"structures":structures.duplicate(),"job":job,"progress":progress,"day":day,"elapsed_seconds":elapsed_seconds,"extra_land":extra_land.duplicate(),"field_plots":field_plots.duplicate(),"roads":roads.duplicate(),"farm_profile":farm_profile.duplicate(true),"selected_plot":selected_plot,"active_plot":active_plot,"travel_index":travel_index,"travel_fraction":travel_fraction,"travel_route":_route_save(),"next_field_group_id":next_field_group_id,"field_tasks":field_tasks.duplicate(true)}
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
 for plot_key in field_plots.keys():
  field_plots[plot_key] = _plot_state(str(plot_key))
 next_field_group_id = maxi(1,int(data.get("next_field_group_id",1)))
 for plot_key in field_plots:
  next_field_group_id = maxi(next_field_group_id,_group_of(str(plot_key))+1)
 field_tasks.clear()
 for task in data.get("field_tasks",[]):
  if task is Dictionary and field_plots.has(str(task.get("key",""))) and str(task.get("action","")) in ["prepare","sow","harvest"]:
   field_tasks.append(task)
 pending_field_action = ""
 selected_plot = str(data.get("selected_plot",""))
 if not field_plots.has(selected_plot):
  selected_plot = ""
 active_plot = str(data.get("active_plot",""))
 if not field_plots.has(active_plot):
  active_plot = ""
 travel_route.clear()
 for pair in data.get("travel_route",[]):
  if pair is Array and pair.size() == 2:
   travel_route.append(Vector2i(int(pair[0]),int(pair[1])))
 travel_index = clampi(int(data.get("travel_index",0)),0,maxi(0,travel_route.size()-1))
 travel_fraction = clampf(float(data.get("travel_fraction",0.0)),0.0,0.999)
 farm_profile = data.get("farm_profile",{}).duplicate(true)
 if not farm_profile.is_empty():
  if not FarmRegistry.validate(farm_profile):
   farm_profile.clear()
  else:
   farm_profile["plot_x"] = int(farm_profile["plot_x"])
   farm_profile["plot_y"] = int(farm_profile["plot_y"])
 if not Territory.valid_layout(extra_land,field_plots,roads):
  extra_land.clear()
  field_plots.clear()
  roads.clear()
  selected_plot = ""
  active_plot = ""
  travel_route.clear()
 _cancel_build()
 job = str(data["job"])
 progress = float(data["progress"])
 day = int(data["day"])
 elapsed_seconds = float(data.get("elapsed_seconds", (day-1) * GameClock.SECONDS_PER_YEAR / 365.0))
 _draw()
 if job == "" and not field_tasks.is_empty():
  _start_next_field_task()
