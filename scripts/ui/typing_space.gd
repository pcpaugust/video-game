extends Control

const MenuData = preload("res://scripts/data/menu_data.gd")
const MenuConfig = preload("res://scripts/config/menu_config.gd")

@onready var ingredient_preview: PanelContainer = $IngredientPreview
@onready var ingredient_texture: TextureRect = $IngredientPreview/IngredientTexture
@onready var typing_box: PanelContainer = $TypingBox
@onready var dashed_overlay: Control = $TypingBox/DashedBorderOverlay
@onready var text_field: Label = $TypingBox/BoxMargin/TextField
@onready var space_guide: Label = $TypingBox/SpaceGuide

var style_matched: StyleBoxFlat
var style_unmatched: StyleBoxFlat
var is_matched: bool = false

# Cursor blink
var _cursor_visible: bool = true
var _cursor_timer: float = 0.0
const CURSOR_BLINK_INTERVAL: float = 0.5

var _current_buffer: String = ""

func _ready() -> void:
	style_matched = typing_box.get_theme_stylebox("panel").duplicate()
	style_matched.bg_color = Color("#F5C656") # Yellow
	
	style_unmatched = style_matched.duplicate()
	style_unmatched.bg_color = Color("#EFE5CD") # Cream
	style_unmatched.border_width_bottom = 0
	style_unmatched.border_width_top = 0
	style_unmatched.border_width_left = 0
	style_unmatched.border_width_right = 0
	
	dashed_overlay.draw.connect(_on_dashed_overlay_draw)
	_refresh_display()

func _on_dashed_overlay_draw() -> void:
	if is_matched:
		return
		
	var size = dashed_overlay.size
	var c = Color("#706A6A")
	var w = 3.0
	var d = 15.0
	var h = w / 2.0
	# Draw dashed lines around the perimeter
	dashed_overlay.draw_dashed_line(Vector2(0, h), Vector2(size.x, h), c, w, d)
	dashed_overlay.draw_dashed_line(Vector2(0, size.y - h), Vector2(size.x, size.y - h), c, w, d)
	dashed_overlay.draw_dashed_line(Vector2(h, 0), Vector2(h, size.y), c, w, d)
	dashed_overlay.draw_dashed_line(Vector2(size.x - h, 0), Vector2(size.x - h, size.y), c, w, d)

func _process(delta: float) -> void:
	_cursor_timer += delta
	if _cursor_timer >= CURSOR_BLINK_INTERVAL:
		_cursor_timer = 0.0
		_cursor_visible = !_cursor_visible
		_refresh_display()

# Called by cooking.gd every time the typing buffer changes
func update_preview(current_buffer: String) -> void:
	_current_buffer = current_buffer
	_cursor_visible = true
	_cursor_timer = 0.0
	_refresh_display()

# --- kept for backwards compat; cooking.gd still calls this ---
func update_mode(_new_mode: String) -> void:
	pass

# --- private ---
func _refresh_display() -> void:
	if not is_node_ready():
		return

	# Build display text: typed buffer + blinking cursor
	var cursor = "|" if _cursor_visible else " "
	if text_field:
		text_field.text = _current_buffer + cursor

	var last_word = _get_last_word(_current_buffer)
	var matched_ing = _get_matching_ingredient(last_word)
	
	is_matched = (matched_ing != "")
	
	# Update background styles based on match state
	if is_matched:
		typing_box.add_theme_stylebox_override("panel", style_matched)
	else:
		typing_box.add_theme_stylebox_override("panel", style_unmatched)
	
	# Trigger redraw for the dashed overlay
	dashed_overlay.queue_redraw()

	var matched_texture: Texture2D = null
	if is_matched:
		matched_texture = _get_texture(matched_ing)

	if space_guide:
		space_guide.visible = is_matched

	if ingredient_preview:
		ingredient_preview.visible = matched_texture != null
	if ingredient_texture:
		ingredient_texture.texture = matched_texture

func _get_last_word(buffer: String) -> String:
	var trimmed = buffer.strip_edges()
	if trimmed == "":
		return ""
	var parts = trimmed.split(" ", false)
	if parts.size() == 0:
		return ""
	return parts[parts.size() - 1]

func _get_matching_ingredient(partial_word: String) -> String:
	if partial_word == "": return ""
	
	var matches = []
	for ing in MenuData.all_ingredients():
		if ing == partial_word:
			return ing # Exact match takes priority
		if ing.begins_with(partial_word):
			matches.append(ing)
			
	if matches.size() == 1:
		return matches[0]
		
	return ""

func _get_texture(ing_name: String) -> Texture2D:
	if MenuConfig.INGREDIENT_TEXTURES.has(ing_name):
		return MenuConfig.INGREDIENT_TEXTURES[ing_name] as Texture2D
	return null
