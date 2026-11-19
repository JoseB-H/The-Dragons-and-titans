extends SceneTree
## Ventana T04: entradas físicas, cursor, daño y renderizado reales; IA aislada.

var checks := 0
var failures := 0
var shots_spawned := 0
var arena: Node3D
var player: Node3D
var enemy: Node3D
var camera: Camera3D
var q: Node3D
var e: Node3D
var label: Label
var output_dir := "user://t04-validation"


func _initialize() -> void:
	_run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func key(code: int, pressed: bool, echo := false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)


func click(pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = root.get_mouse_position()
	event.pressed = pressed
	Input.parse_input_event(event)


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


func pause_fixture() -> void:
	# Aislar habilidades del cierre T05 tras _ready y en cada recarga con R.
	if is_instance_valid(current_scene) and current_scene.has_node("Enemy"):
		current_scene.set_physics_process(false)
		current_scene.get_node("Enemy").set_physics_process(false)


func bind_scene() -> void:
	arena = current_scene
	arena.set_physics_process(false)
	player = arena.get_node("Dragon")
	enemy = arena.get_node("Enemy")
	enemy.set_physics_process(false)
	camera = player.get_node("Camera")
	q = player.get_node("PowerWeapon")
	e = player.get_node("PulseAbility")
	label = arena.get_node("Controls/Panel/Margin/Label")
	shots_spawned = 0
	arena.get_node("Projectiles").child_entered_tree.connect(func(_node: Node): shots_spawned += 1)


func capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	expect(root.get_texture().get_image().save_png(output_dir.path_join(filename)) == OK, "Captura guardada: " + filename)


func restore_with_key() -> bool:
	var previous_id := arena.get_instance_id()
	key(KEY_R, true)
	key(KEY_R, false)
	for frame in range(120):
		await process_frame
		if is_instance_valid(current_scene) and current_scene.get_instance_id() != previous_id:
			bind_scene()
			await ticks(2)
			return true
	return false


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		printerr("T04 ventana requiere X11/Wayland/Windows; headless no valida imagen.")
		quit(1)
		return
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output-dir="):
			output_dir = argument.trim_prefix("--output-dir=")
	expect(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir)) == OK, "Directorio de capturas disponible")
	scene_changed.connect(pause_fixture)
	arena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(arena)
	arena.set_physics_process(false)
	current_scene = arena
	bind_scene()
	await ticks(3)
	for binding in [["ability_q", KEY_Q], ["ability_e", KEY_E]]:
		expect(InputMap.action_get_events(binding[0]).any(func(event): return event is InputEventKey and event.physical_keycode == binding[1]), "Input Map físico: " + binding[0])
	expect(q.damage == 45 and q.projectile_speed == 36.0 and q.projectile_lifetime == 2.0 and q.cooldown == 2.5, "Datos Q provisionales 45/36/2/2.5")
	expect(e.damage == 30 and e.radius == 4.0 and e.cooldown == 4.0 and e.effect_duration == 0.5, "Datos E provisionales 30/4/4/0.5")
	expect(label.is_visible_in_tree() and label.text.contains("Q: LISTA") and label.text.contains("E: LISTA"), "HUD muestra ambas habilidades listas")
	key(KEY_Q, true, true)
	key(KEY_E, true, true)
	await ticks(2)
	key(KEY_Q, false)
	key(KEY_E, false)
	expect(shots_spawned == 0 and q.cooldown_remaining == 0 and e.cooldown_remaining == 0 and arena.get_node("Effects").get_child_count() == 0, "Eco inicial no activa habilidades ni consume recargas")
	# Q conserva velocidad real; -7 deja visible el vuelo antes del impacto.
	Input.warp_mouse(camera.unproject_position(enemy.global_position))
	await ticks(2)
	expect((-player.get_node("Facing").global_basis.z).dot((enemy.global_position - player.global_position).normalized()) > 0.999, "Cursor real apunta Q al enemigo")
	key(KEY_Q, true)
	await ticks(1)
	var projectiles := arena.get_node("Projectiles").get_children()
	expect(shots_spawned == 1 and projectiles.size() == 1 and root.get_visible_rect().has_point(camera.unproject_position(projectiles[0].global_position)) and q.cooldown_remaining > 0, "Q física crea proyectil potente visible")
	if not projectiles.is_empty():
		var color: Color = projectiles[0].get_node("Visual").mesh.material.albedo_color
		expect(color.r > 0.7 and color.b > 0.7 and color.g < 0.3, "Q usa material magenta propio")
	expect(e.cooldown_remaining == 0 and player.get_node("Weapon").cooldown_remaining == 0, "Q conserva recargas independientes")
	await capture("T04-proyectil-potente-linux.png")
	expect(await until(func(): return enemy.current_health == 35, 90), "Q causa 45 mediante impacto real")
	await ticks(3)
	expect(enemy.current_health == 35 and player.current_health == 100, "Q aplica daño único y conserva al emisor")
	# Solo se acorta el tiempo pendiente en el montaje para comprobar el hold.
	q.cooldown_remaining = 0.08
	expect(await until(func(): return q.cooldown_remaining == 0, 30), "Q recupera disponibilidad dentro del límite")
	await ticks(3)
	expect(shots_spawned == 1 and label.text.contains("Q: LISTA"), "Mantener Q no vuelve a disparar al acabar la recarga")
	key(KEY_Q, true, true)
	await ticks(2)
	expect(shots_spawned == 1 and q.cooldown_remaining == 0, "Eco Q lista no reactiva")
	key(KEY_Q, false)
	await ticks(1)
	# Enemigo a distancia XZ 3: E transforma 35 en 5; apuntar fuera evita matarlo.
	enemy.position = Vector3(0, 1.5, -3)
	Input.warp_mouse(camera.unproject_position(Vector3(7, 1.5, 0)))
	await ticks(2)
	key(KEY_Q, true)
	await ticks(1)
	key(KEY_Q, false)
	key(KEY_E, true)
	click(true)
	await ticks(1)
	click(false)
	expect(enemy.current_health == 5 and e.cooldown_remaining > 0 and arena.get_node("Effects").get_child_count() == 1, "E física aplica 30 y muestra anillo temporal")
	if arena.get_node("Effects").get_child_count() > 0:
		var pulse: Node3D = arena.get_node("Effects").get_child(0)
		expect(pulse.global_position.is_equal_approx(player.global_position) and pulse.get_node("Visual").mesh is TorusMesh, "Anillo real centrado en el jugador")
	expect(shots_spawned == 3 and player.get_node("Weapon").cooldown_remaining > 0, "Básico, Q y E funcionan con recargas independientes")
	# process_frame precede a Arena._process: leer el HUD cuando ya se ha dibujado.
	await RenderingServer.frame_post_draw
	var cooldown_pattern := RegEx.create_from_string("Q: [0-9]+\\.[0-9] s · E: [0-9]+\\.[0-9] s")
	expect(cooldown_pattern.search(label.text) != null and not label.text.contains("LISTA"), "HUD presenta segundos de ambas recargas; texto observado: " + label.text)
	await capture("T04-pulso-y-recargas-linux.png")
	key(KEY_E, false)
	key(KEY_Q, true)
	await ticks(1)
	key(KEY_Q, false)
	key(KEY_E, true)
	await ticks(1)
	expect(shots_spawned == 3 and enemy.current_health == 5 and arena.get_node("Effects").get_child_count() == 1, "Pulsaciones durante recarga no crean ataques ni efectos")
	expect(await until(func(): return arena.get_node("Effects").get_child_count() == 0, 90), "El anillo se elimina al terminar")
	expect(enemy.current_health == 5, "Duración del pulso no repite daño")
	q.cooldown_remaining = 0.08
	e.cooldown_remaining = 0.08
	expect(await until(func(): return q.cooldown_remaining == 0 and e.cooldown_remaining == 0, 30), "Ambas recargas terminan dentro del límite")
	await ticks(3)
	expect(enemy.current_health == 5 and arena.get_node("Effects").get_child_count() == 0 and shots_spawned == 3, "Mantener E no reactiva al acabar la recarga")
	expect(label.text.contains("Q: LISTA") and label.text.contains("E: LISTA"), "HUD vuelve a LISTA tras ambas recargas")
	key(KEY_E, true, true)
	await ticks(2)
	expect(e.cooldown_remaining == 0 and enemy.current_health == 5, "Eco E lista no reactiva")
	key(KEY_E, false)
	player.take_damage(100, enemy.faction)
	key(KEY_Q, true)
	key(KEY_E, true)
	await ticks(2)
	key(KEY_Q, false)
	key(KEY_E, false)
	expect(q.cooldown_remaining == 0 and e.cooldown_remaining == 0 and shots_spawned == 3, "Jugador muerto bloquea Q/E sin consumir recargas")
	expect(label.text.contains("Q: BLOQUEADA") and label.text.contains("E: BLOQUEADA"), "HUD comunica bloqueo por muerte")
	for iteration in range(3):
		player.current_health = 100
		enemy.current_health = 80
		player.position = Vector3(3, 1.5, 3)
		enemy.position = Vector3(-3, 1.5, -3)
		Input.warp_mouse(camera.unproject_position(Vector3(8, 1.5, 6)))
		await ticks(2)
		key(KEY_Q, true)
		key(KEY_E, true)
		click(true)
		await ticks(1)
		key(KEY_Q, false)
		key(KEY_E, false)
		click(false)
		expect(arena.get_node("Projectiles").get_child_count() >= 2 and arena.get_node("Effects").get_child_count() == 1 and q.cooldown_remaining > 0 and e.cooldown_remaining > 0, "Fixture %d tiene proyectiles, efecto y recargas activos" % (iteration + 1))
		var old_player := player.get_instance_id()
		var restored := await restore_with_key()
		expect(restored, "R física restaura arena %d dentro del límite" % (iteration + 1))
		if not restored:
			quit(1)
			return
		expect(player.get_instance_id() != old_player and player.current_health == 100 and enemy.current_health == 80, "Restauración %d crea actores nuevos con salud 100/80" % (iteration + 1))
		expect(player.position.is_equal_approx(Vector3(0, 1.5, 0)) and enemy.position.is_equal_approx(Vector3(0, 1.5, -7)), "Restauración %d repone posiciones" % (iteration + 1))
		expect(arena.get_node("Projectiles").get_child_count() == 0 and arena.get_node("Effects").get_child_count() == 0 and q.cooldown_remaining == 0 and e.cooldown_remaining == 0 and player.get_node("Weapon").cooldown_remaining == 0 and enemy.get_node("Weapon").cooldown_remaining == 0, "Restauración %d limpia nodos y todas las recargas" % (iteration + 1))
		expect(label.text.contains("Q: LISTA") and label.text.contains("E: LISTA"), "Restauración %d deja HUD listo" % (iteration + 1))
	print("T04 ventana: %d comprobaciones, %d fallos; salida %d; capturas en %s" % [checks, failures, 1 if failures else 0, output_dir])
	arena.free()
	quit(1 if failures else 0)
