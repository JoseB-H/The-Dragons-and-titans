extends CharacterBody3D
## Salud y facciones compartidas. Los controladores llaman super._ready().
## Valores provisionales del prototipo, no estadísticas del juego original.

signal health_changed(current: int, maximum: int)
signal died()

@export_range(1, 10000, 1, "or_greater") var max_health: int = 100:
	set(value):
		var maximum := maxi(value, 1)
		if max_health == maximum:
			return
		max_health = maximum
		if is_node_ready():
			current_health = clampi(current_health, 0, max_health)
			health_changed.emit(current_health, max_health)
@export var faction: int = 1

var current_health: int = 0
var combat_enabled := true


func _ready() -> void:
	add_to_group("combat_actors")
	current_health = max_health
	health_changed.emit(current_health, max_health)


func is_alive() -> bool:
	return current_health > 0


func can_act() -> bool:
	return combat_enabled and is_inside_tree() and not is_queued_for_deletion() and is_alive()


func take_damage(amount: int, attacker_faction: int) -> bool:
	if not combat_enabled or amount <= 0 or attacker_faction == faction or not is_alive():
		return false
	current_health = clampi(current_health - amount, 0, max_health)
	var killed := not is_alive()
	health_changed.emit(current_health, max_health)
	if killed:
		died.emit()
	return true
