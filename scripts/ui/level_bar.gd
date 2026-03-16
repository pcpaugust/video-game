extends Control

# อ้างอิง Node ลูกภายใน LevelBar.tscn (อิงตามรูปที่ 3)
@onready var level_label = $Container/Level
@onready var score_label = $Container/Score
@onready var progress_bar = $BarWrap/ProgressBar

func set_level(level_number: int, target: int) -> void:
	# อัปเดตข้อความ เช่น "Level 1" หรือ "ด่าน: 1"
	if level_label:
		level_label.text = "Level %d" % level_number
		level_label.queue_redraw()
	if score_label:
		score_label.text = "Score: 0"
	# รีเซ็ต ProgressBar เมื่อเริ่มด่านใหม่ (ถ้าคุณใช้มันแสดงความคืบหน้าของด่าน)
	if progress_bar:
		progress_bar.value = 0
		progress_bar.max_value = target

# (เพิ่มเติม) ฟังก์ชันอัปเดตความคืบหน้าของด่าน
func update_progress(current_score: int) -> void:
	if progress_bar:
		progress_bar.value = current_score
	if score_label:
		score_label.text = "Score: %d" % current_score
