extends Node3D
## Pulso instantáneo: daño una vez por centro XZ, con frontera inclusiva.
## Hijo directo de CombatActor; Arena asigna effects_parent.
## E sin hostiles también consume recarga y crea el efecto. Balance provisional.

signal activated()

const COMBAT_ACTOR := preload("res://scripts/combat_actor.gd")
const EFFECT_SCENE := preload("res://scenes/pulse_effect.tscn")

@export_range(1, 10000, 1, "or_greater") var damage: int = 30
@export_range(0.01, 30.0, 0.01, "or_greater") var radius: float = 4.0
@export_range(0.0, 30.0, 0.01, "or_greater") var cooldown: float = 4.0
@export_range(0.01, 10.0, 0.01, "or_greater") var effect_duration: float = 0.5

var cooldown_remaining: float = 0.0
var effects_parent: Node3D
var _activating := false


func _physics_process(delta: float) -> void:
	cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)


func try_activate() -> bool:
	if not is_inside_tree() or is_queued_for_deletion() or _activating or cooldown_remaining > 0.0:
		return false
	var actor := get_parent() as COMBAT_ACTOR
	if actor == null or not actor.can_act():
		return false
	if not is_instance_valid(effects_parent) or not effects_parent.is_inside_tree() or effects_parent.is_queued_for_deletion():
		return false
	if damage <= 0 or not is_finite(radius) or radius <= 0.0 or not is_finite(cooldown) or cooldown < 0.0 or not is_finite(effect_duration) or effect_duration <= 0.0:
		return false
	var origin := actor.global_position
	var source_faction: int = actor.faction
	var pulse_damage := damage
	var radius_squared := radius * radius
	var candidates := get_tree().get_nodes_in_group("combat_actors")
	var effect := EFFECT_SCENE.instantiate() as Node3D
	effect.radius = radius
	effect.lifetime = effect_duration
	# El contenedor administra la vida del VFX; su escala no cambia el alcance.
	effect.top_level = true
	effect.position = origin
	# Reservar antes de add_child y de las señales de daño evita reentrada.
	_activating = true
	cooldown_remaining = cooldown
	effects_parent.add_child(effect)
	effect.reset_physics_interpolation()
	for candidate in candidates:
		if not is_instance_valid(candidate) or not candidate is Node3D or candidate == actor:
			continue
		if not candidate.is_inside_tree() or candidate.is_queued_for_deletion():
			continue
		if not candidate.has_method("is_alive") or not candidate.has_method("take_damage"):
			continue
		var target_faction: Variant = candidate.get("faction")
		if not target_faction is int or target_faction == source_faction or not candidate.is_alive():
			continue
		var offset: Vector3 = candidate.global_position - origin
		if offset.x * offset.x + offset.z * offset.z <= radius_squared:
			candidate.take_damage(pulse_damage, source_faction)
	if is_instance_valid(self):
		_activating = false
		activated.emit()
	return true
