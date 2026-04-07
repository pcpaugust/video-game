# dish_container.gd
extends PanelContainer

@onready var container = $MarginContainer/VBoxContainer/List

func update_list(dish_array: Array):
	if not is_node_ready():
		await ready
	
	for child in container.get_children():
		child.queue_free()

	if dish_array.is_empty():
		var empty_label := Label.new()
		empty_label.text = "ยังไม่มี"
		empty_label.modulate = Color(0.439216, 0.415686, 0.415686, 0.65)
		empty_label.add_theme_font_size_override("font_size", 11)
		container.add_child(empty_label)
		return
	
	for i in range(dish_array.size()):
		var dish_data = dish_array[i] # ข้อมูลแต่ละจาน
		var dish_name = dish_data.get("key", "Unknown").capitalize()

		var chip := PanelContainer.new()
		var chip_style := StyleBoxFlat.new()
		chip_style.bg_color = Color(1, 0.933333, 0.764706, 1)
		chip_style.border_width_left = 1
		chip_style.border_width_top = 1
		chip_style.border_width_right = 1
		chip_style.border_width_bottom = 1
		chip_style.border_color = Color(0.439216, 0.415686, 0.415686, 0.65)
		chip_style.corner_radius_top_left = 8
		chip_style.corner_radius_top_right = 8
		chip_style.corner_radius_bottom_right = 8
		chip_style.corner_radius_bottom_left = 8
		chip_style.content_margin_left = 6
		chip_style.content_margin_right = 6
		chip_style.content_margin_top = 2
		chip_style.content_margin_bottom = 2
		chip.add_theme_stylebox_override("panel", chip_style)

		var label := Label.new()
		label.text = str(i + 1) + ". " + dish_name
		label.add_theme_font_size_override("font_size", 11)
		label.add_theme_color_override("font_color", Color(0.439216, 0.415686, 0.415686, 1))

		chip.add_child(label)
		container.add_child(chip)
