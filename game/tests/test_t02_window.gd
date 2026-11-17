extends SceneTree
## Prueba gráfica automatizada. Requiere ventana real; no sustituye prueba humana.

var checks := 0
var failures := 0
var dragon: Node3D
var camera: Camera3D
var output_dir := "user://t02-validation"


func _initialize() -> void:
	_run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func key_event(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)


func hold_key(code: int) -> void:
	key_event(code, true)
	var centered := true
	var offset_stable := true
	var offset := camera.global_position - dragon.global_position
	# Cruzar 20 unidades a 6/s en un eje diagonal requiere más de 4.7 s.
	for frame in range(360):
		await physics_frame
		await process_frame
		var rendered_position := dragon.get_global_transform_interpolated().origin
		var on_screen := camera.unproject_position(rendered_position)
		centered = centered and on_screen.distance_to(root.get_visible_rect().size * 0.5) < 2.0
		offset_stable = offset_stable and (camera.global_position - dragon.global_position).is_equal_approx(offset)
	key_event(code, false)
	expect(centered, "Dragón centrado durante 360 ticks de seguimiento interpolado")
	expect(offset_stable, "Seguimiento sin cambios de offset ni retardo")


func capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(output_dir.path_join(filename))
	expect(error == OK, "Captura guardada: " + filename)


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		printerr("Esta prueba requiere X11/Wayland/Windows con renderizado real.")
		quit(1)
		return
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output-dir="):
			output_dir = argument.trim_prefix("--output-dir=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var arena: Node3D = load("res://scenes/arena.tscn").instantiate()
	root.add_child(arena)
	# Mantener todas las aserciones T02 sin ataques ajenos a esta regresión.
	arena.get_node("Enemy").set_physics_process(false)
	await process_frame
	dragon = arena.get_node("Dragon")
	camera = dragon.get_node("Camera")
	Input.warp_mouse(Vector2(1050, 360))
	await physics_frame
	await process_frame
	await capture("T02-inicio-linux.png")

	# Entrada física a través del Input Map y del _physics_process real.
	var corners := [Vector2(-10, -10), Vector2(10, -10), Vector2(10, 10), Vector2(-10, 10)]
	var keys := [KEY_W, KEY_D, KEY_S, KEY_A]
	for index in range(keys.size()):
		await hold_key(keys[index])
		var expected: Vector2 = corners[index]
		expect(Vector2(dragon.position.x, dragon.position.z).distance_to(expected) < 0.01, "Tecla %s llega a esquina %s; posición %s" % [keys[index], expected, dragon.position])
		expect(is_equal_approx(dragon.position.y, 1.5), "Altura constante en movimiento real")
	await capture("T02-esquina-linux.png")

	# El cursor OS debe llegar al controlador durante el movimiento normal.
	for cursor in [Vector2(20, 360), Vector2(1260, 360), Vector2(640, 100), Vector2(640, 700)]:
		Input.warp_mouse(cursor)
		await physics_frame
		await process_frame
		var facing: Node3D = dragon.get_node("Facing")
		var hit: Vector3 = Plane(Vector3.UP, dragon.global_position.y).intersects_ray(camera.project_ray_origin(cursor), camera.project_ray_normal(cursor))
		var target_direction := (hit - dragon.global_position).normalized()
		expect((-facing.global_basis.z).dot(target_direction) > 0.999, "Cursor OS orienta hocico: %s" % cursor)
	print("T02 ventana: %d comprobaciones, %d fallos; capturas en %s" % [checks, failures, output_dir])
	arena.free()
	quit(1 if failures else 0)
