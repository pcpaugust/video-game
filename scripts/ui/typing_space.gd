extends MarginContainer

# ดึง Node ลูกออกมาเตรียมไว้
@onready var mode = $TypingSpace/TypingBlock/BlockContent/ModeLabel
@onready var input_label = $TypingSpace/TypingBlock/BlockContent/TextField
@onready var icon_container = $TypingSpace/HBoxContainer

const TypingIngredientScene = preload("res://scenes/ui/TypingIngredient.tscn")
const MenuData = preload("res://scripts/data/menu_data.gd")
const GameConfig = preload("res://scripts/config/game_config.gd")

func update_mode(new_mode: String):
	if mode:
		mode.text = new_mode

func update_preview(current_buffer: String):
	# 1. อัปเดตตัวหนังสือที่กำลังพิมพ์ (เสมือน TextField)
	if input_label:
		input_label.text = current_buffer
	
	# 2. ลบไอคอนเก่าเฉพาะใน HBoxContainer (ไม่ไปลบ Label ข้างนอก)
	for child in icon_container.get_children():
		child.queue_free()
		
	# 3. สร้างไอคอนใหม่ตามคำที่พิมพ์
	var words = current_buffer.strip_edges().split(" ", false)
	for word in words:
		if MenuData.is_valid_ingredient(word):
			var icon = TypingIngredientScene.instantiate()
			icon_container.add_child(icon)
			if icon.has_method("set_ingredient"):
				icon.call_deferred("set_ingredient", word)
