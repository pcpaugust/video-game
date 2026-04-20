extends HBoxContainer

# อ้างอิง Node ลูกภายใน LevelBar.tscn (อิงตามรูปที่ 3)
@onready var level_label = $Level/LevelLabel
@onready var progress_bar = $BarWrap/ProgressBar
@onready var star1 = $BarWrap/StarLeft
@onready var star2 = $BarWrap/StarMid
@onready var star3 = $BarWrap/StarRight

var empty_star = preload("res://assets/artwork/star/empty.png")
var gold_star = preload("res://assets/artwork/star/fill.png")

func set_level(level_number: int, target: int) -> void:
	# อัปเดตข้อความ เช่น "Level 1" หรือ "ด่าน: 1"
	if level_label:
		level_label.text = "Level %d" % level_number
		level_label.queue_redraw()
	# รีเซ็ต ProgressBar เมื่อเริ่มด่านใหม่ (ถ้าคุณใช้มันแสดงความคืบหน้าของด่าน)
	if progress_bar:
		progress_bar.value = 0
		progress_bar.max_value = target
	update_star_visual()

# (เพิ่มเติม) ฟังก์ชันอัปเดตความคืบหน้าของด่าน
func update_progress(current_score: int) -> void:
	if progress_bar:
		progress_bar.value = current_score
	update_star_visual()

func update_star_visual() -> void:
	var threshold = progress_bar.max_value / 3
	if progress_bar.value < threshold:
		star1.texture = empty_star
		star2.texture = empty_star
		star3.texture = empty_star
		return
	
	if progress_bar.value >= threshold:
		star1.texture = gold_star
	if progress_bar.value >= threshold * 2:
		star2.texture = gold_star
	if progress_bar.value >= threshold * 3:
		star3.texture = gold_star
