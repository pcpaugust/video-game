extends Node2D

const MenuData = preload("res://scripts/data/menu_data.gd")
const GameConfig = preload("res://scripts/config/game_config.gd")

class Customer:
	var name: String
	var order_keys: Array[String] = []
	var patience: float = 0.0
	var max_patience: float = 0.0
	var is_special: bool = false
	var is_child: bool = false


enum Mode {
	PREP,
	CLEAR_SLOT,
	SERVE,
}

var level: int = 1
var score: int = 0

var customers: Array[Customer] = []

var typing_buffer: String = ""
var current_mode: Mode = Mode.PREP

var dish_slots: Array = [] # Each: { "key": String, "ingredients": Array[String] }
var selected_slot: int = 0

var missed_customers: int = 0

@onready var level_label: Label = $CanvasLayer/Root/MainVBox/TopBar/LevelLabel
@onready var score_label: Label = $CanvasLayer/Root/MainVBox/TopBar/ScoreLabel
@onready var mode_label: Label = $CanvasLayer/Root/MainVBox/Bottom/TypingPanel/ModeLabel
@onready var input_label: Label = $CanvasLayer/Root/MainVBox/Bottom/TypingPanel/InputLabel
@onready var dish_slots_label: Label = $CanvasLayer/Root/MainVBox/Middle/CookArea/DishSlotsLabel
@onready var customers_label: Label = $CanvasLayer/Root/MainVBox/Middle/CustomerArea/CustomersLabel
@onready var hint_label: Label = $CanvasLayer/Root/MainVBox/Bottom/TypingPanel/HintLabel


func _ready() -> void:
	randomize()
	start_level(1)


func start_level(new_level: int) -> void:
	level = new_level
	score = 0
	missed_customers = 0
	customers.clear()
	dish_slots.clear()
	typing_buffer = ""
	current_mode = Mode.PREP
	selected_slot = 0

	_spawn_initial_customers()
	_update_ui()


func _spawn_initial_customers() -> void:
	var unlocked: Array[String] = MenuData.get_unlocked_ingredients_for_level(level)

	var count: int = clamp(
		GameConfig.BASE_CUSTOMER_COUNT + level,
		GameConfig.BASE_CUSTOMER_COUNT,
		GameConfig.MAX_CUSTOMERS
	)
	for i in range(count):
		var c: Customer = Customer.new()
		c.is_child = randf() < GameConfig.CHILD_CUSTOMER_CHANCE
		c.is_special = randf() < GameConfig.SPECIAL_CUSTOMER_CHANCE
		c.name = MenuData.random_customer_name(c.is_special, c.is_child)
		c.order_keys = MenuData.build_random_order_keys(unlocked, level)

		var base_time: float = (
			GameConfig.BASE_PATIENCE_TIME
			- float(level) * GameConfig.PATIENCE_TIME_PER_LEVEL
		)
		if c.is_child:
			base_time += GameConfig.CHILD_PATIENCE_BONUS
		if c.is_special:
			base_time -= GameConfig.SPECIAL_PATIENCE_PENALTY

		c.max_patience = max(base_time, GameConfig.MIN_PATIENCE_TIME)
		c.patience = c.max_patience
		customers.append(c)


func _process(delta: float) -> void:
	_update_customers(delta)
	_update_ui()


func _update_customers(delta: float) -> void:
	for i in range(customers.size() - 1, -1, -1):
		var c: Customer = customers[i]
		c.patience -= delta
		if c.patience <= 0.0:
			customers.remove_at(i)
			missed_customers += 1

	if customers.is_empty():
		# Simple win condition for now: clear all customers.
		start_level(level + 1)
	elif missed_customers >= GameConfig.MAX_MISSED_CUSTOMERS:
		# Simple lose condition: too many walked away.
		start_level(1)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var ev := event as InputEventKey

		match ev.keycode:
			KEY_TAB:
				_handle_tab()
				get_viewport().set_input_as_handled()
				return
			KEY_ENTER, KEY_KP_ENTER:
				_handle_enter()
				get_viewport().set_input_as_handled()
				return
			KEY_ESCAPE:
				if current_mode != Mode.PREP:
					current_mode = Mode.PREP
					typing_buffer = ""
					_update_ui()
					get_viewport().set_input_as_handled()
				return
			KEY_BACKSPACE:
				if typing_buffer.length() > 0:
					typing_buffer = typing_buffer.substr(0, typing_buffer.length() - 1)
					_update_ui()
				return

		# For other keys, append unicode text into buffer.
		if ev.unicode != 0:
			var ch := char(ev.unicode)
			typing_buffer += ch
			_update_ui()


func _handle_tab() -> void:
	match current_mode:
		Mode.PREP:
			# Switch to serve mode directly.
			current_mode = Mode.SERVE
		Mode.SERVE:
			# Go back to prep mode.
			current_mode = Mode.PREP
		Mode.CLEAR_SLOT:
			# Cycle through dish slots while in clear mode.
			if dish_slots.size() > 0:
				selected_slot = (selected_slot + 1) % dish_slots.size()
	_update_ui()


func _handle_enter() -> void:
	match current_mode:
		Mode.PREP:
			var cmd: String = typing_buffer.strip_edges()
			if cmd == "":
				return
			if cmd.to_lower() == "clear":
				if dish_slots.size() > 0:
					current_mode = Mode.CLEAR_SLOT
					selected_slot = 0
					typing_buffer = ""
					_update_ui()
				else:
					typing_buffer = ""
					_update_ui()
				return

			_attempt_cook_current_buffer()
			return

		Mode.CLEAR_SLOT:
			if dish_slots.size() > 0 and selected_slot >= 0 and selected_slot < dish_slots.size():
				dish_slots.remove_at(selected_slot)
				if dish_slots.size() == 0:
					selected_slot = 0
				else:
					selected_slot = clamp(selected_slot, 0, dish_slots.size() - 1)
			current_mode = Mode.PREP
			typing_buffer = ""
			_update_ui()
			return

		Mode.SERVE:
			_attempt_serve_current_buffer()
			return


func _attempt_cook_current_buffer() -> void:
	var raw := typing_buffer.strip_edges()
	if raw == "":
		return

	var tokens: Array[String] = []
	for part in raw.split(" ", false):
		var token := String(part).strip_edges()
		if token == "":
			continue
		tokens.append(token)

	if tokens.is_empty():
		typing_buffer = ""
		_update_ui()
		return

	var valid_ingredients: Array[String] = []
	var invalid_count: int = 0
	for t in tokens:
		if MenuData.is_valid_ingredient(t):
			valid_ingredients.append(t)
		else:
			invalid_count += 1

	if valid_ingredients.is_empty():
		# All invalid -> pure waste, just clear.
		typing_buffer = ""
		_update_ui()
		return

	var key := MenuData.canonical_dish_key(valid_ingredients)

	if dish_slots.size() < GameConfig.MAX_DISH_SLOTS:
		dish_slots.append({
			"key": key,
			"ingredients": valid_ingredients.duplicate(),
		})

	# Optional: you could track waste/penalty if invalid_count > 0.

	typing_buffer = ""
	_update_ui()


func _attempt_serve_current_buffer() -> void:
	var customer_name := typing_buffer.strip_edges()
	if customer_name == "":
		return

	var target_index: int = -1
	for i in range(customers.size()):
		var c: Customer = customers[i]
		if c.name == customer_name:
			target_index = i
			break

	if target_index == -1:
		# No matching customer.
		typing_buffer = ""
		_update_ui()
		return

	var customer: Customer = customers[target_index]

	var served_keys: Array[String] = []
	var remaining_required: Array[String] = customer.order_keys.duplicate()

	for slot_idx in range(dish_slots.size()):
		var dish = dish_slots[slot_idx]
		var key: String = dish["key"]

		var required_index := remaining_required.find(key)
		if required_index != -1:
			served_keys.append(key)
			remaining_required.remove_at(required_index)

	# Remove dishes that were served from slots.
	if served_keys.size() > 0:
		for i in range(dish_slots.size() - 1, -1, -1):
			var d = dish_slots[i]
			if served_keys.has(d["key"]):
				dish_slots.remove_at(i)

		# Add a little extra time for partial serves.
		var bonus: float = (
			float(served_keys.size()) * GameConfig.TIME_BONUS_PER_DISH
		)
		customer.patience = min(customer.patience + bonus, customer.max_patience)

		# Score reward, more if full order and/or special.
		var base_score: int = (
			GameConfig.BASE_SCORE_PER_DISH * served_keys.size()
		)
		if remaining_required.is_empty():
			base_score += GameConfig.FULL_ORDER_BONUS
		if customer.is_special:
			base_score = int(
				float(base_score) * GameConfig.SPECIAL_SCORE_MULTIPLIER
			)
		if customer.is_child:
			base_score = int(
				float(base_score) * GameConfig.CHILD_SCORE_MULTIPLIER
			)

		score += base_score

		# If fully completed, remove customer.
		if remaining_required.is_empty():
			customers.remove_at(target_index)

	typing_buffer = ""
	_update_ui()


func _build_mode_text() -> String:
	match current_mode:
		Mode.PREP:
			return "โหมด: ปรุง (พิมพ์วัตถุดิบ เว้นวรรค แล้วกด Enter)"
		Mode.CLEAR_SLOT:
			return "โหมด: เคลียร์ชาม (กด Tab เลือกช่อง แล้ว Enter ทิ้ง)"
		Mode.SERVE:
			return "โหมด: เสิร์ฟ (พิมพ์ชื่อลูกค้า แล้วกด Enter)"
	return ""


func _build_dish_slots_text() -> String:
	if dish_slots.is_empty():
		return "ชามที่พัก: (ว่าง)"

	var lines: Array[String] = []
	for i in range(dish_slots.size()):
		var dish = dish_slots[i]
		var ing: Array[String] = dish["ingredients"]
		var prefix := ""
		if current_mode == Mode.CLEAR_SLOT and i == selected_slot:
			prefix = "> "
		else:
			prefix = "  "
		lines.append("%s[%d] %s" % [prefix, i + 1, " ".join(ing)])
	return "\n".join(lines)


func _build_customers_text() -> String:
	if customers.is_empty():
		return "ลูกค้า: ไม่มี (ถ้าจบด่านจะไปด่านถัดไปอัตโนมัติ)"

	var lines: Array[String] = []
	for c in customers:
		var type_label: String = ""
		if c.is_special:
			type_label = "[พิเศษ] "
		elif c.is_child:
			type_label = "[เด็ก] "

		var patience_ratio: float = c.patience / max(c.max_patience, 0.01)
		var patience_bar_len := 10
		var filled := int(round(patience_ratio * patience_bar_len))
		var bar := ""
		for i in range(patience_bar_len):
			bar += "#" if i < filled else "-"

		lines.append(
			"%s%s | รอ: [%s] | เมนู: %s" % [
				type_label,
				c.name,
				bar,
				", ".join(c.order_keys),
			]
		)
	return "\n".join(lines)


func _update_ui() -> void:
	if not is_inside_tree():
		return

	level_label.text = "ด่าน: %d" % level
	score_label.text = "คะแนน: %d (ลูกค้าที่หนี: %d/%d)" % [
		score,
		missed_customers,
		GameConfig.MAX_MISSED_CUSTOMERS,
	]
	mode_label.text = _build_mode_text()
	input_label.text = "กำลังพิมพ์: %s" % typing_buffer
	dish_slots_label.text = _build_dish_slots_text()
	customers_label.text = _build_customers_text()

	hint_label.text = (
		"วิธีเล่น:\n"
		+ "- พิมพ์ชื่อวัตถุดิบคั่นด้วยช่องว่าง แล้วกด Enter เพื่อปรุงชาม\n"
		+ "- พิมพ์ \"clear\" แล้ว Enter -> กด Tab เลือกชาม -> Enter เพื่อทิ้ง\n"
		+ "- กด Tab เพื่อสลับไปโหมดเสิร์ฟ / กลับโหมดปรุง\n"
		+ "- ในโหมดเสิร์ฟ พิมพ์ชื่อลูกค้าแล้ว Enter เพื่อลองเสิร์ฟ"
	)

