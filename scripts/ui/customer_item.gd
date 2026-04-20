extends PanelContainer
class_name CustomerItem

const ORDER_COLORS: Array[Color] = [
	Color(0.972549, 0.913725, 0.643137, 1),
	Color(0.976471, 0.556863, 0.235294, 1),
	Color(0.262745, 0.760784, 0.337255, 1),
	Color(0.294118, 0.376471, 0.941176, 1),
	Color(0.992157, 0.666667, 0.741176, 1),
	Color(0.67451, 0.564706, 0.956863, 1),
]

@onready var face_icon: TextureRect = $MarginContainer/VBoxContainer/HeaderRow/FaceIcon
@onready var name_label: Label = $MarginContainer/VBoxContainer/HeaderRow/NameColumn/NameLabel
@onready var patience_bar: ProgressBar = $MarginContainer/VBoxContainer/HeaderRow/NameColumn/PatienceBar
@onready var box_a: PanelContainer = $MarginContainer/VBoxContainer/OrdersRow/OrderBoxA
@onready var box_b: PanelContainer = $MarginContainer/VBoxContainer/OrdersRow/OrderBoxB
@onready var grid_a: GridContainer = $MarginContainer/VBoxContainer/OrdersRow/OrderBoxA/BoxAContent
@onready var grid_b: GridContainer = $MarginContainer/VBoxContainer/OrdersRow/OrderBoxB/BoxBContent
@onready var item_template: PanelContainer = $MarginContainer/VBoxContainer/OrdersRow/OrderBoxA/BoxAContent/ItemTemplate
@onready var orders_text: Label = $MarginContainer/VBoxContainer/OrdersText

const FACE_ANGY: Texture2D = preload("res://assets/figma/face_angy.svg")
const FACE_HAPPY: Texture2D = preload("res://assets/figma/face_happy.svg")
const INGREDIENT_TEXTURES = MenuConfig.INGREDIENT_TEXTURES

func update_from_data(
	name: String,
	is_special: bool,
	is_child: bool,
	patience: float,
	max_patience: float,
	order_keys: Array
) -> void:
	name_label.text = name
	face_icon.texture = FACE_HAPPY if (is_special or is_child) else FACE_ANGY

	_update_patience(patience, max_patience)
	_update_orders(order_keys)

func _update_patience(current: float, max_val: float) -> void:
	if not patience_bar:
		return
	patience_bar.max_value = max_val
	patience_bar.value = current

	var ratio: float = current / max_val if max_val > 0.0 else 0.0
	patience_bar.modulate = Color(0.262745, 0.760784, 0.337255) if ratio >= 0.3 else Color(0.87451, 0.337255, 0.25098)

func update_patience(current: float, max_val: float) -> void:
	_update_patience(current, max_val)

func _update_orders(order_keys: Array) -> void:
	if grid_a == null or grid_b == null:
		return

	_clear_grid(grid_a)
	_clear_grid(grid_b)

	var first_box_count: int = min(order_keys.size(), 4)
	for i in range(first_box_count):
		grid_a.add_child(_make_item(order_keys[i]))

	for i in range(first_box_count, order_keys.size()):
		grid_b.add_child(_make_item(order_keys[i]))

	if orders_text:
		orders_text.text = ", ".join(order_keys)

func _clear_grid(grid: GridContainer) -> void:
	for child in grid.get_children():
		if child == item_template:
			continue
		child.queue_free()

func _make_item(order_key: String = "") -> PanelContainer:
	var item: PanelContainer = item_template.duplicate() as PanelContainer
	item.visible = true
	item.tooltip_text = order_key

	var style := StyleBoxFlat.new()
	var color_idx: int = 0
	if order_key != "":
		var order_hash: int = int(order_key.hash())
		color_idx = abs(order_hash) % ORDER_COLORS.size()
	style.bg_color = ORDER_COLORS[color_idx]
	style.corner_radius_top_left = 999
	style.corner_radius_top_right = 999
	style.corner_radius_bottom_right = 999
	style.corner_radius_bottom_left = 999
	item.add_theme_stylebox_override("panel", style)

	return item
