extends Resource
class_name MenuConfig

# Ingredient lists
const BROTH_TYPES: Array[String] = [
	"แห้ง",    # dry (no soup)
	"น้ำใส",
	"น้ำข้น",
	"ต้มยำ",
	"เย็นตาโฟ",
]

const NOODLE_TYPES: Array[String] = [
	"เส้นเล็ก",
	"เส้นหมี่",
	"วุ้นเส้น",
	"บะหมี่",
	"เส้นใหญ่",
]

const MEAT_TYPES: Array[String] = [
	"ลูกชิ้น",
	"เนื้อตุ๋น",
	"หมูเด้ง",
	"น่องไก่",
]

const VEGETABLE_TYPES: Array[String] = [
	"ต้นหอมผักชี",
	"ถั่วงอก",
	"กระเทียมเจียว",
]

const DRINK_TYPES: Array[String] = [
	"โอเลี้ยง",
	"กระเจี๊ยบ",
	"เก๊กฮวย",
]

const INGREDIENT_TEXTURES: Dictionary = {
	"เส้นเล็ก": preload("res://assets/artwork/menu/nood02.png"),
	"เส้นหมี่": preload("res://assets/artwork/menu/nood04.png"),
	"วุ้นเส้น": preload("res://assets/artwork/menu/nood03.png"),
	"บะหมี่": preload("res://assets/artwork/menu/nood01.png"),
	"เส้นใหญ่": preload("res://assets/artwork/menu/nood05.png"),
	"ลูกชิ้น": preload("res://assets/artwork/menu/meat01.png"),
	"เนื้อตุ๋น": preload("res://assets/artwork/menu/meat02.png"),
	"หมูเด้ง": preload("res://assets/artwork/menu/meat04.png"),
	"น่องไก่": preload("res://assets/artwork/menu/meat05.png"),
	"กระเทียมเจียว": preload("res://assets/artwork/menu/veg02.png"),
	"ถั่วงอก": preload("res://assets/artwork/menu/veg03.png"),
	"ต้นหอมผักชี": preload("res://assets/artwork/menu/veg01.png"),
	"โอเลี้ยง": preload("res://assets/artwork/menu/drink02.png"),
	"กระเจี๊ยบ": preload("res://assets/artwork/menu/drink01.png"),
	"เก๊กฮวย": preload("res://assets/artwork/menu/drink03.png"),
}

# Customer name pools
const NORMAL_CUSTOMER_NAMES: Array[String] = [
	"พี่ต่อ",
	"ป้าแป้ง",
	"ลุงหมู",
	"พี่นิด",
	"พี่เมย์",
	"พี่ต้น",
	"น้าเจี๊ยบ",
	"ลุงสมชาย",
	"พี่เก่ง",
	"พี่แนน",
	"น้าแดง",
	"พี่อาร์ต",
	"ป้าจิก",
	"น้าจอย",
	"ป้าต้อย",
	"พี่เก่ง",
	"พี่แนน",
	"ลุงสมชาย",
	"น้าแดง",
	"พี่อาร์ต",
	"ป้ามะลิ",
	"พี่บอย",
	"น้าเชียร",
	"พี่กุ้ง",
	"ลุงหวัง",
	"ป้าจิก",
	"พี่หนุ่ม"
]

const CHILD_CUSTOMER_NAMES: Array[String] = [
	"น้องออม",
	"น้องปั้นแป้ง",
	"น้องฟีฟี",
	"น้องค็อกเทล",
	"น้องหมูเด้ง", 
	"น้องกอหญ้า",
	"น้องพาสต้า",
	"น้องออกัส",
	"น้องเมล่อน",
	"น้องตะวัน",
	"น้องเพนกวิน"
]
