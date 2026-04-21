extends Control

signal continue_requested

@onready var title_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DescLabel

func set_stats(level: int) -> void:
	if title_label:
		title_label.text = "ผ่านด่าน " + str(level) + " แล้ว!"
	if desc_label:
		desc_label.text = "เตรียมตัวสำหรับด่าน " + str(level + 1) + "!"

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event is InputEventKey and event.pressed:
		var ev = event as InputEventKey
		if ev.keycode == KEY_SPACE or ev.keycode == KEY_ENTER:
			set_process_unhandled_input(false)
			continue_requested.emit()
