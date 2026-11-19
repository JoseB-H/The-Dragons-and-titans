extends SceneTree
## V0.2: selección, combate y navegación reales en dos ventanas nativas.
## La IA solo se pausa al preparar cada arena; los resultados son combate real.

const ATLAS_SCENE := "res://scenes/world_menu.tscn"
const SELECTION_SCENE := "res://scenes/dragon_selection.tscn"
const ARENA_SCENE := "res://scenes/arena.tscn"
const PROFILES := {
	&"cobre": {"name": "Cobre", "health": 100, "speed": 6.0, "basic": 20, "basic_cd": 0.4, "q": 45, "q_cd": 2.5, "e": 30, "radius": 4.0, "e_cd": 4.0},
	&"jade": {"name": "Jade", "health": 70, "speed": 8.0, "basic": 15, "basic_cd": 0.3, "q": 35, "q_cd": 2.0, "e": 20, "radius": 3.5, "e_cd": 3.0},
}

var checks := 0
var failures := 0
var arena: Node3D
var player: Node3D
var enemy: Node3D
var camera: Camera3D
var hud: CanvasLayer
var roster: Node
var shots_spawned := 0
var results: Array[int] = []
var output_dir := "user://v02-validation"


func _initialize() -> void:
	create_timer(180.0).timeout.connect(func():
		printerr("FAIL: V0.2 ventana excedió el tiempo máximo de 180 s")
		quit(1)
	)
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


func until(condition: Callable, limit: int = 120) -> bool:
	for frame in range(limit):
		if condition.call():
			return true
		await ticks()
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
	# Los eventos usan píxeles nativos, como el cursor y la captura de pantalla.
	event.position = Vector2(DisplayServer.mouse_get_position() - DisplayServer.window_get_position())
	event.global_position = Vector2(DisplayServer.mouse_get_position())
	event.pressed = pressed
	Input.parse_input_event(event)


func release_controls() -> void:
	for code in [KEY_W, KEY_S, KEY_Q, KEY_E, KEY_R, KEY_ENTER, KEY_TAB]:
		key(code, false)
	click(false)
	await ticks(3)


func press_key(code: int) -> void:
	key(code, true)
	await ticks()
	key(code, false)
	await ticks()


func accept_and_hold() -> void:
	# BaseButton emite pressed al soltar Enter; una segunda pulsación rápida
	# queda mantenida durante el cambio para probar guardia y bloqueo de entrada.
	key(KEY_ENTER, true)
	key(KEY_ENTER, false)
	key(KEY_ENTER, true)
	key(KEY_ENTER, true, true)


func click_button(button: Button) -> void:
	root.warp_mouse(button.get_global_rect().get_center())
	await ticks(2)
	click(true)
	await ticks()
	click(false)
	await ticks()


func focus_with_tab(button: Button) -> bool:
	# Recorrer el orden de foco real también detecta tarjetas inaccesibles.
	for step in range(current_scene.find_children("*", "Button", true, false).size() + 1):
		if button.has_focus():
			return true
		await press_key(KEY_TAB)
	expect(false, "Tab alcanza el botón «%s»" % button.text)
	return false


func active_game_scene_count() -> int:
	var count := 0
	for child: Node in root.get_children():
		if child.scene_file_path in [ATLAS_SCENE, SELECTION_SCENE, ARENA_SCENE]:
			count += 1
	return count


func pause_new_enemy() -> void:
	if is_instance_valid(current_scene) and current_scene.has_node("Enemy"):
		current_scene.get_node("Enemy").set_physics_process(false)


func bind_arena() -> void:
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
	var screen := DisplayServer.screen_get_image(DisplayServer.window_get_current_screen())
	if screen == null:
		expect(false, "El backend permite capturar la ventana nativa")
		return
	var rectangle := Rect2i(DisplayServer.window_get_position(), DisplayServer.window_get_size())
	expect(Rect2i(Vector2i.ZERO, screen.get_size()).encloses(rectangle), "Ventana completamente dentro de la pantalla capturada")
	var frame := screen.get_region(rectangle)
	expect(frame.get_size() == size, "Captura física %s; observada %s" % [size, frame.get_size()])
	expect(frame.save_png(output_dir.path_join(filename)) == OK, "Captura guardada: " + filename)


func inspect_menu(profile_id: StringName) -> void:
	await RenderingServer.frame_post_draw
	var menu: Control = current_scene
	var bounds := root.get_visible_rect()
	expect(menu.scene_file_path == SELECTION_SCENE and active_game_scene_count() == 1, "Selector único, sin arena acumulada")
	expect(menu.selected_profile_id() == profile_id and roster.selected_id == profile_id, "Selector y catálogo conservan elección %s" % profile_id)
	for control: Control in menu.find_children("*", "Control", true, false):
		if control.is_visible_in_tree():
			expect(bounds.encloses(control.get_global_rect()), "Menú muestra «%s» dentro de ventana" % control.name)
			if control is Label or control is Button:
				expect(control.size.x >= control.get_minimum_size().x and control.size.y >= control.get_minimum_size().y, "Menú no recorta «%s»" % control.name)
	expect(menu.details.text.contains(PROFILES[profile_id].name), "Detalles identifican el dragón elegido")
	expect(menu.play_button.focus_mode == Control.FOCUS_ALL and not menu.play_button.disabled, "Jugar accesible por teclado y habilitado")


func choose_profile(profile_id: StringName, method: String) -> bool:
	var menu: Control = current_scene
	var button: Button = menu.copper_button if profile_id == &"cobre" else menu.jade_button
	if method == "mouse":
		await click_button(button)
	else:
		if not await focus_with_tab(button):
			return false
		await press_key(KEY_ENTER)
	expect(current_scene == menu and menu.selected_profile_id() == profile_id and roster.selected_id == profile_id, "Elegir %s mediante %s actualiza selección sin iniciar" % [profile_id, method])
	return menu.selected_profile_id() == profile_id


func start_match(profile_id: StringName, method: String) -> bool:
	var menu: Control = current_scene
	var old_menu: WeakRef = weakref(menu)
	if method == "keyboard":
		if not await focus_with_tab(menu.play_button):
			return false
		# Mantener Enter y su eco durante la navegación no debe encadenar escenas.
		accept_and_hold()
	else:
		await click_button(menu.play_button)
	var changed := await until(func(): return is_instance_valid(current_scene) and current_scene.scene_file_path == ARENA_SCENE)
	expect(changed, "Jugar con %s abre la arena de %s" % [method, profile_id])
	if not changed:
		return false
	bind_arena()
	var arena_id := arena.get_instance_id()
	await ticks(10)
	expect(current_scene.get_instance_id() == arena_id and old_menu.get_ref() == null and active_game_scene_count() == 1, "Jugar cambia escena una vez y libera selector")
	expect(player.position.is_equal_approx(Vector3(0, 1.5, 0)) and shots_spawned == 0, "Entrada mantenida al entrar no mueve ni dispara")
	await release_controls()
	await check_fresh(profile_id)
	var previous_id := arena.get_instance_id()
	expect(arena.return_to_selection() != OK, "Volver a elegir se rechaza mientras se juega")
	await ticks(2)
	expect(current_scene.get_instance_id() == previous_id and arena.state == 0, "Retorno rechazado conserva partida en curso")
	return true


func inspect_arena(final: bool, profile_id: StringName) -> void:
	await RenderingServer.frame_post_draw
	var bounds := root.get_visible_rect()
	var panel: Control = hud.get_node("Panel")
	var label: Label = hud.get_node("Panel/Margin/Label")
	var on_screen := camera.unproject_position(player.global_position)
	expect(bounds.encloses(panel.get_global_rect()), "HUD dentro de ventana para %s" % profile_id)
	expect(label.size.x >= label.get_minimum_size().x and label.size.y >= label.get_minimum_size().y, "HUD sin texto cortado para %s" % profile_id)
	expect(bounds.has_point(on_screen) and not camera.is_position_behind(player.global_position) and not panel.get_global_rect().has_point(on_screen), "Jugador %s visible sin HUD encima" % profile_id)
	expect(label.text.contains(PROFILES[profile_id].name) and label.text.contains("Objetivo") and label.text.contains("WASD") and label.text.contains("Q:") and label.text.contains("E:"), "HUD conserva identidad, objetivo, controles y habilidades")
	if final:
		expect(hud.result_panel.visible and bounds.encloses(hud.result_panel.get_global_rect()), "Panel final visible dentro de ventana")
		expect(not hud.result_panel.get_global_rect().has_point(on_screen), "Panel final deja visible al dragón")
		expect(hud.restart_button.is_visible_in_tree() and hud.restart_button.has_focus(), "Final enfoca Reiniciar para teclado")
		expect(hud.selection_button.is_visible_in_tree() and bounds.encloses(hud.selection_button.get_global_rect()), "Elegir dragón visible dentro del final")
		expect(hud.result_title.text == ("VICTORIA" if arena.state == 1 else "DERROTA"), "Resultado inequívoco en panel final")
	else:
		expect(not hud.result_panel.visible and not hud.selection_button.is_visible_in_tree(), "Jugar muestra HUD sin acciones finales")


func check_fresh(profile_id: StringName) -> void:
	await RenderingServer.frame_post_draw
	var data: Dictionary = PROFILES[profile_id]
	var basic: Node = player.get_node("Weapon")
	var power: Node = player.get_node("PowerWeapon")
	var pulse: Node = player.get_node("PulseAbility")
	expect(arena.scene_file_path == ARENA_SCENE and arena.state == 0 and active_game_scene_count() == 1, "Reinicio vuelve a una sola arena jugando")
	expect(player.profile_id == profile_id and player.profile_name == data.name and roster.selected_id == profile_id, "Arena aplica y conserva perfil %s" % profile_id)
	expect(player.current_health == data.health and player.max_health == data.health and enemy.current_health == 80, "Salud completa propia de %s al iniciar/reiniciar" % profile_id)
	expect(is_equal_approx(player.movement_speed, data.speed), "Velocidad aplicada de %s" % profile_id)
	expect(basic.damage == data.basic and is_equal_approx(basic.cooldown, data.basic_cd) and power.damage == data.q and is_equal_approx(power.cooldown, data.q_cd), "Básico/Q aplican datos del perfil %s" % profile_id)
	expect(pulse.damage == data.e and is_equal_approx(pulse.radius, data.radius) and is_equal_approx(pulse.cooldown, data.e_cd), "E aplica daño, radio y recarga del perfil %s" % profile_id)
	expect(player.position.is_equal_approx(Vector3(0, 1.5, 0)) and enemy.position.is_equal_approx(Vector3(0, 1.5, -7)), "Reinicio recupera posiciones")
	expect(arena.get_node("Projectiles").get_child_count() == 0 and arena.get_node("Effects").get_child_count() == 0 and shots_spawned == 0, "Reinicio sin proyectiles ni efectos heredados")
	expect(basic.cooldown_remaining == 0 and power.cooldown_remaining == 0 and pulse.cooldown_remaining == 0 and enemy.get_node("Weapon").cooldown_remaining == 0, "Reinicio recupera todas las recargas")
	expect(enemy.target == player and arena.find_children("*", "CharacterBody3D", true, false).size() == 2, "Dos actores y objetivo correcto sin acumulación")
	expect(not hud.result_panel.visible and hud.restart_requested.get_connections().size() == 1 and hud.selection_requested.get_connections().size() == 1, "Panel oculto y conexiones de navegación únicas")


func exercise_movement_and_projectiles(profile_id: StringName) -> void:
	var origin := player.position
	key(KEY_W, true)
	await ticks(10)
	key(KEY_W, false)
	var distance := player.position.distance_to(origin)
	var expected_distance: float = PROFILES[profile_id].speed * 10.0 / Engine.physics_ticks_per_second
	expect(absf(distance - expected_distance) < 0.3, "W mueve a %s a la velocidad de su perfil" % profile_id)
	key(KEY_S, true)
	await ticks(10)
	key(KEY_S, false)
	await ticks(3)
	expect(player.position.distance_to(origin) < 0.3, "Movimiento opuesto recupera posición sin deriva")
	root.warp_mouse(camera.unproject_position(enemy.global_position))
	await ticks(3)
	click(true)
	await ticks()
	click(false)
	var after_basic: int = 80 - PROFILES[profile_id].basic
	expect(await until(func(): return enemy.current_health == after_basic, 90), "Básico de %s aplica daño por impacto real" % profile_id)
	key(KEY_Q, true)
	await ticks()
	key(KEY_Q, false)
	var after_q: int = after_basic - PROFILES[profile_id].q
	expect(await until(func(): return enemy.current_health == after_q, 90), "Q de %s aplica daño por impacto real" % profile_id)
	expect(player.current_health == PROFILES[profile_id].health and arena.state == 0, "Proyectiles propios no dañan al emisor ni cierran antes de vencer")


func exercise_pulse(profile_id: StringName) -> void:
	# Fixture espacial: daño y cierre siguen en las rutas reales, sin alterar salud.
	enemy.position = player.position + Vector3(0, 0, -3)
	enemy.reset_physics_interpolation()
	await ticks(2)
	key(KEY_E, true)
	await ticks()
	key(KEY_E, false)
	expect(enemy.current_health == 80 - PROFILES[profile_id].e, "E de %s causa su daño real dentro del radio" % profile_id)
	expect(player.get_node("PulseAbility").cooldown_remaining > 0 and arena.get_node("Effects").get_child_count() == 1, "E muestra efecto temporal y consume su recarga")
	await ticks(2)
	expect(enemy.current_health == 80 - PROFILES[profile_id].e, "El efecto visible no repite daño")


func play_to_result(victory: bool) -> bool:
	enemy.set_physics_process(true)
	if victory:
		root.warp_mouse(camera.unproject_position(enemy.global_position))
		await ticks(3)
		click(true)
	var ended := await until(func(): return arena.state != 0, 780)
	expect(ended and arena.state == (1 if victory else 2), "Resultado por combate real: " + ("victoria" if victory else "derrota"))
	if ended:
		await ticks(2)
	return ended


func check_closed() -> void:
	var positions := [player.position, enemy.position]
	var health := Vector2i(player.current_health, enemy.current_health)
	var before_shots := shots_spawned
	var result_count := results.size()
	key(KEY_W, true)
	key(KEY_Q, true)
	key(KEY_E, true)
	click(true)
	player.get_node("Weapon").cooldown_remaining = 0.0
	player.get_node("PowerWeapon").cooldown_remaining = 0.0
	player.get_node("PulseAbility").cooldown_remaining = 0.0
	expect(not player.get_node("Weapon").try_fire(Vector3.FORWARD) and not player.get_node("PowerWeapon").try_fire(Vector3.FORWARD) and not player.get_node("PulseAbility").try_activate(), "Final bloquea básico/Q/E incluso por API")
	expect(not player.take_damage(1000, 2) and not enemy.take_damage(1000, 1), "Final bloquea daño directo o pendiente")
	await ticks(12)
	expect(player.position.is_equal_approx(positions[0]) and enemy.position.is_equal_approx(positions[1]), "Final bloquea movimiento de ambos actores")
	expect(Vector2i(player.current_health, enemy.current_health) == health and shots_spawned == before_shots, "Salud y ataques permanecen estables al terminar")
	expect(results.size() == result_count and arena.get_node("Projectiles").get_child_count() == 0 and arena.get_node("Effects").get_child_count() == 0, "Final único limpia proyectiles y efectos")
	# W/Q/E/clic continúan pulsados para la comprobación de reinicio con R.


func restart(profile_id: StringName, method: String, held: bool) -> bool:
	var previous: WeakRef = weakref(arena)
	var previous_id := arena.get_instance_id()
	if method == "R":
		key(KEY_R, true)
		key(KEY_R, true, true)
		key(KEY_R, false)
	elif method == "keyboard":
		if not await focus_with_tab(hud.restart_button):
			return false
		accept_and_hold()
	else:
		await click_button(hud.restart_button)
	var changed := await until(func(): return is_instance_valid(current_scene) and current_scene.get_instance_id() != previous_id)
	expect(changed, "Reinicio de %s con %s crea nueva escena" % [profile_id, method])
	if not changed:
		return false
	bind_arena()
	var reloaded_id := arena.get_instance_id()
	await ticks(10)
	expect(current_scene.get_instance_id() == reloaded_id and previous.get_ref() == null, "Reinicio libera escena anterior y no se encadena por eco/hold")
	if held or method == "keyboard":
		expect(player.position.is_equal_approx(Vector3(0, 1.5, 0)) and shots_spawned == 0 and arena.get_node("Effects").get_child_count() == 0, "Controles mantenidos no actúan tras reiniciar")
	await release_controls()
	await check_fresh(profile_id)
	return true


func return_to_menu(profile_id: StringName, method: String) -> bool:
	var old_arena: WeakRef = weakref(arena)
	if method == "keyboard":
		if not await focus_with_tab(hud.selection_button):
			return false
		accept_and_hold()
	else:
		await click_button(hud.selection_button)
	var changed := await until(func(): return is_instance_valid(current_scene) and current_scene.scene_file_path == SELECTION_SCENE)
	expect(changed, "Elegir dragón tras final vuelve al selector con %s" % method)
	if not changed:
		return false
	var menu: Control = current_scene
	var menu_id := menu.get_instance_id()
	await ticks(10)
	expect(is_instance_valid(current_scene) and current_scene.get_instance_id() == menu_id and old_arena.get_ref() == null, "Retorno libera arena y Enter/clic no inicia otra partida")
	await release_controls()
	await inspect_menu(profile_id)
	var selected_button: Button = menu.copper_button if profile_id == &"cobre" else menu.jade_button
	expect(selected_button.has_focus(), "Volver al selector enfoca tarjeta de %s" % profile_id)
	return true


func open_equipment_from_atlas() -> bool:
	var entry: String = ProjectSettings.get_setting("application/run/main_scene")
	expect(entry == ATLAS_SCENE, "La escena inicial es el atlas")
	if entry != ATLAS_SCENE or change_scene_to_file(entry) != OK:
		return false
	await scene_changed
	await ticks(3)
	for button: Button in current_scene.find_children("*", "Button", true, false):
		if button.text == "Dragones y equipo":
			await click_button(button)
			var opened := await until(func(): return is_instance_valid(current_scene) and current_scene.scene_file_path == SELECTION_SCENE)
			expect(opened, "Dragones y equipo abre el selector desde el atlas")
			return opened
	expect(false, "El atlas ofrece Dragones y equipo")
	return false


func _run() -> void:
	# Esta precondición permite observar RED sin un servidor gráfico previo.
	expect(ResourceLoader.exists(SELECTION_SCENE), "V0.2 requiere una escena de selección antes del combate")
	if failures:
		quit(1)
		return
	if DisplayServer.get_name() == "headless":
		printerr("V0.2 ventana requiere renderizado gráfico; headless no valida imagen ni GUI.")
		quit(1)
		return
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output-dir="):
			output_dir = argument.trim_prefix("--output-dir=")
	expect(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir)) == OK, "Directorio de capturas disponible")
	roster = root.get_node_or_null("DragonRoster")
	expect(roster != null, "Catálogo DragonRoster disponible antes del menú")
	if roster == null:
		quit(1)
		return
	expect(roster.selected_id == &"cobre", "Sesión nueva comienza con Cobre")
	scene_changed.connect(pause_new_enemy)
	if not await open_equipment_from_atlas():
		quit(1)
		return
	for size in [Vector2i(1280, 720), Vector2i(960, 540)]:
		root.size = size
		await ticks(3)
		expect(DisplayServer.window_get_size() == size, "Ventana nativa tiene tamaño %s" % size)
		var suffix := "%dx%d-linux.png" % [size.x, size.y]
		for profile_id: StringName in [&"cobre", &"jade"]:
			# Ambos perfiles se eligen con ratón y teclado en cada resolución.
			var other_id: StringName = &"jade" if profile_id == &"cobre" else &"cobre"
			if not await choose_profile(other_id, "mouse") or not await choose_profile(profile_id, "mouse"):
				quit(1)
				return
			if not await choose_profile(other_id, "keyboard") or not await choose_profile(profile_id, "keyboard"):
				quit(1)
				return
			await inspect_menu(profile_id)
			await capture("V02-selector-%s-%s" % [profile_id, suffix], size)
			if not await start_match(profile_id, "keyboard" if profile_id == &"cobre" else "mouse"):
				quit(1)
				return
			await inspect_arena(false, profile_id)
			await capture("V02-%s-jugando-%s" % [profile_id, suffix], size)
			for cycle in range(3):
				if cycle == 0:
					await exercise_movement_and_projectiles(profile_id)
				elif cycle == 2:
					await exercise_pulse(profile_id)
				var victory := cycle != 1
				if not await play_to_result(victory):
					quit(1)
					return
				await inspect_arena(true, profile_id)
				if cycle < 2:
					await capture("V02-%s-%s-%s" % [profile_id, "victoria" if victory else "derrota", suffix], size)
				await check_closed()
				if cycle != 0:
					await release_controls()
				var method := "R" if cycle != 1 else ("keyboard" if profile_id == &"cobre" else "mouse")
				if not await restart(profile_id, method, cycle == 0):
					quit(1)
					return
			# El tercer reinicio también se juega antes de volver y cambiar perfil.
			if not await play_to_result(true):
				quit(1)
				return
			await check_closed()
			await release_controls()
			if not await return_to_menu(profile_id, "mouse" if profile_id == &"cobre" else "keyboard"):
				quit(1)
				return
		# El cambio Jade→Cobre prueba el retorno y deja el valor legado al cerrar.
		if not await choose_profile(&"cobre", "mouse"):
			quit(1)
			return
	expect(results == [1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1], "Cuatro resultados únicos por perfil y resolución, sin señales acumuladas")
	expect(roster.selected_id == &"cobre" and current_scene.selected_profile_id() == &"cobre", "Suite deja Cobre seleccionado")
	print("V0.2 ventana: %d comprobaciones, %d fallos; capturas en %s" % [checks, failures, output_dir])
	quit(1 if failures else 0)
