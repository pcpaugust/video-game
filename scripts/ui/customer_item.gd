extends PanelContainer
class_name CustomerItem

@onready var name_label: Label = $MarginContainer/VBoxContainer/TopRow/VBoxContainer/NameLabel
@onready var type_label: Label = $MarginContainer/VBoxContainer/TopRow/TypeLabel
@onready var patience_bar: ProgressBar = $MarginContainer/VBoxContainer/TopRow/VBoxContainer/PatienceBar
@onready var order_icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TopRow2/OrderIcon
@onready var order_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/TopRow2/OrderLabel2

const MENU_ASSETS: Array[String] = [
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Menu/foods/1pancake.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Menu/foods/2omelet.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Menu/foods/3sandwhich.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Menu/foods/4curryrice.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Menu/drinks/1orange.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Menu/drinks/2coffee.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Menu/drinks/3chocolate.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Menu/sweets/1strawberry-chocolate.png",
	"res://assets/PtPt - Cute Pixel Cooking Game Starter Pack/Menu/sweets/4vanilla-chocolate.png",
]

func update_from_data(
	name: String,
	is_special: bool,
	is_child: bool,
	patience: float,
	max_patience: float,
	order_keys: Array
) -> void:
	name_label.text = name
	if is_child:
		type_label.text = "CH"
	elif is_special:
		type_label.text = "SP"
	else:
		type_label.text = "N"

	_update_patience(patience, max_patience)
	order_label.text = ", ".join(order_keys)
	_update_order_icon(order_keys)

func _update_patience(current: float, max_val: float) -> void:
	if not patience_bar:
		return
	patience_bar.max_value = max_val
	patience_bar.value = current

	var ratio := current / max_val if max_val > 0.0 else 0.0
	patience_bar.modulate = Color.RED if ratio < 0.3 else Color.WHITE

func _update_order_icon(order_keys: Array) -> void:
	if order_icon == null:
		return
	if order_keys.is_empty():
		order_icon.texture = null
		return
	var key := String(order_keys[0])
	var path := _pick_asset_path(key, MENU_ASSETS)
	if path != "" and ResourceLoader.exists(path):
		order_icon.texture = load(path)
	else:
		order_icon.texture = null

func _pick_asset_path(key: String, assets: Array[String]) -> String:
	if assets.is_empty():
		return ""
	var acc := 0
	for i in key.length():
		acc += key.unicode_at(i)
	return assets[acc % assets.size()]
