extends Node

const CookingScene = preload("res://scenes/main/Cooking.tscn")

var game: Node = null

func _ready() -> void:
	game = CookingScene.instantiate()
	add_child(game)
	await get_tree().process_frame
	await get_tree().process_frame
	if game.help_panel:
		game.help_panel.hide()
	await get_tree().create_timer(0.8).timeout
	await _serve_first_customer()
	await get_tree().create_timer(0.6).timeout
	await _serve_first_customer()
	await get_tree().create_timer(2.2).timeout
	get_tree().quit()

func _serve_first_customer() -> void:
	if game.customers.is_empty():
		return
	var customer = game.customers[0]
	if customer.order_keys.is_empty():
		return
	var dish_text = customer.order_keys[0]
	await _type_text(dish_text, 0.045)
	await get_tree().create_timer(0.25).timeout
	game._handle_submit()
	await get_tree().create_timer(0.75).timeout
	await _type_text(customer.name, 0.075)
	await get_tree().create_timer(0.2).timeout
	game._handle_submit()

func _type_text(text: String, delay: float) -> void:
	game.typing_buffer = ""
	game._sync_typing_visuals()
	for i in range(text.length()):
		game.typing_buffer += text.substr(i, 1)
		game._sync_typing_visuals()
		await get_tree().create_timer(delay).timeout
