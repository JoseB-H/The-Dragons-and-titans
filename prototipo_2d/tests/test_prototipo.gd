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
	var spawner = level.get_node("WaveSpawner")
	# Aislar las regresiones del campo de tiro antes de activar la defensa.
	spawner.wave_pause = 1000.0
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
	var bar = level.get_node("UI/HealthBar")
	pilot_health.take_damage(pilot_health.current_health-30)
	check(bar.fill.bg_color==bar.GREEN,"El 30 % sigue verde")
	pilot_health.take_damage(1)
	check(bar.fill.bg_color==bar.RED and target.get_node("HealthBar").fill.bg_color==bar.GREEN,"Rojo por debajo del 30 % e independencia entre barras")
	check(pilot.get_node("Model").modulate.g<0.5,"Destello al recibir daño")
	await ticks(16)
	check(pilot.get_node("Model").modulate.is_equal_approx(Color.WHITE),"Fin del destello")
	pilot_health.revive()
	var objective = level.get_node("UI/Objective/Text")
	var obelisk = level.get_node("Obelisk")
	var ob_hp = obelisk.get_node("HealthComponent")
	var region = level.get_node("NavigationRegion")
	check(region.navigation_polygon.get_polygon_count()>0,"Malla navegable incluida")
	spawner.wave_sizes = PackedInt32Array([2,1])
	spawner.wave_pause = 0.5
	spawner.wait_left = 0
	await ticks(4)
	var enemies := get_nodes_in_group("minions")
	check(enemies.size()==2 and spawner.wave==1 and objective.text.ends_with("restantes 2"),"Primera oleada y panel")
	var unit = enemies[0]
	var start: Vector2 = unit.global_position
	await ticks(24)
	check(unit.target==obelisk and unit.global_position.distance_to(obelisk.global_position)<start.distance_to(obelisk.global_position),"Ruta al obelisco")
	pilot.global_position = unit.global_position+Vector2(15,0)
	await ticks(3)
	check(unit.target==pilot and unit.state==unit.State.ATACAR and pilot_health.current_health<100,"Aggro y ataque cuerpo a cuerpo")
	var after_hit: int = pilot_health.current_health
	await ticks(12)
	check(pilot_health.current_health==after_hit,"Intervalo entre golpes")
	pilot.global_position = Vector2.ZERO
	await ticks(4)
	check(unit.target==obelisk and unit.state==unit.State.MOVER,"Regresa al objetivo al alejarse el piloto")
	await ticks(330)
	check(ob_hp.current_health<ob_hp.max_health,"Minions llegan y dañan el obelisco")
	for actor in enemies: actor.get_node("HealthComponent").take_damage(999)
	check(spawner.remaining==0 and get_nodes_in_group("minions").is_empty(),"Una baja por minion")
	await ticks(12)
	check(spawner.wave==1,"Pausa real entre oleadas")
	await ticks(25)
	check(spawner.wave==2 and spawner.remaining==1,"Segunda oleada")
	get_nodes_in_group("minions")[0].get_node("HealthComponent").take_damage(999)
	check(objective.text.begins_with("Victoria") and paused,"Victoria final")
	await restart_with_r()
	var fresh = current_scene
	check(fresh!=null and fresh.get_node("WaveSpawner").wave==0 and not paused,"R reinicia después de victoria")
	fresh.get_node("Obelisk/HealthComponent").take_damage(999)
	check(paused and fresh.get_node("UI/Objective/Text").text.begins_with("Derrota"),"Derrota al caer el obelisco")
	await restart_with_r()
	check(not paused and current_scene.get_node("Obelisk/HealthComponent").current_health==180,"R reinicia después de derrota")
	print("Pasos 1 a 4 en 2D: %d comprobaciones, %d fallos" % [checks,failures])
	quit(1 if failures else 0)

func restart_with_r() -> void:
	var key := InputEventKey.new()
	key.physical_keycode = KEY_R
	key.pressed = true
	root.push_input(key)
	await ticks(4)
	key.pressed = false
	root.push_input(key)
