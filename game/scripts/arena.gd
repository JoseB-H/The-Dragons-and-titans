extends Node3D
## Ciclo offline provisional: si ambos caen en el mismo paso, el jugador pierde.

enum MatchState { PLAYING, VICTORY, DEFEAT }

signal match_finished(result: int)

var state: MatchState = MatchState.PLAYING
var _restart_pending := false

@onready var player: Node3D = $Dragon
@onready var enemy: Node3D = $Enemy
@onready var hud: CanvasLayer = $Controls


func _ready() -> void:
	# Actores y proyectiles resuelven primero (prioridad 0). El cierre ve todo el tick.
	process_physics_priority = 100
	player.get_node("Weapon").projectile_parent = $Projectiles
	player.get_node("PowerWeapon").projectile_parent = $Projectiles
	player.get_node("PulseAbility").effects_parent = $Effects
	enemy.get_node("Weapon").projectile_parent = $Projectiles
	enemy.target = player
	hud.restart_requested.connect(restore_arena)
	hud.selection_requested.connect(return_to_selection)
	_update_hud()


func _physics_process(_delta: float) -> void:
	if state != MatchState.PLAYING or _restart_pending:
		return
	if not player.is_alive():
		_finish_match(MatchState.DEFEAT)
	elif not enemy.is_alive():
		_finish_match(MatchState.VICTORY)


func _process(_delta: float) -> void:
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if _restart_pending or not is_inside_tree():
		return
	if event.is_action_pressed("restore_arena") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if not player.waiting_for_release():
			restore_arena()


func restore_arena() -> Error:
	if _restart_pending:
		return OK
	_restart_pending = true
	var error := get_tree().reload_current_scene()
	if error != OK:
		_restart_pending = false
	return error


func return_to_selection() -> Error:
	if _restart_pending:
		return OK
	if state == MatchState.PLAYING:
		return ERR_UNAVAILABLE
	_restart_pending = true
	var error := get_tree().change_scene_to_file("res://scenes/dragon_selection.tscn")
	if error != OK:
		_restart_pending = false
	return error


func _finish_match(result: MatchState) -> void:
	if state != MatchState.PLAYING:
		return
	state = result
	for actor: Node3D in [player, enemy]:
		actor.combat_enabled = false
		actor.velocity = Vector3.ZERO
	for container: Node in [$Projectiles, $Effects]:
		for transient in container.get_children():
			# No ejecutar otro paso mientras queue_free espera a liberar el nodo.
			transient.process_mode = Node.PROCESS_MODE_DISABLED
			transient.queue_free()
	for flash in get_tree().get_nodes_in_group("equipment_impacts"):
		flash.queue_free()
	_update_hud()
	match_finished.emit(state)


func _update_hud() -> void:
	var status := ""
	if state == MatchState.DEFEAT or not player.is_alive():
		status = " · Jugador caído"
	elif state == MatchState.VICTORY or not enemy.is_alive():
		status = " · Enemigo abatido"
	var release_hint := ""
	if player.waiting_for_release():
		release_hint = "\nSuelta las teclas y el clic mantenidos para jugar."
	var text := "%s · Objetivo: vencer al enemigo · Valores provisionales\nWASD: mover · Ratón: orientar · Clic izq.: disparar\nQ: proyectil potente · E: pulso · R: reiniciar\nJugador: %d / %d · Enemigo: %d / %d%s\n%s · %s · %s%s" % [player.profile_name + " / " + player.equipment_name, player.current_health, player.max_health, enemy.current_health, enemy.max_health, status, _basic_status(player.get_node("Weapon").cooldown_remaining), _ability_status("Q", player.get_node("PowerWeapon").cooldown_remaining), _ability_status("E", player.get_node("PulseAbility").cooldown_remaining), release_hint]
	hud.update_view(text, state)


func _basic_status(remaining: float) -> String:
	if state != MatchState.PLAYING or not player.is_alive():
		return "Básico: BLOQUEADO (%.1f s)" % remaining
	return "Básico: %.1f s" % remaining


func _ability_status(key: String, remaining: float) -> String:
	if state != MatchState.PLAYING or not player.is_alive():
		return "%s: BLOQUEADA (%.1f s)" % [key, remaining]
	if remaining > 0.0:
		return "%s: %.1f s" % [key, remaining]
	return "%s: LISTA" % key
