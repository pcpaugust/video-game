extends Control

func _ready():
	# Make the StartLabel blink!
	var tween = create_tween().set_loops()
	tween.tween_property($StartLabel, "modulate:a", 0.2, 0.8)
	tween.tween_property($StartLabel, "modulate:a", 1.0, 0.8)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			get_tree().change_scene_to_file("res://scenes/main/Cooking.tscn")
