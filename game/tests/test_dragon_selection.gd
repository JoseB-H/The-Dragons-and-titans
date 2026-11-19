extends SceneTree
## V0.2 T01: selección real, datos visibles, accesibilidad y navegación única.

var checks := 0
var failures := 0
var selection_scene: PackedScene
var roster: Node


func _initialize() -> void:
	create_timer(30.0).timeout.connect(func():
		printerr("FAIL: selector excedió 30 s")
		quit(1)
	)
	_run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func frames(count: int = 2) -> void:
	for frame in range(count):
		await process_frame


func key(code: int, pressed: bool, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func click_button(button: Button) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = button.get_global_rect().get_center()
		event.global_position = event.position
		event.pressed = pressed
		root.push_input(event, true)


func make_selection() -> Control:
	var selection: Control = selection_scene.instantiate()
	root.add_child(selection)
	current_scene = selection
	return selection


func expected_stats(profile: Resource) -> Array[String]:
	return [
		"Salud: %s" % profile.max_health,
		"Velocidad: %s" % String.num(profile.movement_speed, 2),
		"Básico: %s daño · %s s" % [profile.basic_damage, String.num(profile.basic_cooldown, 2)],
		"Q: %s daño · %s s" % [profile.power_damage, String.num(profile.power_cooldown, 2)],
		"E: %s daño · radio %s · %s s" % [profile.pulse_damage, String.num(profile.pulse_radius, 2), String.num(profile.pulse_cooldown, 2)]
	]


func test_selection_and_data() -> void:
	roster.select_dragon(&"cobre")
	var selection := make_selection()
	await frames()
	expect(selection.selected_profile_id() == &"cobre", "La primera elección es Cobre")
	expect(selection.copper_button.has_focus(), "La tarjeta elegida recibe foco inicial; Jugar no recibe Enter retenido")
	for profile: Resource in roster.get_profiles():
		var button: Button = selection.copper_button if profile.id == &"cobre" else selection.jade_button
		expect(button.text.contains(profile.display_name) and button.text.contains(profile.description), "Tarjeta presenta identidad y descripción del recurso %s" % profile.id)
		for stat in expected_stats(profile):
			expect(button.text.contains(stat), "Comparación presenta %s para %s" % [stat, profile.id])
		expect(selection.select_profile(profile.id), "La API permite elegir %s" % profile.id)
		expect(selection.selected_profile_id() == profile.id and roster.selected_id == profile.id, "La elección visible coincide con catálogo %s" % profile.id)
		expect(button.button_pressed, "La tarjeta %s anuncia su selección" % profile.id)
		expect(selection.play_button.text.contains(profile.display_name), "Jugar muestra el dragón elegido %s" % profile.id)
		expect(selection.details.text.contains(profile.display_name) and selection.details.text.contains("provisional"), "Detalle declara selección y balance provisional para %s" % profile.id)
	expect(not selection.select_profile(&"desconocido"), "Se rechaza una opción desconocida")
	expect(selection.selected_profile_id() == &"jade" and selection.jade_button.button_pressed, "Rechazar opción conserva elección y tarjeta Jade")
	selection.copper_button.pressed.emit()
	expect(selection.selected_profile_id() == &"cobre", "Pulsar tarjeta Cobre cambia la elección")
	selection.jade_button.pressed.emit()
	expect(selection.selected_profile_id() == &"jade", "Pulsar tarjeta Jade cambia la elección")
	selection.free()
	selection = make_selection()
	await frames()
	expect(selection.selected_profile_id() == &"jade" and selection.jade_button.has_focus(), "Regresar conserva Jade y enfoca su tarjeta")
	key(KEY_ENTER, true, true)
	await frames()
	expect(current_scene == selection, "Enter repetido al volver no inicia otra partida")
	key(KEY_ENTER, false)
	var another: Control = selection_scene.instantiate()
	root.add_child(another)
	expect(selection.copper_button.button_group != another.copper_button.button_group, "Cada selector posee su grupo de elección")
	expect(selection.copper_button.get_theme_stylebox("normal") != another.copper_button.get_theme_stylebox("normal"), "Cada selector posee sus estilos de UI")
	another.free()
	selection.free()
	roster.select_dragon(&"cobre")


func test_keyboard_and_layout() -> void:
	var selection := make_selection()
	await frames()
	key(KEY_TAB, true)
	key(KEY_TAB, false)
	await frames()
	expect(selection.jade_button.has_focus(), "Tab recorre Cobre a Jade")
	key(KEY_SPACE, true)
	key(KEY_SPACE, false)
	await frames()
	expect(selection.selected_profile_id() == &"jade", "Espacio elige la tarjeta enfocada")
	selection.copper_button.grab_focus()
	key(KEY_ENTER, true)
	key(KEY_ENTER, false)
	await frames()
	expect(selection.selected_profile_id() == &"cobre" and current_scene == selection, "Enter en tarjeta selecciona sin comenzar combate")
	click_button(selection.jade_button)
	await frames()
	expect(selection.selected_profile_id() == &"jade", "El ratón elige Jade sin iniciar la partida")
	click_button(selection.copper_button)
	await frames()
	expect(selection.selected_profile_id() == &"cobre", "El ratón vuelve a elegir Cobre")
	for size: Vector2i in [Vector2i(1280, 720), Vector2i(960, 540)]:
		root.size = size
		await frames()
		var bounds := selection.get_global_rect()
		for control: Control in [selection.copper_button, selection.jade_button, selection.play_button, selection.details]:
			expect(bounds.encloses(control.get_global_rect()), "Control %s visible dentro de %s" % [control.name, size])
			expect(control.size.x >= control.get_combined_minimum_size().x and control.size.y >= control.get_combined_minimum_size().y, "Control %s muestra su contenido completo a %s" % [control.name, size])
	root.size = Vector2i(1280, 720)
	selection.free()
	roster.select_dragon(&"cobre")


func test_immediate_navigation() -> void:
	roster.select_dragon(&"cobre")
	var selection := make_selection()
	# Una navegación iniciada en el mismo turno no deja callbacks de foco pendientes.
	expect(selection.copper_button.has_focus(), "El foco inicial está listo antes de navegar en el mismo turno")
	expect(selection.start_match() == OK, "Se puede comenzar sin esperar otro fotograma del selector")
	await scene_changed
	var arena: Node3D = current_scene
	arena.get_node("Dragon").set_physics_process(false)
	arena.get_node("Enemy").set_physics_process(false)
	await frames()
	expect(arena.scene_file_path == "res://scenes/arena.tscn", "La salida inmediata abre Arena sin tareas pendientes del selector")
	arena.free()
	roster.select_dragon(&"cobre")


func test_navigation_once() -> void:
	roster.select_dragon(&"jade")
	var selection := make_selection()
	await frames()
	var old_scene: WeakRef = weakref(selection)
	var scene_changes: Array[bool] = []
	var on_change := func(): scene_changes.append(true)
	scene_changed.connect(on_change)
	# Entrada retenida del menú se captura en el controlador de producción.
	Input.action_press("ui_accept")
	Input.action_press("attack")
	Input.action_press("move_forward")
	selection.play_button.pressed.emit()
	expect(selection.start_match() == OK and selection.start_match() == OK, "El botón Jugar y solicitudes rápidas admiten una sola navegación")
	await scene_changed
	var arena: Node3D = current_scene
	arena.get_node("Dragon").set_physics_process(false)
	arena.get_node("Enemy").set_physics_process(false)
	expect(arena.scene_file_path == "res://scenes/arena.tscn" and old_scene.get_ref() == null, "Jugar carga Arena y libera selector")
	expect(roster.selected_id == &"jade", "Navegar conserva el perfil elegido")
	var player: Node3D = arena.get_node("Dragon")
	var initial := player.position
	player._physics_process(0.1)
	expect(player.waiting_for_release() and player.position.is_equal_approx(initial), "Clic/Enter/movimiento retenidos no actúan al comenzar")
	expect(arena.get_node("Projectiles").get_child_count() == 0, "El clic de Jugar no dispara un ataque")
	await frames(4)
	expect(scene_changes.size() == 1 and current_scene == arena, "No se duplica la navegación en fotogramas posteriores")
	scene_changed.disconnect(on_change)
	for action: String in ["ui_accept", "attack", "move_forward"]:
		Input.action_release(action)
	arena.free()
	roster.select_dragon(&"cobre")


func finish() -> void:
	if is_instance_valid(roster):
		roster.select_dragon(&"cobre")
	print("V0.2 selector: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)


func _run() -> void:
	expect(ResourceLoader.exists("res://scenes/dragon_selection.tscn"), "Existe una pantalla de selección ejecutable antes de Arena")
	if failures:
		finish()
		return
	selection_scene = load("res://scenes/dragon_selection.tscn")
	roster = root.get_node_or_null("DragonRoster")
	expect(roster != null, "El catálogo de producción está registrado como autoload")
	if failures:
		finish()
		return
	await test_selection_and_data()
	await test_immediate_navigation()
	await test_keyboard_and_layout()
	await test_navigation_once()
	finish()
