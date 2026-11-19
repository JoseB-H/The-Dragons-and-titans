extends SceneTree

var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, reason: String) -> void:
	if not condition:
		failures += 1
		printerr(reason)

func run() -> void:
	change_scene_to_file("res://scenes/world_menu.tscn")
	await scene_changed
	var atlas = current_scene
	atlas.select_mode(atlas.MODES.find_custom(func(mode): return mode[3]=="levels/flight_lab"))
	atlas.enter.pressed.emit()
	await scene_changed
	await physics_frame
	await process_frame
	var pilot = current_scene.get_node("FlightPilot")
	var camera: Camera3D = pilot.camera
	pilot.set_physics_process(false)
	camera.set_physics_process(false)
	var geometry := preload("res://scripts/flight_geometry.gd")
	var marker := Vector3(0,pilot.flight_height,-5)
	var cursor := camera.unproject_position(marker)
	check(geometry.aim(camera,pilot.position,cursor).is_equal_approx(Vector3.FORWARD),"La mira señala la baliza")
	var start: Vector3 = camera.global_position
	Input.action_press("move_back")
	pilot._physics_process(.5)
	Input.action_release("move_back")
	check(is_equal_approx(pilot.position.z,3) and is_equal_approx(pilot.position.y,pilot.flight_height),"Retroceso horizontal")
	check(geometry.aim(camera,pilot.position,cursor).dot(Vector3.FORWARD)>.99,"La retirada conserva la dirección de puntería")
	camera._physics_process(.05)
	check(camera.position.z>start.z and camera.position.z<start.z+3,"Seguimiento progresivo")
	check(is_equal_approx(geometry.movement(camera,Vector2.ONE).length(),1),"Diagonal normalizada")
	Input.action_press("move_right")
	pilot._physics_process(100)
	Input.action_release("move_right")
	check(is_equal_approx(pilot.position.x,pilot.half_extents.x),"Límite de vuelo")
	current_scene.get_node("UI/Atlas").pressed.emit()
	await scene_changed
	check(current_scene.scene_file_path.ends_with("world_menu.tscn"),"Vuelta al atlas")
	print("Práctica de vuelo: 7 comprobaciones, %d fallos" % failures)
	quit(1 if failures else 0)
