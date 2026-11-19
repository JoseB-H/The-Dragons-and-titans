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
	# Verificar la magnitud analógica real con el mapa de entrada del proyecto.
	pilot.set_physics_process(true)
	Input.action_press("move_right", 0.6)
	await ticks(40)
	var analog := Input.get_vector("move_left","move_right","move_up","move_down")
	check(analog.length() < 1 and is_equal_approx(pilot.velocity.length(),pilot.max_speed*analog.length()),"Velocidad proporcional a la entrada")
	Input.action_release("move_right")
	await ticks(30)

	var target = targets[0]
	var health = target.get_node("HealthComponent")
	var deaths := [0]
	health.died.connect(func(): deaths[0] += 1)
	check(not health.take_damage(-10),"Rechazo de daño negativo")
	health.take_damage(900)
	check(health.current_health==0 and not target.visible and target.get_node("HealthBar").value==0,"Muerte y barra del blanco")
	check(not health.take_damage(1) and deaths[0]==1,"Una sola señal de muerte")
	await ticks(170)
	check(not target.visible and target.get_node("Collider").disabled,"Blanco ausente antes de 3 s")
	await ticks(15)
	check(target.visible and not target.get_node("Collider").disabled and health.current_health==health.max_health,"Reaparición del blanco")

	# Daño real de la torreta, manteniendo al piloto al alcance hasta caer.
	var turret = level.get_node("Turret")
	var pilot_health = pilot.get_node("HealthComponent")
	pilot.global_position = turret.global_position-Vector2(110,0)
	for i in 360:
		await physics_frame
		if pilot_health.current_health==0: break
	check(pilot_health.current_health==0 and not pilot.visible,"Los proyectiles de la torreta matan al piloto")
	check(level.get_node("UI/HealthBar").value==0 and not weapon.launch(true),"HUD a cero y arma bloqueada")
	await ticks(165)
	check(not pilot.visible and pilot.get_node("Collider").disabled,"Espera del piloto antes de reaparecer")
	await ticks(20)
	check(pilot.visible and pilot.global_position.is_equal_approx(level.get_node("Spawn").global_position),"Reaparición en Marker2D")
	check(pilot_health.current_health==pilot_health.max_health and level.get_node("UI/HealthBar").value==pilot_health.max_health,"Vida y HUD restaurados")
	check(pilot_health.invulnerable and pilot.get_node("Aura").visible and not pilot_health.take_damage(25),"Aura y bloqueo de daño")
	await ticks(105)
	check(pilot_health.invulnerable and not pilot_health.take_damage(25),"Protección aún activa antes de 2 s")
	await ticks(18)
	check(not pilot_health.invulnerable and not pilot.get_node("Aura").visible and pilot_health.take_damage(25),"El aura termina y vuelve el daño")
	level.get_node("ImpactFeedback").remove_from_group("impact_feedback")
	var bolt = preload("res://scenes/combat/bolt.tscn").instantiate()
	level.add_child(bolt)
	bolt.damage = 5
	bolt.resolve([target,level.get_node("Spawn")])
	check(health.current_health==health.max_health-5,"Impacto sin receptor de feedback y con objeto sin vida")
	var fx = preload("res://scenes/combat/impact.tscn").instantiate()
	level.add_child(fx)
	fx.play(81.6)
	var flash = fx.get_node("Flash")
	var smoke = fx.get_child(1)
	var flash_alpha: float = flash.modulate.a
	var smoke_alpha: float = smoke.modulate.a
	check(flash_alpha<1 and smoke_alpha<1,"Destello y humo translúcidos desde el primer cuadro")
	await ticks(10)
	check(flash.modulate.a<flash_alpha and smoke.modulate.a<smoke_alpha,"Ambas capas se desvanecen")
	print("Pasos 1 a 3 en 2D: %d comprobaciones, %d fallos" % [checks,failures])
	quit(1 if failures else 0)
