extends ScrollContainer

const OrderCardScene = preload("res://scenes/ui/OrderCard.tscn")

@onready var queue = $OrderQueue

func refresh_all_cards(customers: Array):
	# ลบการ์ดเก่าออกทั้งหมด
	for child in queue.get_children():
		child.queue_free()
	
	# สร้างการ์ดใหม่ตามข้อมูลลูกค้า
	for c in customers:
		var card = OrderCardScene.instantiate()
		queue.add_child(card)
		card.setup(c)

func update_patience_only(customers: Array):
	# อัปเดตเฉพาะแถบเวลาโดยไม่ต้องลบโหนดทิ้ง (Performance)
	var cards = queue.get_children()
	for i in range(min(cards.size(), customers.size())):
		cards[i].update_patience(customers[i].patience, customers[i].max_patience)
