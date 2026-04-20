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
		queue.add_child(card)
		if card.has_method("update_from_data"):
			card.update_from_data(
				c.name,
				c.is_special,
				c.is_child,
				c.patience,
				c.max_patience,
				c.order_keys
			)

func update_patience_only(customers: Array):
	# อัปเดตเฉพาะแถบเวลาโดยไม่ต้องลบโหนดทิ้ง (Performance)
	var cards = queue.get_children()
	for i in range(min(cards.size(), customers.size())):
		if cards[i].has_method("update_patience"):
			cards[i].update_patience(customers[i].patience, customers[i].max_patience)
