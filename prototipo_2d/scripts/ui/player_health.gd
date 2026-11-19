extends ProgressBar
@export var health: Node

const GREEN := Color("#49da79")
const RED := Color("#f15152")
var fill := StyleBoxFlat.new()

func _ready() -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = Color("#14232b")
	add_theme_stylebox_override("background",background)
	add_theme_stylebox_override("fill",fill)
	health.health_changed.connect(_update_health)
	_update_health(health.current_health, health.max_health)

func _update_health(hp: int, maximum: int) -> void:
	max_value = maximum
	value = hp
	fill.bg_color = RED if hp*100 < maximum*30 else GREEN
	if has_node("Text"): $Text.text = "Vida  %d / %d" % [hp, maximum]
