extends SceneTree
var failures := 0
var checks := 0

func _initialize() -> void:
	run.call_deferred()

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr(message)

func ticks(n: int) -> void:
	for i in n: await physics_frame

func run() -> void:
	# Instanciar el nivel de F5 directamente funciona en Godot 4.3.
	var level = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(level)
	current_scene = level
	await ticks(2)
	var pilot = level.get_node("Player")
	var camera = level.get_node("Camera")
	var weapon = pilot.get_node("Weapon")
	var targets: Array = level.get_node("Targets").get_children()
	Input.action_press("move_right")
	await ticks(4)
	check(pilot.velocity.x>0 and pilot.velocity.x<pilot.max_speed,"Aceleración gradual")
	await ticks(40)
	check(is_equal_approx(pilot.velocity.x,pilot.max_speed),"Velocidad máxima")
	Input.action_release("move_right")
	await ticks(2)
	check(pilot.velocity.x>0 and pilot.velocity.x<pilot.max_speed,"Inercia al soltar")
	await ticks(40)
	check(pilot.velocity.is_zero_approx(),"Frenado completo")
	check(pilot.aim_point.distance_to(pilot.get_global_mouse_position())<2,"Mira en coordenadas del mundo")
	check(camera.position_smoothing_enabled and camera.lead.length()<=camera.look_ahead+.01,"Seguimiento y límite del adelanto")
	pilot.set_physics_process(false)
	pilot.global_position = Vector2.ZERO
	pilot.aim_point = targets[0].global_position
	Input.action_press("basic_fire")
	await ticks(3)
	Input.action_release("basic_fire")
	await ticks(25)
	check(targets[0].total==12 and targets[1].total==0,"Básico al primer blanco")
	Input.action_press("burst_fire")
	await ticks(2)
	Input.action_release("burst_fire")
	pilot.aim_point = targets[3].global_position
	await ticks(50)
	check(targets[0].total==42,"Centro sin doble daño")
	check(targets[1].total==30 and targets[2].total==30 and targets[3].total==0,"Radio y destino fijado al lanzar")
	check(not paused and camera.offset.is_zero_approx(),"Recuperación del impacto")
	# Pasar por el grupo y detonar en un punto vacío fuera de su alcance.
	pilot.aim_point = Vector2(0,-280)
	weapon.launch(true)
	await ticks(55)
	check(targets[0].total==42,"Q no detona antes de alcanzar su destino")
	pilot.aim_point = Vector2(0,-90)
	weapon.launch(true)
	await ticks(55)
	check(targets[0].total==72,"Daño desde un punto vacío dentro del radio")
	pilot.aim_point = pilot.global_position
	check(not weapon.launch(false),"Dirección nula")
	print("Paso 2 en 2D: %d comprobaciones, %d fallos" % [checks,failures])
	quit(1 if failures else 0)
