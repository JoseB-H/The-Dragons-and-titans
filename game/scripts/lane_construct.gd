extends "res://scripts/combat_actor.gd"

const WEAPON := preload("res://scripts/weapon.gd")

const ANGEL := preload("res://assets/minions/angel.glb")
const DEMON := preload("res://assets/minions/demonio.glb")

var model: Node3D
var wing_left: Node3D
var wing_right: Node3D
var flight_phase := 0.0
var lane := 0
var advance_direction := 1.0
var target: Node3D
var weapon: Node3D


func _ready() -> void:
	super._ready()
	model = (ANGEL if faction == 1 else DEMON).instantiate()
	add_child(model)
	wing_left = model.find_child("WingL", true, false)
	wing_right = model.find_child("WingR", true, false)
	flight_phase = lane * 1.7 + faction
	var collider := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.5
	collider.shape = sphere
	add_child(collider)
	weapon = WEAPON.new()
	weapon.damage = 5
	weapon.cooldown = 1.3
	weapon.spawn_distance = 0.52
	weapon.projectile_tint = Color("41bdd4") if faction == 1 else Color("eb6446")
	add_child(weapon)
	died.connect(queue_free)


func _physics_process(delta: float) -> void:
	if not can_act():
		return
	flight_phase += delta * (6.0 if faction == 1 else 9.0)
	var lift := sin(flight_phase)
	model.position.y = lift * 0.046
	wing_left.rotation.z = -lift * 0.21
	wing_right.rotation.z = lift * 0.21
	var direction := Vector3(advance_direction, 0, 0)
	if is_instance_valid(target) and target.can_act():
		var offset := target.global_position - global_position
		offset.y = 0.0
		if offset.length_squared() > 0.0001:
			direction = offset.normalized()
			look_at(global_position + direction)
			weapon.try_fire(direction)
			return
	look_at(global_position + direction)
	position.x = clampf(position.x + advance_direction * 4.2 * delta, -43.0, 43.0)
