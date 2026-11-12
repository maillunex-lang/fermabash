extends CanvasLayer
const Registry = preload("res://scripts/systems/farm_registry.gd")
signal confirmed(profile: Dictionary)
signal cancelled()
var overlay: ColorRect
var district_select: OptionButton
var name_input: LineEdit
var grid: GridContainer
var info: Label
var selected := Vector2i(-1,-1)
var occupied: Array = []
var farm_buttons: Dictionary = {}
var district_id := ""

func _ready() -> void:
 overlay = ColorRect.new()
 overlay.color = Color("102721",0.98)
 overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 overlay.mouse_filter = Control.MOUSE_FILTER_STOP
 add_child(overlay)
 var scroll := ScrollContainer.new()
 scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 overlay.add_child(scroll)
 var center := CenterContainer.new()
 center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 center.size_flags_vertical = Control.SIZE_EXPAND_FILL
 scroll.add_child(center)
 var box := VBoxContainer.new()
 box.custom_minimum_size = Vector2(600,0)
 box.add_theme_constant_override("separation",8)
 center.add_child(box)
 var title := Label.new()
 title.text = "СОЗДАНИЕ ХОЗЯЙСТВА"
 title.add_theme_font_size_override("font_size",30)
 box.add_child(title)
 var subtitle := Label.new()
 subtitle.text = "Локальная альфа: выбор района и участка. Другие игроки появятся после запуска сервера."
 subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 box.add_child(subtitle)
 name_input = LineEdit.new()
 name_input.placeholder_text = "Название фермы (3–40 символов)"
 name_input.custom_minimum_size.y = 52
 box.add_child(name_input)
 district_select = OptionButton.new()
 district_select.custom_minimum_size.y = 52
 district_select.add_item("Выберите район",0)
 for i in range(Registry.DISTRICTS.size()):
  district_select.add_item(str(Registry.DISTRICTS[i]["name"]),i+1)
 district_select.item_selected.connect(_district_changed)
 box.add_child(district_select)
 info = Label.new()
 info.text = "Выберите район, затем свободную клетку для участка 2×2."
 info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 box.add_child(info)
 grid = GridContainer.new()
 grid.columns = Registry.GRID
 grid.add_theme_constant_override("h_separation",2)
 grid.add_theme_constant_override("v_separation",2)
 box.add_child(grid)
 for y in range(Registry.GRID):
  for x in range(Registry.GRID):
   var cell := Vector2i(x,y)
   var button := Button.new()
   button.text = "·"
   button.custom_minimum_size = Vector2(46,36)
   button.add_theme_font_size_override("font_size",15)
   button.pressed.connect(func(): _choose(cell))
   grid.add_child(button)
   farm_buttons[Registry.GRID*y+x] = button
 var confirm := Button.new()
 confirm.text = "Создать ферму"
 confirm.custom_minimum_size.y = 58
 confirm.pressed.connect(_confirm)
 box.add_child(confirm)
 var back := Button.new()
 back.text = "← Назад"
 back.custom_minimum_size.y = 48
 back.pressed.connect(func(): cancelled.emit())
 box.add_child(back)
 _refresh()

func _district_changed(index: int) -> void:
 district_id = "" if index == 0 else str(Registry.DISTRICTS[index-1]["id"])
 selected = Vector2i(-1,-1)
 _refresh()

func _choose(cell: Vector2i) -> void:
 if district_id == "":
  info.text = "Сначала выберите район."
  return
 if not Registry.plot_free(cell,occupied):
  info.text = "Участок занят или выходит за пределы карты."
  return
 selected = cell
 info.text = "Стартовый участок: (%d, %d), размер 2×2." % [cell.x,cell.y]
 _refresh()

func _refresh() -> void:
 for y in range(Registry.GRID):
  for x in range(Registry.GRID):
   var cell := Vector2i(x,y)
   var button: Button = farm_buttons[Registry.GRID*y+x]
   button.disabled = district_id == "" or not Registry.plot_free(cell,occupied)
   button.text = "✓" if cell == selected else ("×" if button.disabled else "·")

func _confirm() -> void:
 var profile: Dictionary = Registry.create(name_input.text,district_id,selected,occupied)
 if profile.is_empty():
  info.text = "Укажите название (3–40 символов), район и свободный участок."
  return
 confirmed.emit(profile)

func open(occupied_plots: Array = []) -> void:
 occupied = occupied_plots.duplicate()
 selected = Vector2i(-1,-1)
 district_id = ""
 if district_select != null:
  district_select.select(0)
  name_input.text = ""
  _refresh()
 overlay.visible = true

func close() -> void:
 overlay.visible = false
