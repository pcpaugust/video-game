extends MarginContainer

const OrderCardScene = preload("res://scenes/ui/customer_item.tscn")

@onready var queue = $OrderQueue

func refresh_all_cards(customers: Array):
	# ลบการ์ดเก่าออกทั้งหมด
	for child in queue.get_children():
		child.queue_free()
	
	# สร้างการ์ดใหม่ตามข้อมูลลูกค้า
	for c in customers:
		var card = OrderCardScene.instantiate()
		
		var wrapper = Control.new()
		wrapper.custom_minimum_size = card.custom_minimum_size
		queue.add_child(wrapper)
		wrapper.add_child(card)
		
		if card.has_method("update_from_data"):
			card.update_from_data(
				c.name,
				c.is_child,
				c.patience,
				c.max_patience,
				c.order_keys
			)
			
		if "is_new" in c and c.is_new:
			card.position.x = 1920
			card.modulate = Color(1, 1, 1, 0)
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(card, "position:x", 0.0, 0.6).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			tween.tween_property(card, "modulate", Color(1, 1, 1, 1), 0.5).set_ease(Tween.EASE_OUT)
			c.is_new = false

func update_patience_only(customers: Array):
	# อัปเดตเฉพาะแถบเวลาโดยไม่ต้องลบโหนดทิ้ง (Performance)
	var wrappers = queue.get_children()
	for i in range(min(wrappers.size(), customers.size())):
		if wrappers[i].get_child_count() > 0:
			var card = wrappers[i].get_child(0)
			if card.has_method("update_patience"):
				card.update_patience(customers[i].patience, customers[i].max_patience)
