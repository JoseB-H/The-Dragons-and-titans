extends Camera2D
@export var target: CharacterBody2D
@export_range(0, 240) var look_ahead := 72.0
@export_range(1, 30) var look_ahead_speed := 3.0
var lead := Vector2.ZERO

func _ready() -> void:
	global_position = target.global_position
	reset_smoothing()

func _physics_process(delta: float) -> void:
	# Camera2D suaviza el seguimiento. El adelanto nunca supera su límite.
	var desired: Vector2 = (target.get("aim_point")-target.global_position).limit_length(look_ahead)
	lead = lead.lerp(desired,minf(1,look_ahead_speed*delta))
	global_position = target.global_position+lead
