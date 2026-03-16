extends PanelContainer

@onready var name_label = $MarginContainer/VBoxContainer/TopRow/VBoxContainer/NameLabel # ปรับชื่อตามภาพ
@onready var type_label = $MarginContainer/VBoxContainer/TopRow/TypeLabel
@onready var patience_bar = $MarginContainer/VBoxContainer/TopRow/VBoxContainer/PatienceBar
@onready var order_list = $MarginContainer/VBoxContainer/OrderList # โหนด Container ที่เราเพิ่มใหม่

func setup(customer_data: Object):
	name_label.text = customer_data.name
	if (customer_data.is_child):
		type_label.text = "CH"
	elif (customer_data.is_special):
		type_label.text = "SP"
	else: type_label.text = "N"
	update_patience(customer_data.patience, customer_data.max_patience)
	
	# แสดงรายการที่สั่ง
	_display_order_items(customer_data.order_keys)

func _display_order_items(keys: Array):
	# 1. เคลียร์รายการเก่าก่อน (กันเหนียว)
	for child in order_list.get_children():
		child.queue_free()
	
	# 2. สร้างรายการใหม่ตามที่สั่ง
	for key in keys:
		# แบบง่าย: ใช้ Label
		var label = Label.new()
		label.text = "- " + key
		label.add_theme_font_size_override("font_size", 14) # ปรับขนาดตามความเหมาะสม
		label.add_theme_color_override("font_color", Color.BLACK)
		order_list.add_child(label)
		
		# แบบ Advance (ถ้ามีไอคอน):
		# var icon = TextureRect.new()
		# icon.texture = load("res://assets/icons/" + key + ".png")
		# icon.custom_minimum_size = Vector2(24, 24)
		# icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		# order_list.add_child(icon)

func update_patience(current: float, max_val: float):
	if not patience_bar: return
	patience_bar.max_value = max_val
	patience_bar.value = current
	
	var ratio = current / max_val
	patience_bar.modulate = Color.RED if ratio < 0.3 else Color.WHITE
