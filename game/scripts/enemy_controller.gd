extends "res://scripts/combat_actor.gd"
## IA y valores provisionales: persigue en XZ y dispara al entrar en alcance.
## Solo Facing gira; la raíz conserva la altura y los límites de la arena.

@export_range(0.0, 50.0, 0.1) var movement_speed := 3.0
@export var flight_height := 1.5
@export var arena_half_size := Vector2(12.0, 12.0)
@export_range(0.0, 12.0, 0.1) var bounds_margin := 2.0
@export_range(0.0, 30.0, 0.1) var attack_range := 7.0

var target: Node3D

@onready var facing: Node3D = $Facing
@onready var weapon: Node3D = $Weapon


func _ready() -> void:
	super._ready()
	_constrain_position()
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	if not is_alive() or not _has_valid_target():
		return
	_constrain_position()
	var direction := target.global_position - global_position
	direction.y = 0.0
	var distance := direction.length()
	if distance < 0.0001:
		return
	direction /= distance
	if distance > attack_range:
		# Detenerse exactamente en el radio, incluso con un paso de física largo.
		var travel := minf(movement_speed * delta, distance - attack_range)
		var previous_position := position
		position += direction * travel
		_constrain_position()
		if delta > 0.0:
			velocity = (position - previous_position) / delta
		direction = target.global_position - global_position
		direction.y = 0.0
		distance = direction.length()
	if distance < 0.0001:
		return
	facing.look_at(facing.global_position + direction, Vector3.UP)
	if distance <= attack_range + 0.0001:
		weapon.try_fire(direction.normalized())


func _has_valid_target() -> bool:
	return (
		is_instance_valid(target)
		and target.is_inside_tree()
		and not target.is_queued_for_deletion()
		and target != self
		and target.has_method("is_alive")
		and target.is_alive()
		and target.get("faction") != faction
	)


func _constrain_position() -> void:
	var limit := (arena_half_size - Vector2.ONE * bounds_margin).max(Vector2.ZERO)
	position = Vector3(clampf(position.x, -limit.x, limit.x), flight_height, clampf(position.z, -limit.y, limit.y))
