extends PanelContainer
class_name OrderCard

@onready var type_label: Label = $MarginContainer/VBoxContainer/TopRow/TypeLabel
@onready var name_label: Label = $MarginContainer/VBoxContainer/TopRow/VBoxContainer/NameLabel
@onready var patience_bar: ProgressBar = $MarginContainer/VBoxContainer/TopRow/VBoxContainer/PatienceBar
@onready var order_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TopRow2/OrderLabel2


func update_from_data(
	name: String,
	is_special: bool,
	is_child: bool,
	patience: float,
	max_patience: float,
	orders: Array[String]
) -> void:
	# 1. แสดงชื่อลูกค้า
	name_label.text = name
	
	# 2. จัดการ Tag
	var tag: String = ""
	if is_special:
		tag = "[พิเศษ]"
	elif is_child:
		tag = "[เด็ก]"
	type_label.text = tag
	
	# 3. คำนวณหลอดความอดทน (Patience)
	var ratio: float = 0.0
	if max_patience > 0.0:
		ratio = clamp(patience / max_patience, 0.0, 1.0)
	
	# แก้ไขตรงนี้: ProgressBar ของ Godot ปกติใช้ค่า 0-100
	patience_bar.value = ratio * 100 
	
	# 4. แสดงรายการออเดอร์
	order_label.text = ", ".join(orders)
