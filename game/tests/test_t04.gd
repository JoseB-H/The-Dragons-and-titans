extends SceneTree
## Integración T04: entrada física, recargas independientes y restauración real.

var checks := 0
var failures := 0
var shots_spawned := 0
var effects_spawned := 0


func _initialize() -> void:
	_run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func ticks(count: int) -> void:
	for frame in range(count):
		await physics_frame
		await process_frame


func key(code: int, pressed: bool, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _run() -> void:
	var arena: Node3D = load("res://scenes/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var player: Node3D = arena.get_node("Dragon")
	expect(player.has_node("PowerWeapon") and player.has_node("PulseAbility"), "T04 compone Q/E en el jugador conservado")
	if not player.has_node("PowerWeapon") or not player.has_node("PulseAbility"):
		arena.free()
		quit(1)
		return
	arena.get_node("Enemy").set_physics_process(false)
	player.set_physics_process(false)
	var basic: Node = player.get_node("Weapon")
	var power: Node = player.get_node("PowerWeapon")
	var pulse: Node = player.get_node("PulseAbility")
	var shots: Node = arena.get_node("Projectiles")
	var effects: Node = arena.get_node("Effects")
	shots.child_entered_tree.connect(func(_node: Node): shots_spawned += 1)
	effects.child_entered_tree.connect(func(_node: Node): effects_spawned += 1)
	# CD breve solo en el montaje: permite probar mantener tecla tras expirar.
	power.cooldown = 0.05
	pulse.cooldown = 0.05
	await ticks(2)
	var label: Label = arena.get_node("Controls/Panel/Margin/Label")
	expect(label.text.contains("Q: LISTA") and label.text.contains("E: LISTA"), "HUD anuncia habilidades disponibles")
	key(KEY_Q, true)
	expect(shots_spawned == 1 and power.cooldown_remaining > 0.0, "Pulsación física Q activa un proyectil potente")
	expect(basic.cooldown_remaining == 0.0 and pulse.cooldown_remaining == 0.0, "Q no consume recargas ajenas")
	key(KEY_Q, true, true)
	expect(shots_spawned == 1, "Eco de Q no activa otra habilidad")
	key(KEY_E, true)
	expect(effects_spawned == 1 and pulse.cooldown_remaining > 0.0, "E se activa aunque Q esté en recarga")
	key(KEY_E, true, true)
	expect(effects_spawned == 1, "Eco de E no activa otro pulso")
	Input.action_press("attack")
	player._physics_process(0.0)
	Input.action_release("attack")
	expect(shots_spawned == 2 and basic.cooldown_remaining > 0.0, "Ataque básico funciona con Q/E en recarga")
	var power_remaining: float = power.cooldown_remaining
	var pulse_remaining: float = pulse.cooldown_remaining
	key(KEY_Q, false)
	key(KEY_Q, true)
	key(KEY_E, false)
	key(KEY_E, true)
	expect(shots_spawned == 2 and effects_spawned == 1, "Intentos durante recarga no crean nodos")
	expect(power.cooldown_remaining == power_remaining and pulse.cooldown_remaining == pulse_remaining, "Rechazo no reinicia ni consume recarga")
	await ticks(10)
	expect(power.cooldown_remaining == 0.0 and pulse.cooldown_remaining == 0.0, "Recargas de habilidades terminan con física real")
	key(KEY_Q, true, true)
	key(KEY_E, true, true)
	expect(shots_spawned == 2 and effects_spawned == 1, "Mantener tecla/eco tras recarga no reactiva Q/E")
	key(KEY_Q, false)
	key(KEY_E, false)
	key(KEY_Q, true)
	key(KEY_E, true)
	expect(shots_spawned == 3 and effects_spawned == 2, "Soltar y volver a pulsar activa después de recarga")
	key(KEY_Q, false)
	key(KEY_E, false)
	await ticks(10)
	# Un foco perdido puede omitir key-up: no dejar una habilidad bloqueada por latch.
	key(KEY_Q, true)
	await ticks(10)
	player.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	key(KEY_Q, true)
	expect(shots_spawned == 5, "Recuperar foco admite nueva pulsación sin latch atascado")
	key(KEY_Q, false)
	player.take_damage(1000, 2)
	await ticks(10)
	var before_shots := shots_spawned
	var before_effects := effects_spawned
	key(KEY_Q, true)
	key(KEY_E, true)
	key(KEY_Q, false)
	key(KEY_E, false)
	expect(shots_spawned == before_shots and effects_spawned == before_effects, "Jugador muerto no usa Q/E por entrada física")
	expect(power.cooldown_remaining == 0.0 and pulse.cooldown_remaining == 0.0, "Intentos muerto no consumen recargas")
	await process_frame
	expect(label.text.contains("Q: BLOQUEADA") and label.text.contains("E: BLOQUEADA"), "HUD informa bloqueo por muerte")

	# Tres reinicios con habilidades/effectos y recargas activos, no un reset simulado.
	for iteration in range(3):
		arena.restore_arena()
		await scene_changed
		arena = current_scene
		arena.get_node("Enemy").set_physics_process(false)
		player = arena.get_node("Dragon")
		basic = player.get_node("Weapon")
		power = player.get_node("PowerWeapon")
		pulse = player.get_node("PulseAbility")
		shots = arena.get_node("Projectiles")
		effects = arena.get_node("Effects")
		expect(basic.cooldown_remaining == 0 and power.cooldown_remaining == 0 and pulse.cooldown_remaining == 0, "Restaura todas las recargas %d" % iteration)
		expect(shots.get_child_count() == 0 and effects.get_child_count() == 0, "Restaura contenedores vacíos %d" % iteration)
		expect(player.current_health == 100 and arena.get_node("Enemy").current_health == 80, "Restaura salud de ambos actores")
		expect(player.position.is_equal_approx(Vector3(0, 1.5, 0)), "Restaura posición del jugador")
		expect(arena.find_children("*", "CharacterBody3D", true, false).size() == 2 and player.get_signal_connection_list("died").is_empty(), "Sin actores/conexiones acumulados")
		await process_frame
		label = arena.get_node("Controls/Panel/Margin/Label")
		expect(label.text.contains("Q: LISTA") and label.text.contains("E: LISTA"), "HUD recupera disponibilidad")
		key(KEY_Q, true)
		key(KEY_E, true)
		key(KEY_Q, false)
		key(KEY_E, false)
		expect(shots.get_child_count() == 1 and effects.get_child_count() == 1, "Q/E crean estado activo para próxima restauración")
		expect(basic.try_fire(Vector3.RIGHT), "Básico también queda en recarga antes de restaurar")
		player.take_damage(10, 2)
		player.position = Vector3(2, 1.5, 3)
	# Restaurar también el estado activo creado en el último ciclo.
	arena.restore_arena()
	await scene_changed
	arena = current_scene
	arena.get_node("Enemy").set_physics_process(false)
	expect(arena.get_node("Effects").get_child_count() == 0 and arena.get_node("Projectiles").get_child_count() == 0, "Última restauración elimina todos los efectos/proyectiles")
	arena.free()
	print("T04 integración: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)
