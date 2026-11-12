extends CanvasLayer
const FarmRegistry = preload("res://scripts/systems/farm_registry.gd")
const MarketRules = preload("res://scripts/systems/market_rules.gd")
## Russian-language adaptive HUD and menu. All game actions are emitted as signals.
signal action_requested(action: String)
var stats: Label
var message: Label
var task: Label
var progress_bar: ProgressBar
var menu_overlay: ColorRect
var menu_buttons: Dictionary = {}
var action_buttons: Dictionary = {}
var info_panel: PanelContainer
var actions_panel: PanelContainer
var title_label: Label
var main_root: Control
var active_tab := "field"
var region_overlay: ColorRect
var region_panel: PanelContainer
var region_list: VBoxContainer
var region_title: Label
var region_selected := ""
var city_map: Control
var city_details: Label
var city_buttons: Dictionary = {}
var city_scroll: ScrollContainer
var tab_buttons: Dictionary = {}


const BG := Color("132b28")
const PANEL := Color("183a34",0.94)
const ACCENT := Color("e4aa4b")
const TEXT := Color("f5f2e9")
const MUTED := Color("b8c9c1")

func _ready() -> void:
 name = "GameUI"
 main_root = Control.new()
 main_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 main_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(main_root)
 _make_hud()
 _make_menu()
 _make_region_menu()
 get_viewport().size_changed.connect(_layout)
 _layout()

func _style(bg: Color, radius: int = 14) -> StyleBoxFlat:
 var style := StyleBoxFlat.new()
 style.bg_color = bg
 style.set_corner_radius_all(radius)
 style.content_margin_left = 14
 style.content_margin_right = 14
 style.content_margin_top = 10
 style.content_margin_bottom = 10
 return style

func _label(text_value: String, size: int, color: Color = TEXT) -> Label:
 var label := Label.new()
 label.text = text_value
 label.add_theme_font_size_override("font_size",size)
 label.add_theme_color_override("font_color",color)
 return label

func _button(parent: Node, label: String, action: String, primary := false) -> Button:
 var button := Button.new()
 button.text = label
 button.custom_minimum_size = Vector2(168,74)
 button.add_theme_font_size_override("font_size",25)
 button.add_theme_color_override("font_color",BG if primary else TEXT)
 button.add_theme_stylebox_override("normal",_style(ACCENT if primary else Color("29554a")))
 button.add_theme_stylebox_override("hover",_style(Color("f0c476") if primary else Color("346b5b")))
 button.add_theme_stylebox_override("pressed",_style(Color("b88533") if primary else Color("1d473d")))
 button.pressed.connect(func(): action_requested.emit(action))
 parent.add_child(button)
 return button

func _make_hud() -> void:
 info_panel = PanelContainer.new()
 info_panel.add_theme_stylebox_override("panel",_style(PANEL))
 info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
 main_root.add_child(info_panel)
 var info := VBoxContainer.new()
 info.add_theme_constant_override("separation",5)
 info_panel.add_child(info)
 var brand := _label("AGRO EMPIRE  /  БАШКОРТОСТАН",22,ACCENT)
 info.add_child(brand)
 stats = _label("",24)
 stats.autowrap_mode = TextServer.AUTOWRAP_WORD
 info.add_child(stats)
 task = _label("Хозяйство готово к работе",20,MUTED)
 info.add_child(task)
 progress_bar = ProgressBar.new()
 progress_bar.custom_minimum_size.y = 9
 progress_bar.show_percentage = false
 progress_bar.value = 0
 info.add_child(progress_bar)
 message = _label("Выберите действие",19,MUTED)
 info.add_child(message)
 actions_panel = PanelContainer.new()
 actions_panel.add_theme_stylebox_override("panel",_style(PANEL))
 actions_panel.mouse_filter = Control.MOUSE_FILTER_STOP
 main_root.add_child(actions_panel)
 var outer := VBoxContainer.new()
 outer.add_theme_constant_override("separation",8)
 actions_panel.add_child(outer)
 var tabs := HBoxContainer.new()
 tabs.add_theme_constant_override("separation",8)
 outer.add_child(tabs)
 for entry in [["Поля","field"],["Стройка","construction"],["Земля","territory"],["Рынок","market"]]:
  var tab := _button(tabs,entry[0],"tab_"+entry[1])
  tab_buttons[entry[1]] = tab
 var flow := GridContainer.new()
 flow.columns = 3
 flow.add_theme_constant_override("h_separation",8)
 flow.add_theme_constant_override("v_separation",8)
 outer.add_child(flow)
 for entry in [
  ["Подготовить","prepare"],["Посев","sow"],["Уборка","harvest"],["Продать","sell"],
  ["Навес 1×1","build_shed"],["Склад 2×2","build"],["Мастерская 3×3","build_workshop"],
  ["Агрокомплекс 4×4","build_complex"],["Купить землю 100 ₽","buy_land"],["Новое поле 80 ₽/клетка","place_field"],["Грунт 40 ₽","road_dirt"],["Щебень 100 ₽","road_gravel"],["Асфальт 250 ₽","road_asphalt"],["Отмена","cancel_build"],["Сохранить","save"],["Карта","region_map"],["Меню","menu"],
  ["Элеватор","contract_short"],["Мельница","contract_bulk"],["Бригада","hire_crew"]
 ]:
  action_buttons[entry[1]] = _button(flow,entry[0],entry[1])
 show_tab("field")

func _make_menu() -> void:
 menu_overlay = ColorRect.new()
 menu_overlay.color = Color("0a201d",0.96)
 menu_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
 menu_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 main_root.add_child(menu_overlay)
 var center := CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 menu_overlay.add_child(center)
 var panel := PanelContainer.new()
 panel.custom_minimum_size = Vector2(360,390)
 panel.add_theme_stylebox_override("panel",_style(Color("1b3b34")))
 center.add_child(panel)
 var box := VBoxContainer.new()
 box.add_theme_constant_override("separation",13)
 panel.add_child(box)
 title_label = _label("AGRO EMPIRE ONLINE",30,ACCENT)
 title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 box.add_child(title_label)
 var subtitle := _label("Экономическая стратегия • Башкортостан",17,MUTED)
 subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 box.add_child(subtitle)
 for entry in [
  ["Новая игра","new"],["Продолжить","continue"],
  ["Настройки","settings"],["Выход","quit"]
 ]:
  menu_buttons[entry[1]] = _button(box,entry[0],entry[1],entry[1] == "new")

func _make_region_menu() -> void:
 region_overlay = ColorRect.new()
 region_overlay.color = Color("0a201d",0.94)
 region_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 region_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
 main_root.add_child(region_overlay)
 var center := CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 region_overlay.add_child(center)
 region_panel = PanelContainer.new()
 region_panel.add_theme_stylebox_override("panel",_style(Color("1b3b34")))
 center.add_child(region_panel)
 region_list = VBoxContainer.new()
 region_list.add_theme_constant_override("separation",10)
 region_panel.add_child(region_list)
 region_title = _label("БАШКОРТОСТАН · РАЙОНЫ",28,ACCENT)
 region_list.add_child(region_title)
 _button(region_list,"← Вернуться к хозяйству","region_close")
 region_overlay.visible = false

func show_regions(profile: Dictionary = {}) -> void:
 region_overlay.visible = true
 _populate_regions(profile)

func hide_regions() -> void:
 region_overlay.visible = false

func _clear_region_choices() -> void:
 city_map = null
 city_details = null
 city_scroll = null
 city_buttons.clear()
 for child in region_list.get_children():
  if child != region_title:
   child.queue_free()

func _populate_regions(profile: Dictionary = {}) -> void:
 _clear_region_choices()
 region_title.text = "БАШКОРТОСТАН · РАЙОНЫ"
 region_list.add_child(_label("Бета: районы и локальная ферма. Общая карта игроков появится с сервером.",18,MUTED))
 for district in FarmRegistry.DISTRICTS:
  var id: String = str(district["id"])
  _button(region_list,str(district["name"]),"region_district:"+id)
 if FarmRegistry.validate(profile):
  region_list.add_child(_label("Ваша ферма: "+str(profile["name"]),21,ACCENT))
 _button(region_list,"← К хозяйству","region_close")

func show_district(id: String, profile: Dictionary = {}) -> void:
 var district: Dictionary = FarmRegistry.district(id)
 if district.is_empty():
  return
 region_selected = id
 _clear_region_choices()
 region_title.text = str(district["name"]).to_upper()
 region_list.add_child(_label("Схематичная сетка района, без реальных кадастровых границ.",17,MUTED))
 var grid := GridContainer.new()
 grid.columns = FarmRegistry.GRID
 grid.add_theme_constant_override("h_separation",2)
 grid.add_theme_constant_override("v_separation",2)
 region_list.add_child(grid)
 var has_farm: bool = FarmRegistry.validate(profile) and profile["district_id"] == id
 for y in range(FarmRegistry.GRID):
  for x in range(FarmRegistry.GRID):
   var tile := Button.new()
   tile.custom_minimum_size = Vector2(44,34)
   var occupied := has_farm and x >= int(profile["plot_x"]) and x < int(profile["plot_x"])+2 and y >= int(profile["plot_y"]) and y < int(profile["plot_y"])+2
   tile.text = "Ф" if occupied else "·"
   tile.disabled = true
   grid.add_child(tile)
 if has_farm:
  region_list.add_child(_label("Ваша ферма: "+str(profile["name"]),20,ACCENT))
 else:
  region_list.add_child(_label("Онлайн-фермы пока недоступны: сервер не подключён.",17,MUTED))
 _button(region_list,"← К районам","region_back")
 _button(region_list,"← К хозяйству","region_close")

func _layout_regions() -> void:
 var viewport := get_viewport().get_visible_rect().size
 region_panel.custom_minimum_size = Vector2(minf(viewport.x-32.0,780.0),0)

func _layout() -> void:
 var viewport := get_viewport().get_visible_rect().size
 var compact := viewport.x < 1050
 var margin := 18.0
 info_panel.position = Vector2(margin,margin)
 info_panel.size = Vector2(minf(viewport.x * 0.45,580.0),0)
 var width := minf(viewport.x-2.0*margin,690.0)
 var flow := actions_panel.get_child(0).get_child(1) as GridContainer
 flow.columns = 2 if compact else 3
 var button_width := (width-64.0-float(flow.columns-1)*10.0)/float(flow.columns)
 for button in action_buttons.values():
  button.custom_minimum_size = Vector2(button_width,74)
 var tab_count := maxi(1, tab_buttons.size())
 for button in tab_buttons.values():
  button.custom_minimum_size = Vector2((width-66.0)/float(tab_count),64)
  button.add_theme_font_size_override("font_size",18 if compact else 20)
 actions_panel.size = Vector2(width,0)
 actions_panel.position = Vector2(margin,viewport.y-actions_panel.get_combined_minimum_size().y-margin)
 title_label.add_theme_font_size_override("font_size",32)
 region_panel.custom_minimum_size = Vector2(minf(viewport.x-32.0,780.0),0)
 _layout_regions()

func show_menu() -> void:
 menu_overlay.visible = true
func hide_menu() -> void:
 menu_overlay.visible = false
func set_status(value: String) -> void:
 message.text = value
func update_hud(day: int, cash: int, grain: int, stage: int, job: String, progress: float, building: bool, prepared: bool = false, capacity: int = 6, plot_selected: bool = false) -> void:
 stats.text = "Сезон %d    %d ₽    Зерно %d/%d т" % [day,cash,grain,capacity]
 var stage_name: String = ["Поле подготовлено" if prepared else "Поле требует подготовки","Посевы растут","Урожай созрел"][clampi(stage,0,2)]
 task.text = ("Строительство: выберите клетку" if building else ("Работа: "+("посев" if job == "sow" else "уборка") if job != "" else stage_name))
 progress_bar.value = clampf(progress*100.0,0.0,100.0)
 action_buttons["prepare"].disabled = false
 action_buttons["sow"].disabled = false
 action_buttons["harvest"].disabled = false
 action_buttons["sell"].disabled = grain <= 0
 action_buttons["build"].disabled = cash < 900
 action_buttons["build_shed"].disabled = cash < 250
 action_buttons["build_workshop"].disabled = cash < 1600
 action_buttons["build_complex"].disabled = cash < 3000
 action_buttons["cancel_build"].disabled = false

func show_tab(tab: String) -> void:
 active_tab = tab
 for action in action_buttons:
  var construction: bool = str(action).begins_with("build")
  var territory: bool = action in ["buy_land","place_field","road_dirt","road_gravel","road_asphalt"]
  var market: bool = action in ["contract_short","contract_bulk","hire_crew"]
  var visible_action := false
  if tab == "territory":
   visible_action = territory
  elif tab == "construction":
   visible_action = construction
  elif tab == "market":
   visible_action = market
  else:
   visible_action = not construction and not territory and not market
  if action == "cancel_build":
   visible_action = tab == "construction" or tab == "territory"
  action_buttons[action].visible = visible_action
 call_deferred("_layout")
 for key in tab_buttons:
  tab_buttons[key].disabled = key == tab

func refresh_economy(trading: int, contract: Dictionary, crew_until: int, cash: int, grain: int) -> void:
 var price := MarketRules.spot_price(trading)
 stats.text += "    Торги %d · %d ₽/т" % [trading, price]
 var short_offer := MarketRules.offer_short(trading)
 var bulk_offer := MarketRules.offer_bulk(trading)
 var short_btn: Button = action_buttons["contract_short"]
 var bulk_btn: Button = action_buttons["contract_bulk"]
 var hire_btn: Button = action_buttons["hire_crew"]
 if contract.is_empty():
  short_btn.text = "Элеватор %d т · %d ₽" % [int(short_offer["tons"]), int(short_offer["price"])]
  bulk_btn.text = "Мельница %d т · %d ₽" % [int(bulk_offer["tons"]), int(bulk_offer["price"])]
 else:
  var active_short := str(contract.get("id","")).begins_with("short")
  short_btn.text = ("Сдать элеватору %d т" % int(contract.get("tons",0))) if active_short else "Элеватор занят"
  bulk_btn.text = ("Сдать мельнице %d т" % int(contract.get("tons",0))) if not active_short else "Мельница занята"
 var hired := MarketRules.crew_active(trading, crew_until)
 hire_btn.text = ("Бригада до дня %d" % crew_until) if hired else ("Нанять бригаду %d ₽" % MarketRules.CREW_COST)
 if active_tab == "market":
  var ahead := MarketRules.forecast(trading, 5)
  task.text = "Прогноз ₽/т: %d  %d  %d  %d  %d" % [ahead[0], ahead[1], ahead[2], ahead[3], ahead[4]]
