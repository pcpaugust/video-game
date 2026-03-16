# video-game/scenes/ui/typing_ingredient.gd
extends VBoxContainer

const MenuConfig = preload("res://scripts/config/menu_config.gd")

@onready var icon_panel: PanelContainer = $CenterContainer/IconCircle
@onready var label: Label = $MarginContainer/Text

var style_grey: StyleBoxFlat
var style_yellow: StyleBoxFlat
var style_orange: StyleBoxFlat
var style_green: StyleBoxFlat
var style_blue: StyleBoxFlat

func set_ingredient(ing_name: String):
	# ตรวจสอบว่า Node พร้อมใช้งานหรือยัง ถ้ายังให้รอ (await) จนกว่าจะ ready
	if not is_node_ready():
		await ready 

	# กำหนดชื่อวัตถุดิบลงใน Label
	if label:
		label.text = ing_name
		label.queue_redraw()

	_apply_icon_color(ing_name)

func _apply_icon_color(ing_name: String) -> void:
	_ensure_styles()
	if not icon_panel:
		return

	var style: StyleBoxFlat = style_yellow
	if ing_name in MenuConfig.BROTH_TYPES:
		style = style_grey
	elif ing_name in MenuConfig.NOODLE_TYPES:
		style = style_yellow
	elif ing_name in MenuConfig.MEAT_TYPES:
		style = style_orange
	elif ing_name in MenuConfig.VEGETABLE_TYPES:
		style = style_green
	elif ing_name in MenuConfig.DRINK_TYPES:
		style = style_blue

	icon_panel.add_theme_stylebox_override("panel", style)

func _ensure_styles() -> void:
	if style_grey != null:
		return
	style_grey = _make_circle_style(Color(0.439216, 0.415686, 0.415686, 1))
	style_yellow = _make_circle_style(Color(0.972549, 0.913725, 0.643137, 1))
	style_orange = _make_circle_style(Color(0.976471, 0.556863, 0.235294, 1))
	style_green = _make_circle_style(Color(0.262745, 0.760784, 0.337255, 1))
	style_blue = _make_circle_style(Color(0.294118, 0.376471, 0.941176, 1))

func _make_circle_style(color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 999
	style.corner_radius_top_right = 999
	style.corner_radius_bottom_right = 999
	style.corner_radius_bottom_left = 999
	return style
