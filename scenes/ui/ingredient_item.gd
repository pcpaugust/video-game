extends HBoxContainer

@onready var icon: TextureRect = $IconContainer/Icon
@onready var label: Label = $LabelContainer/Label

const INGREDIENT_TEXTURES = MenuConfig.INGREDIENT_TEXTURES

func _get_ingredient_texture(ing_name: String) -> Texture2D:
	if not INGREDIENT_TEXTURES.has(ing_name):
		return null
	return INGREDIENT_TEXTURES[ing_name] as Texture2D
	
func setup(ingredient: String): 
	var img: Texture2D = _get_ingredient_texture(ingredient)
	if img:
		icon.texture = img
		icon.visible = img != null
	if label:
		label.text = ingredient
		label.queue_redraw()
	return
