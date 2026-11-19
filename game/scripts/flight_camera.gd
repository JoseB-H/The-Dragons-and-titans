extends Camera3D
## Cámara hija del piloto. Conserva su orientación y sigue su posición en el mundo.
@export_range(0.1, 30.0, 0.1) var follow_rate := 7.0
var pilot: Node3D
var offset_from_pilot: Vector3

func _ready() -> void:
	pilot = get_parent_node_3d()
	offset_from_pilot = position
	top_level = true
	snap_to_pilot()
	look_at(pilot.global_position, Vector3.UP)
	# Primero se desplaza el piloto, luego la cámara y finalmente se calcula la mira.
	process_physics_priority = 1

func snap_to_pilot() -> void:
	global_position = pilot.global_position + offset_from_pilot
	reset_physics_interpolation()

func _physics_process(delta: float) -> void:
	# La interpolación exponencial mantiene una respuesta estable al cambiar los FPS.
	var weight := 1.0 - exp(-follow_rate * delta)
	global_position = global_position.lerp(pilot.global_position + offset_from_pilot, weight)
