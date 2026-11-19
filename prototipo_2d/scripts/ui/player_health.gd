extends ProgressBar
@export var health: Node

func _ready() -> void:
	health.health_changed.connect(_update_health)
	_update_health(health.current_health, health.max_health)

func _update_health(hp: int, maximum: int) -> void:
	max_value = maximum
	value = hp
	$Text.text = "Vida  %d / %d" % [hp, maximum]
