extends "res://scripts/combat_actor.gd"
## Controles provisionales: movimiento relativo a pantalla y apuntado en plano XZ.
## La raíz solo se traslada; Facing gira y Camera hereda únicamente la traslación.

@export_range(0.0, 50.0, 0.1) var movement_speed := 6.0
@export var flight_height := 1.5
@export var arena_half_size := Vector2(12.0, 12.0)
@export_range(0.0, 12.0, 0.1) var bounds_margin := 2.0

@onready var camera: Camera3D = $Camera
@onready var facing: Node3D = $Facing
@onready var weapon: Node3D = $Weapon


func _ready() -> void:
	super._ready()
	_constrain_position()
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	if not is_alive():
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var right := camera.global_basis.x
	var back := camera.global_basis.z
	right.y = 0.0
	back.y = 0.0
	var direction := (right.normalized() * input.x + back.normalized() * input.y).limit_length(1.0)
	position += direction * movement_speed * delta
	_constrain_position()
	_aim_at_cursor(get_viewport().get_mouse_position())
	if Input.is_action_pressed("attack"):
		weapon.try_fire(-facing.global_basis.z)


func _constrain_position() -> void:
	var limit := (arena_half_size - Vector2.ONE * bounds_margin).max(Vector2.ZERO)
	position = Vector3(clampf(position.x, -limit.x, limit.x), flight_height, clampf(position.z, -limit.y, limit.y))


func _aim_at_cursor(cursor: Vector2) -> void:
	if not get_viewport().get_visible_rect().has_point(cursor):
		return
	var plane := Plane(Vector3.UP, global_position.y)
	var hit: Variant = plane.intersects_ray(camera.project_ray_origin(cursor), camera.project_ray_normal(cursor))
	if hit == null or global_position.distance_squared_to(hit) < 0.0001:
		return
	facing.look_at(hit, Vector3.UP)
