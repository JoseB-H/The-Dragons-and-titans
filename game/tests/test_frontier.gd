extends SceneTree

var failures := 0
var checks := 0


func _initialize() -> void:
	run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func ticks(count: int) -> void:
	for step in count:
		await physics_frame
		await process_frame


func capture(name: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/frontera-%s-%d.png" % [name, root.size.x])


func run() -> void:
	change_scene_to_file("res://scenes/dragon_selection.tscn")
	await scene_changed
	await ticks(2)
	current_scene.select_profile(&"cobre")
	var button: Button = current_scene.get_node("Margin/Content/FrontierButton")
	expect(root.get_visible_rect().encloses(button.get_global_rect()), "El acceso al 5v5 se ve en el menú")
	button.pressed.emit()
	await scene_changed
	var arena: Node3D = current_scene
	if not arena.has_method("seconds_to_respawn"):
		printerr("FAIL: no cargó Frontera")
		quit(1)
		return
	expect(arena.teams[0].size() == 5 and arena.teams[1].size() == 5 and arena.bots.size() == 9, "Cinco dragones por facción y nueve bots")
	expect(arena._match_actors().size() == 18, "Diez dragones, seis torres y dos núcleos")
	expect(arena.defenses[0].size() == 3 and arena.defenses[1].size() == 3, "Defensas de ambos equipos")
	expect(is_zero_approx(arena.home_core.position.z) and is_zero_approx(arena.rival_core.position.z), "Núcleos alineados con el carril central")
	expect(arena.lanes.values().has(0) and arena.lanes.values().has(1) and arena.lanes.values().has(2), "Asignación en tres carriles")
	var breath: CPUParticles3D = arena.player.get_node("Facing").breath
	expect(arena.player.get_node("Weapon").try_fire(Vector3.RIGHT) and breath.emitting, "El ataque básico de Cobre emite fuego")
	var start: float = arena.bots[0].position.x
	await ticks(34)
	expect(arena.bots[0].position.x > start, "Los aliados avanzan")
	var map_key := InputEventKey.new()
	map_key.physical_keycode = KEY_M
	map_key.pressed = true
	arena._unhandled_input(map_key)
	expect(arena.tactical_open, "M abre vista táctica")
	await capture("mapa")
	arena._unhandled_input(map_key)
	expect(not arena.tactical_open, "M vuelve a la cámara del jugador")
	await capture("camara")
	arena.player.take_damage(arena.player.max_health, 2)
	await ticks(2)
	expect(not arena.player.is_alive() and arena.state == 0 and arena.scores[1] == 1, "La baja se cuenta y la partida continúa")
	arena.elapsed = arena.returns[arena.player] + 0.01
	await ticks(2)
	expect(arena.player.is_alive() and arena.player.position.is_equal_approx(arena.spawns[arena.player]), "El jugador reaparece en su base")
	expect(arena.wave_number == 1 and arena.constructs.size() == 6, "Una oleada genera una unidad por equipo y carril")
	var unit: Node3D = arena.constructs[0]
	for minion in arena.constructs:
		var file := "angel.glb" if minion.faction == 1 else "demonio.glb"
		expect(minion.model.scene_file_path.get_file() == file and minion.wing_left != null and minion.wing_right != null, "Cada carril carga el modelo y las alas de su facción")
	var unit_start: float = unit.position.x
	await ticks(10)
	expect(unit.position.x > unit_start, "La oleada aliada avanza")
	var bot: Node3D = arena.bots[0]
	bot.current_health = 10
	await ticks(2)
	expect(bot.rally_position is Vector3 and bot.target == null, "La IA herida se retira y deja de perseguir")
	bot.position = arena.spawns[bot]
	await ticks(75)
	expect(bot.rally_position == null and bot.current_health * 4 >= bot.max_health * 3,
		"La IA recupera salud en su base y regresa")
	await capture("oleadas")
	expect(not arena.rival_core.take_damage(100, 1), "Núcleo rival protegido")
	for index in range(2):
		arena.defenses[1][index].take_damage(1000, 1)
	expect(arena.rival_core.shielded, "Dos torres caídas todavía dejan escudo")
	arena.defenses[1][2].take_damage(1000, 1)
	expect(not arena.rival_core.shielded and arena.home_core.shielded, "Última torre retira solo el escudo rival")
	arena.rival_core.take_damage(1000, 1)
	await ticks(2)
	expect(arena.state == 1 and arena._match_actors().all(func(actor): return not actor.can_act()), "Victoria detiene el combate completo")
	expect(arena.constructs.is_empty() and not is_instance_valid(unit), "La victoria retira las unidades")
	expect(not arena.hud.visible and arena.get_viewport().get_camera_3d() != arena.player.camera, "La cámara de cierre toma el control")
	await ticks(90)
	expect(not arena.rival_core.gem_node.visible and arena.home_core.gem_node.visible, "Solo estalla el núcleo rival")
	expect(arena.outcome_banner.is_visible_in_tree() and arena.outcome_banner.text == "VICTORIA" and not arena.hud.visible, "Victoria visible durante el estallido")
	await capture("ruptura")
	await ticks(90)
	expect(arena.hud.visible and arena.hud.result_panel.visible and arena.hud.result_title.text == "VICTORIA", "El resultado aparece después de la ruptura")
	await capture("resultado")
	arena.restore_arena()
	await scene_changed
	arena = current_scene
	expect(arena.state == 0 and arena.home_core.shielded and arena.rival_core.shielded and arena.scores == [0, 0], "Reinicio restaura marcador y escudos")
	expect(arena.wave_number == 0 and arena.constructs.is_empty(), "El reinicio limpia las oleadas")
	for tower in arena.defenses[0]:
		tower.take_damage(1000, 2)
	arena.home_core.take_damage(1000, 2)
	await ticks(90)
	expect(arena.outcome_banner.is_visible_in_tree() and arena.outcome_banner.text == "DERROTA", "La ruptura aliada anuncia derrota")
	await ticks(90)
	expect(arena.state == 2 and arena.hud.visible and not arena.home_core.gem_node.visible and arena.rival_core.gem_node.visible, "Derrota enfoca y rompe el núcleo aliado")
	print("Frontera: %d comprobaciones, %d fallos" % [checks, failures])
	quit(int(failures != 0))
