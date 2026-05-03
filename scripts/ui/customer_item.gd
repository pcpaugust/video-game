extends PanelContainer
class_name CustomerItem

const BASE_CARD_SIZE := Vector2(320, 430)
const ORDER_COLUMN_WIDTH := 280.0
const ORDER_COLUMN_SEPARATION := 12.0
const CARD_HORIZONTAL_MARGIN := 20.0
const COLUMN_INNER_MARGIN := 8

@onready var face_icon: TextureRect = $MarginContainer/VBoxContainer/HeaderRow/FaceIcon
@onready var name_label: Label = $MarginContainer/VBoxContainer/HeaderRow/NameColumn/NameLabel
@onready var patience_bar: ProgressBar = $MarginContainer/VBoxContainer/HeaderRow/NameColumn/PatienceBar
@onready var order_list: HBoxContainer = $MarginContainer/VBoxContainer/OrderList
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
	_resize_for_order_count(order_keys.size())
	_clear_order_list()
	for order_idx in range(order_keys.size()):
		var column_panel := _make_order_column_panel()
		var column := _make_order_column_content(column_panel)
		order_list.add_child(column_panel)

		var ingredients = str(order_keys[order_idx]).split(" ", false)
		for ing in ingredients:
			var item = IngredientItemScene.instantiate()
			column.add_child(item)
			item.call_deferred("setup", ing)

func _resize_for_order_count(order_count: int) -> void:
	var safe_count = max(order_count, 1)
	var order_width = (
		CARD_HORIZONTAL_MARGIN
		+ safe_count * ORDER_COLUMN_WIDTH
		+ max(safe_count - 1, 0) * ORDER_COLUMN_SEPARATION
	)
	custom_minimum_size = Vector2(
		max(BASE_CARD_SIZE.x, order_width),
		BASE_CARD_SIZE.y
	)

func _make_order_column_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(ORDER_COLUMN_WIDTH, 0)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	panel.add_theme_stylebox_override("panel", _make_order_column_style())
	return panel

func _make_order_column_content(panel: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", COLUMN_INNER_MARGIN)
	margin.add_theme_constant_override("margin_top", COLUMN_INNER_MARGIN)
	margin.add_theme_constant_override("margin_right", COLUMN_INNER_MARGIN)
	margin.add_theme_constant_override("margin_bottom", COLUMN_INNER_MARGIN)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	margin.add_child(column)
	return column

func _make_order_column_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.18)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	return style

func _clear_order_list() -> void:
	for child in order_list.get_children():
		child.queue_free()
