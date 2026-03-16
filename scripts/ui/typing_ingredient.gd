# video-game/scenes/ui/typing_ingredient.gd
extends VBoxContainer

@onready var texture_rect = $CenterContainer/TextureRect
@onready var label = $MarginContainer/Text

const INGREDIENT_ASSETS: Array[String] = [
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Ingredient/food/1carrot.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Ingredient/food/2meat.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Ingredient/food/3cabbage.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Ingredient/food/4egg.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Ingredient/food/5rice.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Ingredient/food/8bread.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Ingredient/sweets/1vanilla.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Ingredient/sweets/2strawberry.png",
]

func set_ingredient(ing_name: String):
	# ตรวจสอบว่า Node พร้อมใช้งานหรือยัง ถ้ายังให้รอ (await) จนกว่าจะ ready
	if not is_node_ready():
		await ready 

	# กำหนดชื่อวัตถุดิบลงใน Label
	if label:
		label.text = ing_name
		label.queue_redraw()

	# ส่วนการโหลดรูปภาพ (mock mapping: pick a deterministic asset)
	var path = _pick_asset_path(ing_name, INGREDIENT_ASSETS)
	if path != "" and ResourceLoader.exists(path):
		texture_rect.texture = load(path)
	else:
		# หากไม่พบรูปภาพให้ใช้รูปเริ่มต้น (icon.svg)
		texture_rect.texture = preload("res://icon.svg")

func _pick_asset_path(key: String, assets: Array[String]) -> String:
	if assets.is_empty():
		return ""
	var acc := 0
	for i in key.length():
		acc += key.unicode_at(i)
	return assets[acc % assets.size()]
