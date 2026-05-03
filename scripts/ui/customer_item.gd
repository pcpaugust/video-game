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
@onready var order_list: VBoxContainer = $MarginContainer/VBoxContainer/OrderList
@onready var orders_text: Label = $MarginContainer/VBoxContainer/OrdersText

const IngredientItemScene = preload("res://scenes/ui/IngredientItem.tscn")

const FACE_ANGRY: Texture2D = preload("res://assets/artwork/customer/angry.png")
const FACE_MEH: Texture2D = preload("res://assets/artwork/customer/meh.png")
const FACE_HAPPY: Texture2D = preload("res://assets/artwork/customer/happy.png")

var style_normal: StyleBoxFlat
var style_ready: StyleBoxFlat

func _ready() -> void:
	_ensure_card_styles()

func update_from_data(
	name: String,
	is_child: bool,
	patience: float,
	max_patience: float,
	order_keys: Array,
	can_serve: bool = false
) -> void:
	_ensure_card_styles()
	name_label.text = name

	_update_patience(patience, max_patience)
	_update_orders(order_keys)
	_update_serve_affordance(can_serve)

func _update_patience(current: float, max_val: float) -> void:
	if not patience_bar:
		return
	patience_bar.max_value = max_val
	patience_bar.value = current
	face_icon.texture = FACE_HAPPY
	if current <= 0.5 * max_val:
		face_icon.texture = FACE_MEH
	if current <= 0.2 * max_val:
		face_icon.texture = FACE_ANGRY

func update_patience(current: float, max_val: float) -> void:
	_update_patience(current, max_val)

func _update_serve_affordance(can_serve: bool) -> void:
	if can_serve:
		add_theme_stylebox_override("panel", style_ready)
	else:
		add_theme_stylebox_override("panel", style_normal)

func _ensure_card_styles() -> void:
	if style_normal != null:
		return

	style_normal = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style_ready = style_normal.duplicate() as StyleBoxFlat
	style_ready.bg_color = Color(0.941176, 1.0, 0.878431, 0.98)
	style_ready.border_width_left = 4
	style_ready.border_width_top = 4
	style_ready.border_width_right = 4
	style_ready.border_width_bottom = 4
	style_ready.border_color = Color(0.262745, 0.760784, 0.337255, 1)

func _update_orders(order_keys: Array) -> void:
	if orders_text:
		orders_text.text = ", ".join(order_keys)
	_clear_order_list()
	for order_idx in range(order_keys.size()):
		var ing = str(order_keys[order_idx]).split(" ", false)
		for i in ing:
			var item = IngredientItemScene.instantiate()
			order_list.add_child(item)
			item.call_deferred("setup", i)

		if order_idx < order_keys.size() - 1:
			order_list.add_child(_make_order_separator())

func _clear_order_list() -> void:
	for child in order_list.get_children():
		child.queue_free()

func _make_order_separator() -> ColorRect:
	var separator := ColorRect.new()
	separator.custom_minimum_size = Vector2(0, 2)
	separator.color = Color(0.439216, 0.415686, 0.415686, 0.35)
	return separator

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
