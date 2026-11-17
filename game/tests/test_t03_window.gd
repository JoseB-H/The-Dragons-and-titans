extends SceneTree
## Integración gráfica T03 con ventana, física y entradas reales; sin mocks.

var checks := 0
var failures := 0
var shots_spawned := 0
var arena: Node3D
var player: Node3D
var enemy: Node3D
var camera: Camera3D
var output_dir := "user://t03-validation"


func _initialize() -> void:
	_run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
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
	# Aislar actores del cierre T05 tras _ready, antes del primer tick de IA.
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
	shots_spawned = 0
	arena.get_node("Projectiles").child_entered_tree.connect(func(_node: Node): shots_spawned += 1)


func capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(output_dir.path_join(filename))
	expect(error == OK, "Captura guardada: " + filename)


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
		printerr("T03 ventana requiere servidor gráfico X11/Wayland/Windows; headless no valida imagen.")
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
	var label: Label = arena.get_node("Controls/Panel/Margin/Label")
	expect(label.is_visible_in_tree() and label.text.contains("Clic") and label.text.contains("100 / 100") and label.text.contains("80 / 80"), "Controles y salud visibles")
	expect(camera.is_current() and root.get_visible_rect().has_point(camera.unproject_position(enemy.global_position)), "Cámara activa encuadra al enemigo")
	var start := player.position
	var offset := camera.global_position - player.global_position
	key(KEY_D, true)
	await ticks(6)
	key(KEY_D, false)
	expect(player.position.distance_to(start) > 0.3 and (camera.global_position - player.global_position).is_equal_approx(offset), "D física mueve al jugador y cámara lo sigue")
	key(KEY_A, true)
	await ticks(6)
	key(KEY_A, false)
	Input.warp_mouse(camera.unproject_position(enemy.global_position))
	await ticks(3)
	var direction := (enemy.global_position - player.global_position).normalized()
	expect((-player.get_node("Facing").global_basis.z).dot(direction) > 0.999, "Cursor real orienta el hocico al enemigo")
	click(true)
	await ticks(2)
	click(false)
	var projectiles := arena.get_node("Projectiles").get_children()
	expect(projectiles.size() == 1 and root.get_visible_rect().has_point(camera.unproject_position(projectiles[0].global_position)), "Clic crea proyectil visible en combate")
	await capture("T03-combate-linux.png")
	expect(await until(func(): return enemy.current_health < 80, 90), "Proyectil del jugador alcanza al enemigo")
	expect(enemy.current_health == 60 and player.current_health == 100, "Impacto aplica 20 una vez sin herir al emisor")
	enemy.set_physics_process(true)
	expect(await until(func(): return player.current_health < 100, 90), "IA inflige daño mediante proyectil real")
	enemy.set_physics_process(false)
	expect(player.current_health == 90, "Disparo hostil aplica 10 de daño")
	click(true)
	expect(await until(func(): return not enemy.is_alive(), 180), "Clic sostenido abate al enemigo con combate real")
	click(false)
	await ticks(2)
	expect(enemy.current_health == 0 and label.text.contains("Enemigo abatido"), "Salud cero y estado abatido visibles")
	await capture("T03-enemigo-abatido-linux.png")
	var previous_shots := shots_spawned
	enemy.set_physics_process(true)
	await ticks(75)
	expect(shots_spawned == previous_shots, "Enemigo muerto no genera nuevos ataques")

	for iteration in range(3):
		enemy.set_physics_process(false)
		player.current_health = 35
		enemy.current_health = 25
		player.position = Vector3(3, 1.5, 3)
		enemy.position = Vector3(-3, 1.5, -3)
		await ticks(2)
		Input.warp_mouse(camera.unproject_position(enemy.global_position))
		await ticks(2)
		click(true)
		await ticks(2)
		click(false)
		expect(arena.get_node("Projectiles").get_child_count() > 0 and player.get_node("Weapon").cooldown_remaining > 0, "Fixture %d tiene disparo y recarga pendientes" % (iteration + 1))
		var restored := await restore_with_key()
		expect(restored, "R física restaura arena %d dentro del límite" % (iteration + 1))
		if not restored:
			quit(1)
			return
		expect(player.current_health == 100 and enemy.current_health == 80 and player.is_alive() and enemy.is_alive(), "Restauración %d repone salud 100/80" % (iteration + 1))
		expect(player.position.is_equal_approx(Vector3(0, 1.5, 0)) and enemy.position.is_equal_approx(Vector3(0, 1.5, -7)), "Restauración %d repone posiciones" % (iteration + 1))
		var projectile_count := arena.get_node("Projectiles").get_child_count()
		var player_cooldown: float = player.get_node("Weapon").cooldown_remaining
		var enemy_cooldown: float = enemy.get_node("Weapon").cooldown_remaining
		var target_valid: bool = enemy.target == player
		expect(projectile_count == 0 and player_cooldown == 0 and enemy_cooldown == 0 and target_valid, "Restauración %d: proyectiles=%d, recargas=%.3f/%.3f, objetivo=%s; esperado 0/0/0/true" % [iteration + 1, projectile_count, player_cooldown, enemy_cooldown, target_valid])

	enemy.set_physics_process(true)
	expect(await until(func(): return not player.is_alive(), 720), "IA derrota al jugador sin entrada en un máximo de 12 s físicos")
	await ticks(2)
	label = arena.get_node("Controls/Panel/Margin/Label")
	expect(player.current_health == 0 and label.text.contains("Jugador caído"), "Derrota del jugador muestra salud cero")
	await capture("T03-jugador-caido-linux.png")
	start = player.position
	previous_shots = shots_spawned
	key(KEY_D, true)
	click(true)
	await ticks(75)
	key(KEY_D, false)
	click(false)
	expect(player.position.is_equal_approx(start) and shots_spawned == previous_shots, "Jugador muerto ignora movimiento/ataque y enemigo deja de atacar")
	print("T03 ventana: %d comprobaciones, %d fallos; capturas en %s" % [checks, failures, output_dir])
	arena.free()
	quit(1 if failures else 0)
