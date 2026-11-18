extends SceneTree
## Ciclo real en dos ventanas: combate, cierre, controles retenidos y botón/R.

var checks := 0
var failures := 0
var arena: Node3D
var player: Node3D
var enemy: Node3D
var camera: Camera3D
var hud: CanvasLayer
var shots_spawned := 0
var results: Array[int] = []
var output_dir := "user://t05-validation"


func _initialize() -> void:
	create_timer(120.0).timeout.connect(func():
		printerr("FAIL: T05 ventana excedió el tiempo máximo de 120 s")
		quit(1)
	)
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


func until(condition: Callable, limit: int) -> bool:
	for frame in range(limit):
		if condition.call():
			return true
		await ticks(1)
	return condition.call()


func key(code: int, pressed: bool, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)


func click(pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	# Input.parse_input_event recibe píxeles de ventana, no coordenadas virtuales.
	event.position = Vector2(DisplayServer.mouse_get_position() - DisplayServer.window_get_position())
	event.global_position = Vector2(DisplayServer.mouse_get_position())
	event.pressed = pressed
	Input.parse_input_event(event)


func pause_reloaded_enemy() -> void:
	# La escena nueva se inspecciona antes del primer ataque; luego se reactiva IA.
	if is_instance_valid(current_scene):
		current_scene.get_node("Enemy").set_physics_process(false)


func bind_scene() -> void:
	arena = current_scene
	player = arena.get_node("Dragon")
	enemy = arena.get_node("Enemy")
	camera = player.get_node("Camera")
	hud = arena.get_node("Controls")
	shots_spawned = 0
	arena.get_node("Projectiles").child_entered_tree.connect(func(_node: Node): shots_spawned += 1)
	arena.match_finished.connect(func(result: int): results.append(result))


func capture(filename: String, size: Vector2i) -> void:
	await RenderingServer.frame_post_draw
	# El framebuffer puede tener otra escala; capturar la ventana nativa en pantalla.
	var screen := DisplayServer.screen_get_image(DisplayServer.window_get_current_screen())
	if screen == null:
		expect(false, "El backend no permite capturar la ventana nativa")
		return
	var frame := screen.get_region(Rect2i(DisplayServer.window_get_position(), DisplayServer.window_get_size()))
	expect(frame.get_size() == size, "Captura tiene resolución física %s; observada %s" % [size, frame.get_size()])
	expect(frame.save_png(output_dir.path_join(filename)) == OK, "Captura guardada: " + filename)


func inspect_layout(final: bool) -> void:
	await RenderingServer.frame_post_draw
	var bounds := root.get_visible_rect()
	var panel: Control = hud.get_node("Panel")
	var label: Label = hud.get_node("Panel/Margin/Label")
	var on_screen := camera.unproject_position(player.global_position)
	expect(bounds.encloses(panel.get_global_rect()), "Panel de estado dentro de ventana")
	expect(label.size.x >= label.get_minimum_size().x and label.size.y >= label.get_minimum_size().y, "Texto de estado sin recorte")
	expect(not panel.get_global_rect().has_point(on_screen), "HUD no tapa al jugador")
	if final:
		expect(hud.result_panel.visible and bounds.encloses(hud.result_panel.get_global_rect()), "Panel final visible dentro de ventana")
		expect(not hud.result_panel.get_global_rect().has_point(on_screen), "Panel final deja visible al jugador")
		expect(hud.restart_button.visible and hud.restart_button.has_focus(), "Reiniciar accesible y con foco de teclado")
	else:
		expect(not hud.result_panel.visible and label.text.contains("Objetivo"), "Juego muestra objetivo sin panel final")


func check_fresh() -> void:
	await RenderingServer.frame_post_draw
	expect(arena.state == 0 and player.current_health == 100 and enemy.current_health == 80, "Reinicio vuelve a jugando con salud completa")
	expect(player.position.is_equal_approx(Vector3(0, 1.5, 0)) and enemy.position.is_equal_approx(Vector3(0, 1.5, -7)), "Reinicio recupera posiciones")
	expect(arena.get_node("Projectiles").get_child_count() == 0 and arena.get_node("Effects").get_child_count() == 0, "Reinicio sin proyectiles ni efectos")
	expect(player.get_node("Weapon").cooldown_remaining == 0 and player.get_node("PowerWeapon").cooldown_remaining == 0 and player.get_node("PulseAbility").cooldown_remaining == 0, "Reinicio recupera todas las recargas")
	expect(enemy.target == player and arena.find_children("*", "CharacterBody3D", true, false).size() == 2, "Reinicio sin actores duplicados y objetivo correcto")
	expect(not hud.result_panel.visible and hud.restart_requested.get_connections().size() == 1, "Una conexión de reinicio y panel oculto")


func restart(method: String) -> bool:
	var previous_id := arena.get_instance_id()
	if method == "R":
		key(KEY_R, true)
		key(KEY_R, true, true)
		key(KEY_R, false)
	elif method == "keyboard":
		key(KEY_ENTER, true)
		key(KEY_ENTER, true, true)
		key(KEY_ENTER, false)
	else:
		root.warp_mouse(hud.restart_button.get_global_rect().get_center())
		await ticks(2)
		click(true)
		await ticks(1)
		click(false)
	var changed := await until(func(): return is_instance_valid(current_scene) and current_scene.get_instance_id() != previous_id, 120)
	expect(changed, "Reinicio con %s crea nueva escena una vez" % method)
	if changed:
		bind_scene()
		await check_fresh()
	return changed


func play_to_result(victory: bool) -> bool:
	enemy.set_physics_process(true)
	if victory:
		root.warp_mouse(camera.unproject_position(enemy.global_position))
		await ticks(3)
		# E crea un efecto en vuelo; el cierre debe eliminar todos los remanentes.
		key(KEY_E, true)
		key(KEY_E, false)
		click(true)
	var ended := await until(func(): return arena.state != 0, 780)
	expect(ended and arena.state == (1 if victory else 2), "Resultado por combate real: " + ("victoria" if victory else "derrota"))
	if not ended:
		return false
	await ticks(2)
	return true


func check_closed() -> void:
	var before_player := player.position
	var before_enemy := enemy.position
	var health := Vector2i(player.current_health, enemy.current_health)
	var before_shots := shots_spawned
	var result_count := results.size()
	key(KEY_W, true)
	key(KEY_Q, true)
	key(KEY_E, true)
	click(true)
	# Comprobar también las API directas, no solo que se desactivó la entrada.
	player.get_node("Weapon").cooldown_remaining = 0.0
	player.get_node("PowerWeapon").cooldown_remaining = 0.0
	player.get_node("PulseAbility").cooldown_remaining = 0.0
	expect(not player.get_node("Weapon").try_fire(Vector3.FORWARD) and not player.get_node("PowerWeapon").try_fire(Vector3.FORWARD) and not player.get_node("PulseAbility").try_activate(), "Final bloquea básico/Q/E incluso por API")
	expect(not player.take_damage(1000, 2) and not enemy.take_damage(1000, 1), "Final bloquea daño pendiente/directo")
	await ticks(20)
	expect(player.position.is_equal_approx(before_player) and enemy.position.is_equal_approx(before_enemy), "Final bloquea movimiento de ambos actores")
	expect(Vector2i(player.current_health, enemy.current_health) == health and shots_spawned == before_shots, "Salud y ataques permanecen estables tras cierre")
	expect(results.size() == result_count and arena.get_node("Projectiles").get_child_count() == 0 and arena.get_node("Effects").get_child_count() == 0, "Señal final única y contenedores limpios")
	# W/Q/E/clic permanecen pulsados para comprobar el arrastre al reiniciar por R.


func release_controls() -> void:
	for code in [KEY_W, KEY_Q, KEY_E, KEY_R, KEY_ENTER]:
		key(code, false)
	click(false)
	await ticks(3)


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		printerr("T05 ventana requiere renderizado gráfico; headless no valida imagen ni GUI.")
		quit(1)
		return
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output-dir="):
			output_dir = argument.trim_prefix("--output-dir=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	scene_changed.connect(pause_reloaded_enemy)
	for size in [Vector2i(1280, 720), Vector2i(960, 540)]:
		root.size = size
		await ticks(3)
		expect(DisplayServer.window_get_size() == size, "Ventana nativa tiene tamaño %s" % size)
		arena = load("res://scenes/arena.tscn").instantiate()
		root.add_child(arena)
		current_scene = arena
		bind_scene()
		enemy.set_physics_process(false)
		await ticks(3)
		var suffix := "%dx%d-linux.png" % [size.x, size.y]
		await inspect_layout(false)
		await capture("T05-jugando-" + suffix, size)
		for cycle in range(3):
			var victory := cycle != 1
			if not await play_to_result(victory):
				quit(1)
				return
			await inspect_layout(true)
			expect(hud.result_title.text == ("VICTORIA" if victory else "DERROTA"), "Resultado inequívoco en panel final")
			if cycle < 2:
				await capture(("T05-victoria-" if victory else "T05-derrota-") + suffix, size)
			await check_closed()
			if cycle != 0:
				await release_controls()
			var method: String = ["R", "keyboard", "mouse"][cycle]
			if not await restart(method):
				quit(1)
				return
			if cycle == 0:
				await ticks(10)
				expect(player.position.is_equal_approx(Vector3(0, 1.5, 0)) and shots_spawned == 0, "Controles mantenidos no actúan tras R")
				await release_controls()
			await ticks(2)
		await release_controls()
		current_scene = null
		arena.queue_free()
		await ticks(2)
	expect(results == [1, 2, 1, 1, 2, 1], "Tres finales alternos únicos por resolución")
	print("T05 ventana: %d comprobaciones, %d fallos; capturas en %s" % [checks, failures, output_dir])
	quit(1 if failures else 0)
