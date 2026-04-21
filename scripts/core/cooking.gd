extends Node2D

const MenuData = preload("res://scripts/data/menu_data.gd")
const GameConfig = preload("res://scripts/config/game_config.gd")
const HelpPanelScene = preload("res://scenes/ui/HelpPanel.tscn")
const GameOverScene = preload("res://scenes/ui/GameOver.tscn")
const NextLevelScene = preload("res://scenes/ui/NextLevel.tscn")

enum Mode {
	PREP,
	CLEAR_SLOT,
	SERVE,
	GAME_OVER,
	LEVEL_COMPLETE,
}

class Customer:
	var name: String
	var order_keys: Array[String] = []
	var patience: float = 0.0
	var max_patience: float = 0.0
	var is_child: bool = false
	var is_new: bool = true

var level: int = 1
var score: int = 0
var target_score: int = 40
var customers: Array[Customer] = []
var typing_buffer: String = ""
var current_bowl_ingredients: Array[String] = []
var missed_customers: int = 0
var current_mode: Mode = Mode.PREP
var spawn_timer: float = 0.0

# ระบบชามอาหาร (Dish Slots) จาก game_manager
var dish_slots: Array = [] # เก็บ: { "key": String, "ingredients": Array[String] }
var selected_slot: int = 0

@onready var level_bar = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/LevelBar
@onready var order_queue = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/Order
@onready var typing_space = $CanvasLayer/TypingSpace
@onready var center_bowl = $CanvasLayer/BowlsContainer/CenterBowl
@onready var left_bowl = $CanvasLayer/BowlsContainer/LeftBowl
@onready var right_bowl = $CanvasLayer/BowlsContainer/RightBowl
@onready var left_hand = $CanvasLayer/LeftHand
@onready var right_hand = $CanvasLayer/RightHand

var help_panel: Control = null
var game_over_panel: Control = null
var next_level_panel: Control = null
var _hand_tween: Tween
func _ready() -> void:
	randomize()
	_create_help_panel()
	level = 1
	target_score = 40
	start_level(level, target_score)

func start_level(new_level: int, target: int) -> void:
	level = new_level
	target_score = target
	score = 0
	missed_customers = 0
	customers.clear()
	dish_slots.clear()
	typing_buffer = ""
	current_bowl_ingredients.clear()
	current_mode = Mode.PREP
	level_bar.set_level(new_level, target)
	center_bowl.clear()
	center_bowl.set_state("glow")
	left_bowl.clear()
	right_bowl.clear()
	for i in range(GameConfig.BASE_CUSTOMER_COUNT):
		_spawn_single_customer()
		
	spawn_timer = max(GameConfig.MIN_SPAWN_INTERVAL, GameConfig.SPAWN_INTERVAL_BASE - (level * GameConfig.SPAWN_INTERVAL_DECREASE_PER_LEVEL))
	_update_ui_full()

func _spawn_single_customer() -> void:
	if customers.size() >= GameConfig.MAX_CUSTOMERS: return
	
	var unlocked = MenuData.get_unlocked_ingredients_for_level(level)
	var used_name = []
	for c in customers:
		used_name.append(c.name)
		
	var c = Customer.new()
	c.is_child = randf() < GameConfig.CHILD_CUSTOMER_CHANCE
	
	for i in range(10):
		c.name = MenuData.random_customer_name(c.is_child)
		if not used_name.has(c.name):
			break
			
	c.order_keys = MenuData.build_random_order_keys(unlocked, level)

	var base_time = GameConfig.BASE_PATIENCE_TIME - (level * GameConfig.PATIENCE_TIME_PER_LEVEL)

	if c.is_child:
		base_time += GameConfig.CHILD_PATIENCE_BONUS
		
	c.max_patience = max(base_time, GameConfig.MIN_PATIENCE_TIME)
	c.patience = c.max_patience
	customers.append(c)
	_update_ui_full()

func _process(delta: float) -> void:
	if current_mode == Mode.GAME_OVER or current_mode == Mode.LEVEL_COMPLETE: return
	
	_update_customers_logic(delta)
	order_queue.update_patience_only(customers)
	
	if customers.size() < GameConfig.MAX_CUSTOMERS:
		if customers.is_empty():
			spawn_timer = 0.0
			
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_spawn_single_customer()
			spawn_timer = max(GameConfig.MIN_SPAWN_INTERVAL, GameConfig.SPAWN_INTERVAL_BASE - (level * GameConfig.SPAWN_INTERVAL_DECREASE_PER_LEVEL))

func _update_customers_logic(delta: float) -> void:
	for i in range(customers.size() - 1, -1, -1):
		var c = customers[i]
		c.patience -= delta
		if c.patience <= 0.0:
			customers.remove_at(i)
			missed_customers += 1
				
		# ตรวจสอบเงื่อนไขแพ้เกม
		if missed_customers >= GameConfig.BASE_MISSED_CUSTOMERS + level:
			_handle_game_over()
		_update_ui_full()
		_refresh_completed_bowl_states()

func _unhandled_input(event: InputEvent) -> void:
	if current_mode == Mode.GAME_OVER or current_mode == Mode.LEVEL_COMPLETE: return
	if event is InputEventKey and event.pressed:
		var ev = event as InputEventKey
		match ev.keycode:
			KEY_ENTER: _handle_submit()
			KEY_TAB: _handle_tab()
			KEY_BACKSPACE: _handle_backspace()
			KEY_SPACE: _handle_space()
			_:
				if ev.unicode != 0 and ev.unicode != 32: # Ignore space here since it's handled above
					typing_buffer += char(ev.unicode)
					_sync_typing_visuals()

func _handle_space() -> void:
	if current_mode == Mode.PREP:
		var word = typing_buffer.strip_edges()
		if MenuData.is_valid_ingredient(word):
			current_bowl_ingredients.append(word)
			typing_buffer = ""
			_sync_typing_visuals()
			return
	
	# Default behavior for non-prep modes or invalid words
	typing_buffer += " "
	_sync_typing_visuals()

func _handle_tab() -> void:
	match current_mode:
		Mode.CLEAR_SLOT:
			if dish_slots.size() > 0:
				selected_slot = (selected_slot + 1) % dish_slots.size()
	_update_mode_ui()

func _handle_submit() -> void:
	var cmd = typing_buffer.strip_edges()
	
	if cmd.to_lower() == "clear" and current_mode == Mode.PREP:
		if dish_slots.size() > 0 or current_bowl_ingredients.size() > 0:
			current_mode = Mode.CLEAR_SLOT
			selected_slot = 0
			typing_buffer = ""
			current_bowl_ingredients.clear()
			_sync_typing_visuals()
			_update_mode_ui()
		return

	if current_mode == Mode.CLEAR_SLOT:
		_confirm_clear_slot()
		typing_buffer = ""
		_sync_typing_visuals()
		return

	# Check if cmd is a customer name
	var is_customer = false
	if cmd != "":
		for c in customers:
			if c.name == cmd:
				is_customer = true
				break

	if is_customer:
		_attempt_serve(cmd)
	else:
		_attempt_cook()

	typing_buffer = ""
	_sync_typing_visuals()

# Logic การปรุงอาหารจาก game_manager
func _attempt_cook() -> void:
	var words = typing_buffer.strip_edges().split(" ", false)
	var valid_ingredients: Array[String] = current_bowl_ingredients.duplicate()
	for w in words:
		if MenuData.is_valid_ingredient(w):
			valid_ingredients.append(w)
	
	if valid_ingredients.is_empty(): return

	if dish_slots.size() < GameConfig.MAX_DISH_SLOTS:
		var key = MenuData.canonical_dish_key(valid_ingredients)
		dish_slots.append({"key": key, "ingredients": valid_ingredients})
		_update_dish(dish_slots)
		
		if dish_slots.size() == 1:
			left_bowl.play_complete_animation()
		elif dish_slots.size() == 2:
			right_bowl.play_complete_animation()
			
		print("Cooked: ", key, " ", valid_ingredients)
		current_bowl_ingredients.clear()
		
		if left_bowl.state == "dark" && right_bowl.state == "dark": 
			_handle_game_over()
	else: print("Dish Slot is Full!")

# Logic การเสิร์ฟจาก game_manager
func _attempt_serve(customer_name: String) -> void:
	var target_idx = -1
	for i in range(customers.size()):
		if customers[i].name == customer_name:
			target_idx = i
			break

	if target_idx == -1: return

	var customer = customers[target_idx]
	var served_keys = []
	var remaining_required = customer.order_keys.duplicate()

	# ตรวจสอบอาหารในถุง/ชาม
	for i in range(dish_slots.size() - 1, -1, -1):
		var key = dish_slots[i]["key"]
		var req_idx = remaining_required.find(key)
		if req_idx != -1:
			served_keys.append(key)
			remaining_required.remove_at(req_idx)
			dish_slots.remove_at(i)
			_update_dish(dish_slots)

	if served_keys.size() > 0:
		customer.order_keys = remaining_required
		# 1. คำนวณคะแนนพื้นฐาน
		var current_serve_score = served_keys.size() * GameConfig.BASE_SCORE_PER_DISH
		
		# 2. เพิ่มโบนัสถ้าเสิร์ฟครบออเดอร์
		if remaining_required.is_empty():
			current_serve_score += GameConfig.FULL_ORDER_BONUS
			
		# 3. Apply ตัวคูณตามประเภทลูกค้า
		elif customer.is_child:
			current_serve_score = int(current_serve_score * GameConfig.CHILD_SCORE_MULTIPLIER)
   
		score += current_serve_score
		
		# 4. เพิ่มโบนัสเวลา (Patience) เมื่อเสิร์ฟสำเร็จบางส่วนหรือทั้งหมด
		var time_bonus = served_keys.size() * GameConfig.TIME_BONUS_PER_DISH
		customer.patience = min(customer.patience + time_bonus, customer.max_patience)

		# ถ้าเสิร์ฟครบแล้วให้ลบลูกค้าออก
		if remaining_required.is_empty():
			customers.remove_at(target_idx)

		_update_ui_full()
		_update_score()

func _confirm_clear_slot() -> void:
	if dish_slots.size() > 0:
		dish_slots.remove_at(selected_slot)
	current_mode = Mode.PREP
	_update_mode_ui()

func _handle_backspace() -> void:
	if typing_buffer.length() > 0:
		typing_buffer = typing_buffer.substr(0, typing_buffer.length() - 1)
		_sync_typing_visuals()
	elif current_bowl_ingredients.size() > 0:
		typing_buffer = current_bowl_ingredients.pop_back()
		_sync_typing_visuals()

func _sync_typing_visuals() -> void:
	if typing_space.has_method("update_preview"):
		typing_space.update_preview(typing_buffer)
	_wiggle_hands()
	
	# Parse valid ingredients from the buffer and update center bowl
	var all_ing = current_bowl_ingredients.duplicate()
	var words = typing_buffer.strip_edges().split(" ", false)
	for w in words:
		if MenuData.is_valid_ingredient(w):
			all_ing.append(w)
	center_bowl.set_ingredients(all_ing)
	center_bowl.set_state("glow")

func _wiggle_hands() -> void:
	if not left_hand or not right_hand: return
	if _hand_tween and _hand_tween.is_running():
		return
		
	_hand_tween = create_tween()
	_hand_tween.set_parallel(true)
	
	var l_angle = randf_range(0.05, 0.15) * (1 if randi() % 2 == 0 else -1)
	var r_angle = randf_range(0.05, 0.15) * (1 if randi() % 2 == 0 else -1)
	
	_hand_tween.tween_property(left_hand, "rotation", l_angle, 0.05)
	_hand_tween.tween_property(right_hand, "rotation", r_angle, 0.05)
	
	_hand_tween.chain().tween_property(left_hand, "rotation", 0.0, 0.05)
	_hand_tween.tween_property(right_hand, "rotation", 0.0, 0.05)

func _update_mode_ui() -> void:
	var text = ""
	match current_mode:
		Mode.PREP: text = "🔤 พิมพ์วัตถุดิบเพื่อปรุง หรือ พิมพ์ชื่อลูกค้าเพื่อเสิร์ฟ"
		Mode.SERVE: text = "🔤 พิมพ์วัตถุดิบเพื่อปรุง หรือ พิมพ์ชื่อลูกค้าเพื่อเสิร์ฟ"
		Mode.CLEAR_SLOT: text = "🗑️ โหมดทิ้ง: กด [TAB] เลือกจาน จากนั้น [Enter] ยืนยัน"
		Mode.GAME_OVER: text = "เกมจบแล้ว!"
		Mode.LEVEL_COMPLETE: text = "ผ่านด่านแล้ว!"
	typing_space.update_mode(text)

func _update_score() -> void:
	if score >= target_score and current_mode != Mode.LEVEL_COMPLETE:
		print("Finished! Level Complete Screen Started!")
		_handle_level_complete()
		
	level_bar.update_progress(score)

func _update_dish(dish: Array) -> void:
	if dish.size() > 0:
		left_bowl.set_ingredients(dish[0]["ingredients"])
		_update_bowl_state(left_bowl, dish[0]["key"])
	else:
		left_bowl.clear()
		
	if dish.size() > 1:
		right_bowl.set_ingredients(dish[1]["ingredients"])
		_update_bowl_state(right_bowl, dish[1]["key"])
	else:
		right_bowl.clear()

func _refresh_completed_bowl_states() -> void:
	if dish_slots.size() > 0:
		_update_bowl_state(left_bowl, dish_slots[0]["key"])
	if dish_slots.size() > 1:
		_update_bowl_state(right_bowl, dish_slots[1]["key"])

func _update_bowl_state(bowl: Control, key: String) -> void:
	var has_match = false
	for c in customers:
		if key in c.order_keys:
			has_match = true
			break
			
	if has_match:
		bowl.set_state("match")
	else:
		bowl.set_state("dark")

func _update_ui_full() -> void:
	order_queue.refresh_all_cards(customers)
	_update_dish(dish_slots)
	_update_mode_ui()

func _handle_game_over() -> void:
	print("Game Over!")
	current_mode = Mode.GAME_OVER
	_update_mode_ui()
	
	if not game_over_panel:
		game_over_panel = GameOverScene.instantiate()
		$CanvasLayer.add_child(game_over_panel)
		game_over_panel.restart_requested.connect(_on_restart_requested)
	
	game_over_panel.set_stats(score, level)
	game_over_panel.show()
	game_over_panel.set_process_unhandled_input(true)

func _on_restart_requested() -> void:
	if game_over_panel:
		game_over_panel.hide()
	
	print("Restarting...")
	start_level(1, 40)

func _handle_level_complete() -> void:
	current_mode = Mode.LEVEL_COMPLETE
	_update_mode_ui()
	
	if not next_level_panel:
		next_level_panel = NextLevelScene.instantiate()
		$CanvasLayer.add_child(next_level_panel)
		next_level_panel.continue_requested.connect(_on_continue_requested)
	
	next_level_panel.set_stats(level)
	next_level_panel.show()
	next_level_panel.set_process_unhandled_input(true)

func _on_continue_requested() -> void:
	if next_level_panel:
		next_level_panel.hide()
	
	var new_level = level + 1
	var new_target = target_score + 40 + (level * 20)
	start_level(new_level, new_target)

func _create_help_panel() -> void:
	# Create and show help panel at startup
	help_panel = HelpPanelScene.instantiate()
	add_child(help_panel)
