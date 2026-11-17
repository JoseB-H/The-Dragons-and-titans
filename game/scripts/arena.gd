extends Node3D
## Composición de T03 y restauración mínima. Los estados de partida son T05.

@onready var player: Node3D = $Dragon
@onready var enemy: Node3D = $Enemy
@onready var label: Label = $Controls/Panel/Margin/Label


func _ready() -> void:
	player.get_node("Weapon").projectile_parent = $Projectiles
	player.get_node("PowerWeapon").projectile_parent = $Projectiles
	player.get_node("PulseAbility").effects_parent = $Effects
	enemy.get_node("Weapon").projectile_parent = $Projectiles
	enemy.target = player
	_update_hud()


func _process(_delta: float) -> void:
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restore_arena") and not event.is_echo():
		get_viewport().set_input_as_handled()
		restore_arena()


func restore_arena() -> Error:
	return get_tree().reload_current_scene()


func _update_hud() -> void:
	var status := ""
	if not player.is_alive():
		status = " · Jugador caído"
	elif not enemy.is_alive():
		status = " · Enemigo abatido"
	label.text = "T04 · Habilidades · Valores provisionales\nWASD: mover · Ratón: orientar · Clic izq.: disparar\nQ: proyectil potente · E: pulso · R: restaurar\nJugador: %d / %d · Enemigo: %d / %d%s\nBásico: %.1f s · %s · %s" % [player.current_health, player.max_health, enemy.current_health, enemy.max_health, status, player.get_node("Weapon").cooldown_remaining, _ability_status("Q", player.get_node("PowerWeapon").cooldown_remaining), _ability_status("E", player.get_node("PulseAbility").cooldown_remaining)]


func _ability_status(key: String, remaining: float) -> String:
	if not player.is_alive():
		return "%s: BLOQUEADA (%.1f s)" % [key, remaining]
	if remaining > 0.0:
		return "%s: %.1f s" % [key, remaining]
	return "%s: LISTA" % key
