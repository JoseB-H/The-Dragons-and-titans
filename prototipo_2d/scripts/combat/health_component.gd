class_name HealthComponent
extends Node
## Una instancia por actor. La muerte solo se emite al cruzar de vida positiva a cero.
signal health_changed(actual: int, maximum: int)
signal died
@export_range(1, 10000) var max_health := 100
@export var invulnerable := false
var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> bool:
	if amount <= 0 or invulnerable or current_health == 0:
		return false
	current_health = maxi(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()
	return true

func revive(protected: bool = false) -> void:
	invulnerable = protected
	current_health = max_health
	health_changed.emit(current_health, max_health)
