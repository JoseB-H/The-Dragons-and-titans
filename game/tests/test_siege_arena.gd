extends SceneTree

var checks := 0
var failures := 0


func _initialize() -> void:
	run.call_deferred()


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func ticks(count: int) -> void:
	for index in count:
		await physics_frame
		await process_frame


func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/caldera-%s-%d.png" % [name, root.size.x])


func run() -> void:
	change_scene_to_file("res://scenes/dragon_selection.tscn")
	await scene_changed
	var button: Button = current_scene.get_node("Margin/Content/SiegeButton")
	await capture("menu")
	check(button.visible and button.get_global_rect().end.y <= root.get_visible_rect().end.y, "Selector muestra Asedio")
	button.pressed.emit()
	await scene_changed
	var arena: Node3D = current_scene
	check(arena.has_method("_match_actors"), "El modo carga su controlador")
	if not arena.has_method("_match_actors"):
		quit(1)
		return
	check(arena._match_actors().size() == 8, "Cuatro dragones, dos núcleos y dos torres")
	check(arena.ally.faction == arena.player.faction and arena.raider.faction != arena.player.faction, "Facciones de bots")
	await ticks(120)
	await capture("combate")
	check(arena.ally.global_position.z < 5.0, "IA aliada avanza hacia el frente")
	check(arena.raider.global_position.z > -5.0, "IA rival avanza hacia el frente")
	check(arena.ally.weapon.cooldown_remaining > 0.0 or arena._match_actors().any(func(actor): return actor.current_health < actor.max_health), "IA combate sin intervención")
	if DisplayServer.get_name() != "headless":
		await check_flight(arena.player)
	for bot in arena.bots:
		bot.set_physics_process(false)
	arena.player.set_physics_process(false)
	arena.player.position = arena.rival_tower.position + Vector3(0, 0, 2.5)
	arena.rival_tower.weapon.cooldown_remaining = 0.0
	await ticks(2)
	check(arena.rival_tower.weapon.cooldown_remaining > 0.0, "La torre dispara al entrar un rival")
	arena.player.position = Vector3(0, 1.5, -4)
	var weapon: Node3D = arena.player.get_node("Weapon")
	var power: Node3D = arena.player.get_node("PowerWeapon")
	check(arena.rival_core.shielded and arena.home_core.shielded, "Ambos núcleos empiezan protegidos")
	check(not arena.rival_core.take_damage(40, arena.player.faction), "El escudo absorbe daño hostil")
	var pulse: Node3D = arena.player.get_node("PulseAbility")
	arena.player.position = Vector3(0, 1.5, -7)
	check(pulse.try_activate(), "Pulso activado dentro del alcance del núcleo")
	check(arena.rival_core.current_health == arena.rival_core.max_health, "El pulso tampoco atraviesa el escudo")
	arena.rival_tower.take_damage(arena.rival_tower.max_health, arena.player.faction)
	check(not arena.rival_core.shielded and arena.home_core.shielded, "La torre solo desprotege a su propio núcleo")
	arena.player.position = Vector3(0, 1.5, -4)
	var before: int = arena.rival_core.current_health
	check(not arena.home_core.take_damage(50, arena.player.faction), "El núcleo rechaza daño aliado")
	var impacts: Array[Node3D] = []
	var observe_impact := func(node: Node):
		if node.is_in_group("equipment_impacts"):
			var impact := node as Node3D
			impact.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
			impacts.append(impact)
	node_added.connect(observe_impact)
	check(weapon.try_fire(Vector3.FORWARD), "Disparo básico real")
	check(not weapon.try_fire(Vector3.FORWARD), "Recarga bloquea disparo consecutivo")
	check(power.try_fire(Vector3.FORWARD), "Q tiene recarga independiente")
	await ticks(22)
	node_added.disconnect(observe_impact)
	check(not impacts.is_empty(), "El impacto real genera un efecto visible")
	await capture("impacto")
	for impact in impacts:
		if is_instance_valid(impact):
			impact.process_mode = Node.PROCESS_MODE_INHERIT
	await create_timer(0.56).timeout
	check(get_nodes_in_group("equipment_impacts").is_empty(), "Los efectos de impacto caducan")
	check(arena.rival_core.current_health < before, "Proyectiles reducen salud del núcleo por colisión")
	check(arena.state == 0, "El daño parcial no cierra partida")
	arena.rival_core.take_damage(arena.rival_core.max_health, arena.player.faction)
	await ticks(2)
	check(arena.state == 1, "Destrucción rival causa victoria")
	check(arena._match_actors().all(func(actor): return not actor.can_act()), "El final bloquea IA, jugador y núcleos")
	check(arena.get_node("Projectiles").get_child_count() == 0, "Limpieza de proyectiles")
	await capture("victoria")
	arena.restore_arena()
	await scene_changed
	arena = current_scene
	check(arena.state == 0 and is_zero_approx(arena.elapsed), "Restaura el modo y su reloj")
	check(arena._match_actors().all(func(actor): return actor.current_health == actor.max_health), "Restauración completa de salud")
	check(arena.home_core.shielded and arena.rival_core.shielded, "Reinicio restaura ambos escudos")
	arena.home_tower.take_damage(arena.home_tower.max_health, arena.enemy.faction)
	arena.rival_tower.take_damage(arena.rival_tower.max_health, arena.player.faction)
	arena.home_core.take_damage(240, arena.enemy.faction)
	arena.rival_core.take_damage(240, arena.player.faction)
	await ticks(2)
	check(arena.state == 2, "La caída del núcleo aliado tiene prioridad en empate")
	arena.return_to_selection()
	await scene_changed
	check(current_scene.has_node("Margin/Content/SiegeButton"), "Retorno al selector")
	print("Asedio: %d comprobaciones, %d fallos" % [checks, failures])
	quit(int(failures != 0))


func check_flight(player: Node3D) -> void:
	var center := root.get_visible_rect().size * 0.5
	root.warp_mouse(center + Vector2(180, 65))
	await ticks(2)
	var direction: Vector3 = player._cursor_direction(root.get_mouse_position())
	var before: Vector3 = player.global_position
	Input.action_press(&"fly_to_cursor")
	await ticks(6)
	Input.action_release(&"fly_to_cursor")
	check((player.global_position - before).dot(direction) > 0.1, "Vuelo hacia el cursor")
	before = player.global_position
	Input.action_press(&"fly_from_cursor")
	await ticks(6)
	Input.action_release(&"fly_from_cursor")
	check((player.global_position - before).dot(direction) < -0.1, "Retroceso respecto al cursor")
	var zoom_before: float = player.camera.size
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	Input.parse_input_event(wheel)
	await ticks(2)
	check(player.camera.size < zoom_before, "Zoom con la rueda")
