# video-game/scenes/ui/typing_ingredient.gd
@tool
extends VBoxContainer

const MenuConfig = preload("res://scripts/config/menu_config.gd")
const NOODLE_TEXTURES: Dictionary = {
	"เส้นเล็ก": preload("res://assets/figma/nood01.png"),
	"เส้นหมี่": preload("res://assets/figma/nood02.png"),
	"วุ้นเส้น": preload("res://assets/figma/nood03.png"),
	"บะหมี่": preload("res://assets/figma/nood04.png"),
	"เส้นใหญ่": preload("res://assets/figma/nood05.png"),
}

@onready var icon_panel: PanelContainer = $CenterContainer/IconCircle
@onready var icon_texture: TextureRect = $CenterContainer/IconCircle/IconTexture
@onready var label: Label = $MarginContainer/Text

@export var editor_preview_ingredient: String = "เส้นเล็ก":
	set(value):
		editor_preview_ingredient = value
		if Engine.is_editor_hint() and is_node_ready():
			set_ingredient(editor_preview_ingredient)

var style_grey: StyleBoxFlat
var style_yellow: StyleBoxFlat
var style_orange: StyleBoxFlat
var style_green: StyleBoxFlat
var style_blue: StyleBoxFlat
var style_clear: StyleBoxFlat

func _ready() -> void:
	if Engine.is_editor_hint() and editor_preview_ingredient != "":
		set_ingredient(editor_preview_ingredient)

func set_ingredient(ing_name: String):
	# ตรวจสอบว่า Node พร้อมใช้งานหรือยัง ถ้ายังให้รอ (await) จนกว่าจะ ready
	if not is_node_ready():
		await ready 

	# กำหนดชื่อวัตถุดิบลงใน Label
	if label:
		label.text = ing_name
		label.queue_redraw()

	_apply_icon_visual(ing_name)

func _apply_icon_visual(ing_name: String) -> void:
	_ensure_styles()
	if not icon_panel:
		return

	var ing_texture: Texture2D = _get_ingredient_texture(ing_name)
	if icon_texture:
		icon_texture.texture = ing_texture
		icon_texture.visible = ing_texture != null

	var style: StyleBoxFlat = style_yellow
	if ing_texture != null:
		style = style_clear
	elif ing_name in MenuConfig.BROTH_TYPES:
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

func _get_ingredient_texture(ing_name: String) -> Texture2D:
	if not NOODLE_TEXTURES.has(ing_name):
		return null
	return NOODLE_TEXTURES[ing_name] as Texture2D

func _ensure_styles() -> void:
	if style_grey != null:
		return
	style_grey = _make_circle_style(Color(0.439216, 0.415686, 0.415686, 1))
	style_yellow = _make_circle_style(Color(0.973, 0.914, 0.227, 1.0))
	style_orange = _make_circle_style(Color(0.976471, 0.556863, 0.235294, 1))
	style_green = _make_circle_style(Color(0.262745, 0.760784, 0.337255, 1))
	style_blue = _make_circle_style(Color(0.294118, 0.376471, 0.941176, 1))
	style_clear = _make_circle_style(Color(0, 0, 0, 0))

func _make_circle_style(color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 999
	style.corner_radius_top_right = 999
	style.corner_radius_bottom_right = 999
	style.corner_radius_bottom_left = 999
	return style
