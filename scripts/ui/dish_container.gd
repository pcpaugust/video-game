# dish_container.gd
extends PanelContainer

@onready var container = $MarginContainer/VBoxContainer/List

func update_list(dish_array: Array):
	if not is_node_ready():
		await ready
	
	for child in container.get_children():
		child.queue_free()
	
	for i in range(dish_array.size()):
		var dish_data = dish_array[i] # ข้อมูลแต่ละจาน
		var label = Label.new()
		
		var dish_name = dish_data.get("key", "Unknown").capitalize()
		
		label.text = str(i+1) + ". " + dish_name
		container.add_child(label)
