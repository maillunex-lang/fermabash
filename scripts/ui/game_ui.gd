extends CanvasLayer
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

const BG := Color("132b28")
const PANEL := Color("183a34",0.94)
const ACCENT := Color("e4aa4b")
const TEXT := Color("f5f2e9")
const MUTED := Color("b8c9c1")

func _ready() -> void:
 name = "GameUI"
 main_root = Control.new()
 main_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(main_root)
 _make_hud()
 _make_menu()
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
 button.custom_minimum_size = Vector2(120,56)
 button.add_theme_font_size_override("font_size",20)
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
 main_root.add_child(info_panel)
 var info := VBoxContainer.new()
 info.add_theme_constant_override("separation",5)
 info_panel.add_child(info)
 var brand := _label("AGRO EMPIRE  /  БАШКОРТОСТАН",19,ACCENT)
 info.add_child(brand)
 stats = _label("",20)
 info.add_child(stats)
 task = _label("Хозяйство готово к работе",17,MUTED)
 info.add_child(task)
 progress_bar = ProgressBar.new()
 progress_bar.custom_minimum_size.y = 9
 progress_bar.show_percentage = false
 progress_bar.value = 0
 info.add_child(progress_bar)
 message = _label("Выберите действие",17,MUTED)
 info.add_child(message)
 actions_panel = PanelContainer.new()
 actions_panel.add_theme_stylebox_override("panel",_style(PANEL))
 main_root.add_child(actions_panel)
 var flow := GridContainer.new()
 flow.columns = 3
 flow.add_theme_constant_override("h_separation",8)
 flow.add_theme_constant_override("v_separation",8)
 actions_panel.add_child(flow)
 for entry in [
  ["Посев","sow"],["Уборка","harvest"],["Продать","sell"],
  ["Навес 1×1","build_shed"],["Склад 2×2","build"],["Мастерская 3×3","build_workshop"],
  ["Агрокомплекс 4×4","build_complex"],["Отмена","cancel_build"],["Сохранить","save"],["Меню","menu"]
 ]:
  action_buttons[entry[1]] = _button(flow,entry[0],entry[1])

func _make_menu() -> void:
 menu_overlay = ColorRect.new()
 menu_overlay.color = Color("0a201d",0.96)
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

func _layout() -> void:
 var viewport := get_viewport().get_visible_rect().size
 var compact := viewport.x < 900
 info_panel.position = Vector2(12,12)
 info_panel.size = Vector2(minf(viewport.x-24,560 if not compact else viewport.x-24),0)
 actions_panel.position = Vector2(12,viewport.y-(250 if compact else 180))
 actions_panel.size = Vector2(minf(viewport.x-24,510 if compact else 840),0)
 var flow := actions_panel.get_child(0) as GridContainer
 flow.columns = 3 if compact else 6
 for button in action_buttons.values():
  button.custom_minimum_size = Vector2(maxf(100,(actions_panel.size.x-38)/float(flow.columns)),52 if compact else 58)
 title_label.add_theme_font_size_override("font_size",26 if compact else 34)

func show_menu() -> void:
 menu_overlay.visible = true
func hide_menu() -> void:
 menu_overlay.visible = false
func set_status(value: String) -> void:
 message.text = value
func update_hud(day: int, cash: int, grain: int, stage: int, job: String, progress: float, building: bool) -> void:
 stats.text = "День %d     %d ₽     Зерно: %d т" % [day,cash,grain]
 var stage_name: String = ["Поле свободно","Посевы растут","Урожай созрел"][clampi(stage,0,2)]
 task.text = ("Строительство: выберите клетку" if building else ("Работа: "+("посев" if job == "sow" else "уборка") if job != "" else stage_name))
 progress_bar.value = clampf(progress*100.0,0.0,100.0)
 action_buttons["sow"].disabled = job != "" or stage != 0 or cash < 100
 action_buttons["harvest"].disabled = job != "" or stage != 2
 action_buttons["sell"].disabled = grain <= 0
 action_buttons["build"].disabled = cash < 900
 action_buttons["build_shed"].disabled = cash < 250
 action_buttons["build_workshop"].disabled = cash < 1600
 action_buttons["build_complex"].disabled = cash < 3000
 action_buttons["cancel_build"].disabled = not building
