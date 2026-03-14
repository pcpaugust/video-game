# video-game/scenes/ui/typing_ingredient.gd
extends VBoxContainer

@onready var texture_rect = $CenterContainer/TextureRect
@onready var label = $MarginContainer/Text

func set_ingredient(ing_name: String):
	# ตรวจสอบว่า Node พร้อมใช้งานหรือยัง ถ้ายังให้รอ (await) จนกว่าจะ ready
	if not is_node_ready():
		await ready 

	# กำหนดชื่อวัตถุดิบลงใน Label
	if label:
		label.text = ing_name
		label.queue_redraw()

	# ส่วนการโหลดรูปภาพ
	var path = "res://assets/ingredients/%s.png" % ing_name
	if FileAccess.file_exists(path):
		texture_rect.texture = load(path)
	else:
		# หากไม่พบรูปภาพให้ใช้รูปเริ่มต้น (icon.svg)
		texture_rect.texture = preload("res://icon.svg")
