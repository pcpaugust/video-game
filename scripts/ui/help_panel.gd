extends Control

@onready var close_button: Button = $Card/MarginContainer/VBoxContainer/TitleRow/CloseButton

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		visible = not visible

func _on_close_pressed() -> void:
	hide()
