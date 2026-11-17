extends SceneTree
## Integración real: escena, Input Map, controlador y cámara, sin mocks.

var checks := 0
var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func release_movement() -> void:
	for action in ["move_left", "move_right", "move_forward", "move_back"]:
		Input.action_release(action)


func _run() -> void:
	var arena: Node3D = load("res://scenes/arena.tscn").instantiate()
	root.add_child(arena)
	await process_frame
	var dragon: Node3D = arena.get_node_or_null("Dragon")
	expect(dragon != null, "La escena principal debe contener el dragón de T02")
	if dragon == null:
		arena.free()
		quit(1)
		return
	dragon.set_physics_process(false)
	# Proyecciones de Camera3D usan el transform interpolado fuera del tick físico.
	# Ejecutar los pasos deterministas dentro de un tick, igual que el controlador.
	await physics_frame
	var camera: Camera3D = dragon.get_node("Camera")
	var facing: Node3D = dragon.get_node("Facing")
	var original_position := dragon.position
	var camera_offset := camera.global_position - dragon.global_position
	var initial_basis := camera.global_basis
	var speed: float = dragon.movement_speed
	var height: float = dragon.flight_height

	# Eliminar normalización o ignorar delta rompe estas comparaciones de distancia.
	Input.action_press("move_forward")
	dragon._physics_process(0.5)
	var axial_distance := dragon.position.distance_to(original_position)
	expect(is_equal_approx(axial_distance, speed * 0.5), "W recorre velocidad × delta")
	var movement_on_screen := camera.unproject_position(dragon.position) - camera.unproject_position(original_position)
	expect(movement_on_screen.y < 0 and absf(movement_on_screen.x) < 0.01, "W va hacia arriba en pantalla")
	release_movement()
	dragon.position = original_position
	Input.action_press("move_forward")
	Input.action_press("move_right")
	dragon._physics_process(0.5)
	expect(is_equal_approx(dragon.position.distance_to(original_position), axial_distance), "Diagonal sin velocidad adicional")
	expect(is_equal_approx(dragon.position.y, height), "Movimiento conserva altura de vuelo")
	release_movement()

	# Teclas opuestas y paso sin entrada deben permanecer quietos.
	var before := dragon.position
	Input.action_press("move_forward")
	Input.action_press("move_back")
	dragon._physics_process(0.5)
	expect(dragon.position.is_equal_approx(before), "Teclas opuestas se cancelan")
	release_movement()
	dragon._physics_process(0.5)
	expect(dragon.position.is_equal_approx(before), "Sin entrada no hay deriva")

	# Todas las esquinas: el margen mantiene la representación dentro del suelo.
	var limit: Vector2 = dragon.arena_half_size - Vector2.ONE * dragon.bounds_margin
	for corner in [Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1)]:
		dragon.position = Vector3(corner.x * 100, -20, corner.y * 100)
		dragon._physics_process(0.0)
		expect(is_equal_approx(dragon.position.x, corner.x * limit.x) and is_equal_approx(dragon.position.z, corner.y * limit.y), "Límite esquina %s" % corner)
		expect(is_equal_approx(dragon.position.y, height), "Restaurar altura al limitar")
	expect((camera.global_position - dragon.global_position).is_equal_approx(camera_offset), "Cámara conserva offset al seguir")
	expect(camera.global_basis.is_equal_approx(initial_basis), "Apuntar no gira la cámara")
	expect(not camera.is_position_behind(dragon.global_position), "Dragón delante de cámara")
	var projected := camera.unproject_position(dragon.global_position)
	expect(root.get_visible_rect().has_point(projected), "Dragón sigue dentro del encuadre al llegar a esquina")

	# Comprobar proyección real del cursor en centro/bordes y orientación solo en Y.
	dragon.position = original_position
	# El servidor headless no tiene cursor OS. Entradas explícitas al mismo método
	# usado en física; la lectura del ratón real se comprueba con servidor gráfico.
	var cases := [
		[Vector2(640, 100), Vector3(-0.707107, 0, -0.707107)],
		[Vector2(20, 360), Vector3(-0.707107, 0, 0.707107)],
		[Vector2(1260, 360), Vector3(0.707107, 0, -0.707107)],
		[Vector2(640, 700), Vector3(0.707107, 0, 0.707107)],
	]
	for sample in cases:
		var cursor: Vector2 = sample[0]
		dragon._aim_at_cursor(cursor)
		var expected_direction: Vector3 = sample[1]
		expect((-facing.global_basis.z).dot(expected_direction) > 0.999, "Hocico -Z apunta al cursor %s" % cursor)
		expect(facing.global_basis.y.is_equal_approx(Vector3.UP), "Apuntado sin pitch ni roll")
	# Casi en el centro y rayos sin intersección deben preservar orientación válida.
	var last_facing := facing.basis
	dragon._aim_at_cursor(camera.unproject_position(dragon.global_position) + Vector2(0.0001, 0.0001))
	expect(facing.basis.is_equal_approx(last_facing), "Cursor sobre dragón conserva orientación")
	camera.rotation = Vector3.ZERO
	dragon._aim_at_cursor(Vector2(640, 360))
	expect(facing.basis.is_equal_approx(last_facing), "Rayo paralelo al plano conserva orientación")
	expect(facing.basis.is_finite(), "Orientación finita tras casos degenerados")

	# El movimiento usa Input Map físico; no depende del texto del teclado.
	for binding in [["move_forward", KEY_W], ["move_left", KEY_A], ["move_back", KEY_S], ["move_right", KEY_D]]:
		var mapped := false
		for event in InputMap.action_get_events(binding[0]):
			if event is InputEventKey and event.physical_keycode == binding[1]:
				mapped = true
		expect(mapped, "Input Map físico: %s" % binding[0])
	release_movement()
	arena.free()
	print("T02: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)
