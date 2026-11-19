extends SceneTree
## T05: cierre determinista, bloqueo y reinicio sobre la escena de producción.

var checks := 0
var failures := 0
var arena_scene: PackedScene = load("res://scenes/arena.tscn")

const ACTIONS := ["move_left", "move_right", "move_forward", "move_back", "attack", "ability_q", "ability_e", "restore_arena", "ui_accept"]


func _initialize() -> void:
	_run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func ticks(count: int = 1) -> void:
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


func mouse(pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func release_actions() -> void:
	for action: String in ACTIONS:
		Input.action_release(action)


func make_arena() -> Node3D:
	var arena: Node3D = arena_scene.instantiate()
	root.add_child(arena)
	current_scene = arena
	arena.get_node("Dragon").set_physics_process(false)
	arena.get_node("Enemy").set_physics_process(false)
	return arena


func aim_pair(arena: Node3D) -> void:
	var player: Node3D = arena.get_node("Dragon")
	var enemy: Node3D = arena.get_node("Enemy")
	player.position = Vector3(-3, 1.5, 0)
	enemy.position = Vector3(3, 1.5, 0)
	player.reset_physics_interpolation()
	enemy.reset_physics_interpolation()
	for actor: Node3D in [player, enemy]:
		var weapon: Node = actor.get_node("Weapon")
		weapon.damage = 1000
		weapon.projectile_speed = 600.0
		weapon.spawn_distance = 0.0


func test_actor_permission() -> void:
	var actor: CharacterBody3D = load("res://scripts/combat_actor.gd").new()
	root.add_child(actor)
	expect(actor.can_act(), "Actor aislado conserva combate permitido por defecto")
	actor.combat_enabled = false
	expect(not actor.can_act() and not actor.take_damage(10, 2) and actor.current_health == 100, "Deshabilitar combate bloquea acciones y recepción de daño")
	actor.combat_enabled = true
	expect(actor.take_damage(10, 2) and actor.current_health == 90, "Un actor aislado vuelve a aceptar daño al habilitarlo")
	root.remove_child(actor)
	expect(not actor.can_act(), "Un actor fuera del árbol no puede actuar")
	root.add_child(actor)
	actor.queue_free()
	expect(not actor.can_act(), "Un actor pendiente de liberar no puede actuar")
	await ticks()


func test_victory_and_closure() -> void:
	var arena := make_arena()
	var player: Node3D = arena.get_node("Dragon")
	var enemy: Node3D = arena.get_node("Enemy")
	var basic: Node = player.get_node("Weapon")
	var power: Node = player.get_node("PowerWeapon")
	var pulse: Node = player.get_node("PulseAbility")
	var hostile_weapon: Node = enemy.get_node("Weapon")
	var results: Array[int] = []
	var closed_at_signal: Array[bool] = []
	arena.match_finished.connect(func(result: int):
		results.append(result)
		closed_at_signal.append(not player.can_act() and not enemy.can_act() and not player.take_damage(10, 2) and not basic.try_fire(Vector3.RIGHT))
	)
	await ticks(2)
	expect(arena.state == 0 and not paused, "Jugando empieza sin pausa global")
	expect(player.get_signal_connection_list("died").is_empty() and enemy.get_signal_connection_list("died").is_empty(), "Resolver el resultado no añade conexiones a muerte")
	aim_pair(arena)
	# Sincronizar los colliders movidos con el mundo físico antes del barrido.
	await ticks(2)
	pulse.radius = 1.0
	expect(pulse.try_activate(), "Crear un efecto activo antes del final")
	hostile_weapon.projectile_speed = 1.0
	expect(hostile_weapon.try_fire(Vector3.LEFT), "Crear daño hostil pendiente antes del final")
	expect(basic.try_fire(Vector3.RIGHT), "Disparo real prepara la victoria")
	expect(arena.state == 0, "Disparar todavía no decide victoria antes de la física")
	await ticks(2)
	expect(enemy.current_health == 0 and player.current_health == 100 and arena.state == 1, "Impacto real gana sin daño posterior del proyectil lento")
	expect(results == [1] and closed_at_signal == [true], "La transición única emite victoria después de bloquear ambos actores")
	expect(not player.combat_enabled and not enemy.combat_enabled, "El cierre bloquea también al ganador vivo")
	expect(arena.get_node("Projectiles").get_child_count() == 0 and arena.get_node("Effects").get_child_count() == 0, "El cierre elimina proyectiles y efectos activos")
	expect(not player.take_damage(1000, 2) and not enemy.take_damage(1000, 1), "Daño directo pendiente queda bloqueado para ambos actores")
	power.cooldown_remaining = 0.0
	pulse.cooldown_remaining = 0.0
	basic.cooldown_remaining = 0.0
	expect(not basic.try_fire(Vector3.RIGHT) and not power.try_fire(Vector3.RIGHT) and not pulse.try_activate(), "El ganador no usa básico/Q/E mediante sus APIs")
	expect(basic.cooldown_remaining == 0.0 and power.cooldown_remaining == 0.0 and pulse.cooldown_remaining == 0.0, "Intentos finales no consumen recargas")
	var player_position := player.position
	var enemy_position := enemy.position
	var facing: Basis = player.get_node("Facing").basis
	Input.action_press("move_forward")
	Input.action_press("attack")
	key(KEY_Q, true)
	key(KEY_E, true)
	player._physics_process(1.0)
	enemy._physics_process(1.0)
	key(KEY_Q, false)
	key(KEY_E, false)
	release_actions()
	expect(player.position.is_equal_approx(player_position) and enemy.position.is_equal_approx(enemy_position), "Movimiento de jugador e IA queda congelado al terminar")
	expect(player.get_node("Facing").basis.is_equal_approx(facing), "La orientación queda congelada al terminar")
	expect(arena.get_node("Projectiles").get_child_count() == 0 and arena.get_node("Effects").get_child_count() == 0, "Entrada Q/E/clic tras el final no crea acciones")
	await ticks(10)
	arena._physics_process(0.0)
	expect(player.current_health == 100 and arena.state == 1 and results == [1], "Pasos posteriores conservan salud, resultado y emisión única")
	var label: Label = arena.get_node("Controls/Panel/Margin/Label")
	expect(label.text.contains("Enemigo abatido") and label.text.contains("Q: BLOQUEADA") and label.text.contains("E: BLOQUEADA"), "HUD final anuncia enemigo abatido y habilidades bloqueadas del ganador")
	expect(label.text.contains("Objetivo") and label.text.contains("WASD") and label.text.contains("100 / 100"), "HUD conserva objetivo, controles y salud")
	expect(not paused, "El final mantiene interfaz activa sin pausar el árbol")
	arena.free()


func test_defeat() -> void:
	var arena := make_arena()
	aim_pair(arena)
	var player: Node3D = arena.get_node("Dragon")
	var enemy: Node3D = arena.get_node("Enemy")
	var results: Array[int] = []
	arena.match_finished.connect(func(result: int): results.append(result))
	await ticks(2)
	expect(enemy.get_node("Weapon").try_fire(Vector3.LEFT), "Un ataque real enemigo prepara la derrota")
	await ticks(2)
	expect(player.current_health == 0 and enemy.current_health == 80 and arena.state == 2, "Impacto enemigo decide derrota")
	expect(results == [2] and not enemy.can_act() and not enemy.take_damage(10, 1), "Derrota emite una vez y bloquea daño al enemigo vivo")
	await ticks(3)
	expect(arena.get_node("Controls/Panel/Margin/Label").text.contains("Jugador caído"), "HUD conserva mensaje de jugador caído")
	expect(arena.state == 2 and results == [2], "La derrota no vuelve a resolverse en pasos posteriores")
	arena.free()


func test_simultaneous_damage() -> void:
	for enemy_shoots_first in [false, true]:
		var arena := make_arena()
		aim_pair(arena)
		var player: Node3D = arena.get_node("Dragon")
		var enemy: Node3D = arena.get_node("Enemy")
		var results: Array[int] = []
		arena.match_finished.connect(func(result: int): results.append(result))
		await ticks(2)
		if enemy_shoots_first:
			enemy.get_node("Weapon").try_fire(Vector3.LEFT)
			player.get_node("Weapon").try_fire(Vector3.RIGHT)
		else:
			player.get_node("Weapon").try_fire(Vector3.RIGHT)
			enemy.get_node("Weapon").try_fire(Vector3.LEFT)
		await ticks(2)
		expect(player.current_health == 0 and enemy.current_health == 0, "Ambos proyectiles letales resuelven el mismo paso físico, orden=%s" % enemy_shoots_first)
		expect(arena.state == 2 and results == [2], "Empate del mismo paso es derrota única, orden=%s" % enemy_shoots_first)
		arena.free()


func test_fast_restart_and_held_input() -> void:
	var arena := make_arena()
	var player: Node3D = arena.get_node("Dragon")
	var old_scene: WeakRef = weakref(arena)
	# Snapshot del nuevo jugador: solo estas acciones ya mantenidas bloquean entrada.
	for action in ACTIONS:
		Input.action_press(action)
	expect(arena.restore_arena() == OK and arena.restore_arena() == OK and arena.restore_arena() == OK, "Varias solicitudes rápidas aceptan un solo reload")
	await scene_changed
	arena = current_scene
	player = arena.get_node("Dragon")
	var enemy: Node3D = arena.get_node("Enemy")
	player.set_physics_process(false)
	enemy.set_physics_process(false)
	var reloaded: WeakRef = weakref(arena)
	expect(old_scene.get_ref() == null and arena.state == 0, "El reload libera la escena previa y restaura estado jugando")
	expect(player.waiting_for_release() and player.can_act(), "Entrada retenida se bloquea sin deshabilitar APIs de combate del actor")
	expect(player.current_health == 100 and enemy.current_health == 80 and enemy.target == player, "El reload restaura salud y objetivo")
	expect(player.get_node("Weapon").cooldown_remaining == 0.0 and player.get_node("PowerWeapon").cooldown_remaining == 0.0 and player.get_node("PulseAbility").cooldown_remaining == 0.0, "El reload restaura todas las recargas")
	var initial := player.position
	player._physics_process(1.0)
	key(KEY_Q, true)
	key(KEY_E, true)
	key(KEY_R, true)
	expect(player.position.is_equal_approx(initial) and arena.get_node("Projectiles").get_child_count() == 0 and arena.get_node("Effects").get_child_count() == 0, "WASD/clic/Q/E mantenidos no actúan al volver")
	await ticks(3)
	expect(current_scene == reloaded.get_ref(), "R mantenida no encadena otro reinicio")
	# Las APIs directas siguen disponibles: el bloqueo pertenece solo a entrada.
	expect(player.get_node("Weapon").try_fire(Vector3.RIGHT), "Arma directa funciona mientras se espera soltar entrada")
	for projectile in arena.get_node("Projectiles").get_children():
		projectile.free()
	# Soltar snapshot y pulsar una tecla nueva antes del próximo tick no lo amplía.
	key(KEY_Q, false)
	key(KEY_E, false)
	key(KEY_R, false)
	release_actions()
	key(KEY_Q, true)
	expect(not player.waiting_for_release() and arena.get_node("Projectiles").get_child_count() == 1, "Nueva Q funciona en el mismo evento que detecta snapshot liberado")
	key(KEY_Q, false)
	player.get_node("Weapon").cooldown_remaining = 0.0
	mouse(true)
	player._physics_process(0.0)
	expect(arena.get_node("Projectiles").get_child_count() == 2, "Clic nuevo funciona después de soltar snapshot")
	mouse(false)
	Input.action_press("move_right")
	player._physics_process(0.1)
	expect(not player.position.is_equal_approx(initial), "Movimiento nuevo funciona después de soltar snapshot")
	release_actions()
	arena.free()


func test_release_detected_by_mouse() -> void:
	# Solo W estaba retenida: una tecla recién pulsada nunca amplía el snapshot.
	Input.action_press("move_forward")
	var arena := make_arena()
	var player: Node3D = arena.get_node("Dragon")
	expect(player.waiting_for_release(), "W retenida bloquea inicialmente la entrada")
	Input.action_release("move_forward")
	mouse(true)
	player._physics_process(0.0)
	expect(not player.waiting_for_release() and arena.get_node("Projectiles").get_child_count() == 1, "Un evento de ratón refresca liberación antes del filtro de teclas")
	mouse(false)
	release_actions()
	arena.free()
	Input.action_press("ui_accept")
	arena = make_arena()
	player = arena.get_node("Dragon")
	expect(player.waiting_for_release(), "Enter mantenido por botón también se captura")
	Input.action_release("ui_accept")
	key(KEY_E, true)
	expect(not player.waiting_for_release() and arena.get_node("Effects").get_child_count() == 1, "Soltar Enter y pulsar E nueva permite activar sin esperar física")
	key(KEY_E, false)
	release_actions()
	arena.free()


func _run() -> void:
	release_actions()
	var arena := make_arena()
	var has_state := false
	for property in arena.get_property_list():
		if property.name == "state":
			has_state = true
	expect(has_state, "Arena expone estado inicial jugando para resolver el fin de partida")
	if has_state:
		expect(arena.state == 0, "La escena nueva empieza jugando")
	arena.free()
	if has_state:
		await test_actor_permission()
		await test_victory_and_closure()
		await test_defeat()
		await test_simultaneous_damage()
		await test_fast_restart_and_held_input()
		test_release_detected_by_mouse()
	print("T05 estado: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)
