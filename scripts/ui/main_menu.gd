extends Control

@onready var start_sound: AudioStreamPlayer = $StartSound

var _starting_game := false

func _ready():
	# Make the StartLabel blink!
	var tween = create_tween().set_loops()
	tween.tween_property($StartLabel, "modulate:a", 0.2, 0.8)
	tween.tween_property($StartLabel, "modulate:a", 1.0, 0.8)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if not _starting_game and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
			_starting_game = true
			if start_sound and start_sound.stream:
				start_sound.play()
				await start_sound.finished
			get_tree().change_scene_to_file("res://scenes/main/Cooking.tscn")
