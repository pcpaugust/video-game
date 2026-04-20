extends Control

const MenuConfig = preload("res://scripts/config/menu_config.gd")

@onready var bg_texture = $Background
@onready var ingredients_container = $Ingredients

# Map broth types to their background textures
var broth_textures: Dictionary = {
	"แห้ง": preload("res://assets/artwork/bowls/black.png"),
	"น้ำใส": preload("res://assets/artwork/bowls/empty.png"),
	"น้ำข้น": preload("res://assets/artwork/bowls/yellow.png"),
	"ต้มยำ": preload("res://assets/artwork/bowls/tomyam.png"),
	"เย็นตาโฟ": preload("res://assets/artwork/bowls/tafo.png")
}

func _ready() -> void:
	clear()

func set_ingredients(ingredients: Array[String]) -> void:
	# Clear old ingredients
	for child in ingredients_container.get_children():
		child.queue_free()
		
	var has_broth = false
	
	# Determine if we have a broth to change the background bowl
	for ing in ingredients:
		if broth_textures.has(ing):
			bg_texture.texture = broth_textures[ing]
			has_broth = true
			break
			
	if not has_broth:
		bg_texture.texture = broth_textures["น้ำใส"] # Default empty bowl
		
	# Add ingredient textures
	for ing in ingredients:
		if ing in MenuConfig.BROTH_TYPES:
			continue # Broth is handled by the bowl background
			
		var tex = _get_ingredient_texture(ing)
		if tex:
			var trect = TextureRect.new()
			trect.texture = tex
			trect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			trect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			trect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			trect.custom_minimum_size = Vector2(96, 96)
			ingredients_container.add_child(trect)

func _get_ingredient_texture(ing_name: String) -> Texture2D:
	if MenuConfig.INGREDIENT_TEXTURES.has(ing_name):
		return MenuConfig.INGREDIENT_TEXTURES[ing_name] as Texture2D
	return null

func clear() -> void:
	set_ingredients([])
