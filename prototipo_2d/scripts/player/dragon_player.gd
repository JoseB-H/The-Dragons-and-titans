extends CharacterBody2D
## 24 píxeles equivalen a un metro del prototipo anterior.
@export_range(1, 1000) var max_speed := 336.0
@export_range(1, 3000) var acceleration := 960.0
@export_range(1, 3000) var deceleration := 720.0
@export_range(1, 30) var turn_speed := 10.0
@export_range(0, 0.4) var bank_amount := 0.17
@export_range(1, 30) var bank_speed := 6.0
@export var aim_marker: Polygon2D
var aim_point := Vector2.ZERO

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left","move_right","move_up","move_down")
	var rate := deceleration if input.is_zero_approx() else acceleration
	velocity = velocity.move_toward(input.normalized()*max_speed,rate*delta)
	move_and_slide()
	aim_point = get_global_mouse_position()
	if aim_marker: aim_marker.global_position = aim_point
	var aim := aim_point-global_position
	if aim.length_squared() > 5.76:
		# La nariz de la figura apunta a la derecha en sus coordenadas locales.
		rotation = lerp_angle(rotation,aim.angle(),minf(1,turn_speed*delta))
	var lateral := velocity.rotated(-rotation).y/max_speed
	$Model.skew = lerpf($Model.skew,-lateral*bank_amount,minf(1,bank_speed*delta))
