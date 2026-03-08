extends VBoxContainer
class_name CustomerItem

@onready var type_label: Label = $TopRow/TypeLabel
@onready var name_label: Label = $TopRow/NameLabel
@onready var patience_bar: ProgressBar = $TopRow/PatienceBar
@onready var order_label: Label = $OrderLabel


func update_from_data(
	name: String,
	is_special: bool,
	is_child: bool,
	patience: float,
	max_patience: float,
	orders: Array[String]
) -> void:
	name_label.text = name

	var tag: String = ""
	if is_special:
		tag = "[พิเศษ]"
	elif is_child:
		tag = "[เด็ก]"
	type_label.text = tag

	var ratio: float = 0.0
	if max_patience > 0.0:
		ratio = clamp(patience / max_patience, 0.0, 1.0)
	patience_bar.value = ratio * 100.0

	order_label.text = ", ".join(orders)

