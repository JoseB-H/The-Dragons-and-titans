extends Node3D
## Arma sin entrada: jugador e IA solicitan el mismo ataque direccional.
## Debe ser hija directa de un CombatActor; Arena asigna projectile_parent.

const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")

@export_range(1, 10000, 1, "or_greater") var damage: int = 20
@export_range(0.0, 1000.0, 0.1, "or_greater") var projectile_speed: float = 28.0
@export_range(0.0, 30.0, 0.01, "or_greater") var projectile_lifetime: float = 2.0
@export_range(0.0, 30.0, 0.01, "or_greater") var cooldown: float = 0.4
@export_range(0.0, 10.0, 0.1, "or_greater") var spawn_distance: float = 1.9

var cooldown_remaining: float = 0.0
var projectile_parent: Node3D


func _physics_process(delta: float) -> void:
	cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)


func try_fire(direction: Vector3) -> bool:
	var actor := get_parent() as CharacterBody3D
	if actor == null or not actor.has_method("is_alive") or not actor.is_alive():
		return false
	if not is_instance_valid(projectile_parent) or not projectile_parent.is_inside_tree() or projectile_parent.is_queued_for_deletion():
		return false
	var flat_direction := Vector3(direction.x, 0.0, direction.z)
	if flat_direction.is_zero_approx() or cooldown_remaining > 0.0:
		return false
	flat_direction = flat_direction.normalized()
	var projectile := PROJECTILE_SCENE.instantiate() as Node3D
	projectile.direction = flat_direction
	projectile.damage = damage
	projectile.speed = projectile_speed
	projectile.lifetime = projectile_lifetime
	projectile.source_faction = actor.faction
	projectile.source_rid = actor.get_rid()
	projectile.launch_origin = actor.global_position
	projectile_parent.add_child(projectile)
	projectile.global_position = actor.global_position + flat_direction * spawn_distance
	projectile.reset_physics_interpolation()
	cooldown_remaining = maxf(cooldown, 0.0)
	return true
