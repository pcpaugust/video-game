extends Control

signal restart_requested

@onready var score_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScoreLabel
@onready var level_label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LevelLabel

func set_stats(score: int, level: int) -> void:
	if score_label:
		score_label.text = "คะแนนที่ทำได้: " + str(score)
	if level_label:
		level_label.text = "ผ่านถึงด่าน: " + str(level)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event is InputEventKey and event.pressed:
		var ev = event as InputEventKey
		if ev.keycode == KEY_SPACE or ev.keycode == KEY_ENTER:
			# Prevent multiple emits
			set_process_unhandled_input(false)
			restart_requested.emit()
