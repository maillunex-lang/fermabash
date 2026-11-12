extends Control
const Catalog = preload("res://scripts/systems/beta_city_catalog.gd")
signal city_selected(city_id: String)
var buttons: Dictionary = {}
var selected_id := ""
const MAP_BG := Color("193c37")
const MAP_LINE := Color("426e62",0.45)
const PIN := Color("e8b35e")

func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_STOP
 custom_minimum_size = Vector2(600,350)
 resized.connect(_place_pins)
 for item in Catalog.CITIES:
  var city_id: String = str(item["id"])
  var button := Button.new()
  button.text = "●"
  button.tooltip_text = str(item["name"])
  button.custom_minimum_size = Vector2(54,54)
  button.add_theme_font_size_override("font_size",17)
  button.add_theme_color_override("font_color",Color("fff4dc"))
  button.pressed.connect(func(): _select(city_id))
  add_child(button)
  buttons[city_id] = button
 _place_pins()

func _select(city_id: String) -> void:
 if Catalog.city(city_id).is_empty():
  return
 selected_id = city_id
 city_selected.emit(city_id)
 queue_redraw()

func _place_pins() -> void:
 var area := Rect2(Vector2(40,40),Vector2(maxf(size.x-80,1),maxf(size.y-80,1)))
 var occupied: Array[Vector2] = []
 for item in Catalog.CITIES:
  var button: Button = buttons[str(item["id"])]
  var p := area.position + Catalog.normalized(item)*area.size
  var candidate := Vector2(clampf(p.x-27,0,maxf(size.x-54,0)),clampf(p.y-27,0,maxf(size.y-54,0)))
  for attempt in range(8):
   var collides := false
   for existing in occupied:
    if candidate.distance_to(existing) < 56:
     collides = true
     break
   if not collides:
    break
   candidate.y = fposmod(candidate.y+58.0,maxf(size.y-54,1))
  occupied.append(candidate)
  button.position = candidate
 queue_redraw()

func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO,size),MAP_BG,true)
 var area := Rect2(Vector2(40,40),Vector2(maxf(size.x-80,1),maxf(size.y-80,1)))
 for i in range(1,6):
  var x := area.position.x + area.size.x*float(i)/6.0
  draw_line(Vector2(x,0),Vector2(x,size.y),MAP_LINE,1.0)
 for i in range(1,4):
  var y := area.position.y + area.size.y*float(i)/4.0
  draw_line(Vector2(0,y),Vector2(size.x,y),MAP_LINE,1.0)
 for item in Catalog.CITIES:
  var p := area.position+Catalog.normalized(item)*area.size
  draw_circle(p,7.0,PIN)
  if buttons.has(str(item["id"])):
   var center: Vector2 = (buttons[str(item["id"])] as Button).position+Vector2(27,27)
   draw_line(p,center,PIN,1.5)
