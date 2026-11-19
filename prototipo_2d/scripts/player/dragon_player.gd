extends CharacterBody2D
## 24 píxeles equivalen a un metro del prototipo anterior.
@export_range(1, 1000) var max_speed := 336.0
@export_range(1, 3000) var acceleration := 960.0
@export_range(1, 3000) var deceleration := 720.0
@export_range(1, 30) var turn_speed := 10.0
@export_range(0, 0.4) var bank_amount := 0.17
@export_range(1, 30) var bank_speed := 6.0
@export var aim_marker: Polygon2D
@export var spawn_point: Marker2D
@export_range(0.1, 30) var respawn_time := 3.0
@export_range(0, 10) var protection_time := 2.0
var aim_point := Vector2.ZERO

func _ready() -> void:
	global_position = spawn_point.global_position
	$HealthComponent.died.connect(_die)

func _die() -> void:
	velocity = Vector2.ZERO
	hide()
	aim_marker.hide()
	$Collider.set_deferred("disabled", true)
	set_physics_process(false)
	await get_tree().create_timer(respawn_time, false, true).timeout
	global_position = spawn_point.global_position
	aim_point = global_position
	$Model.skew = 0
	$HealthComponent.revive(protection_time > 0)
	$Aura.visible = protection_time > 0
	$Collider.set_deferred("disabled", false)
	show()
	aim_marker.show()
	set_physics_process(true)
	var camera := get_viewport().get_camera_2d()
	if camera:
		camera.global_position = global_position
		camera.reset_smoothing()
	if protection_time > 0:
		await get_tree().create_timer(protection_time, false, true).timeout
		$HealthComponent.invulnerable = false
		$Aura.hide()

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left","move_right","move_up","move_down")
	var rate := deceleration if input.is_zero_approx() else acceleration
	velocity = velocity.move_toward(input*max_speed,rate*delta)
	move_and_slide()
	aim_point = get_global_mouse_position()
	if aim_marker: aim_marker.global_position = aim_point
	var aim := aim_point-global_position
	if aim.length_squared() > 5.76:
		# La nariz de la figura apunta a la derecha en sus coordenadas locales.
		rotation = lerp_angle(rotation,aim.angle(),minf(1,turn_speed*delta))
	var lateral := velocity.rotated(-rotation).y/max_speed
	$Model.skew = lerpf($Model.skew,-lateral*bank_amount,minf(1,bank_speed*delta))
