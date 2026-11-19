extends SceneTree

var failures := 0
var checks := 0

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, msg: String) -> void:
	checks += 1
	if not ok:
		printerr("FAIL: ", msg)
		failures += 1

func ticks(count: int) -> void:
	for i in count:
		await physics_frame

func run() -> void:
	change_scene_to_file("res://scenes/dragon_selection.tscn")
	await scene_changed
	current_scene.get_node("Margin/Content/NethergateButton").pressed.emit()
	await scene_changed
	var arena: Node3D = current_scene
	expect(arena.bots.size() == 9 and arena.teams[0].size() == 5 and arena.teams[1].size() == 5, "Dos equipos completos")
	for actor in arena.bots:
		actor.set_physics_process(false)
	arena.player.position = arena.RUNE_POS[0]
	await ticks(190)
	expect(arena.owners == [1,0,0] and arena.charge[0] > arena.charge[1], "Captura y aceleración de la carga")
	var bot: Node3D = arena.teams[1][0]
	bot.position = arena.RUNE_POS[0]
	await ticks(10)
	expect(is_equal_approx(arena.influence[0], 1), "Captura disputada bloqueada")
	arena.player.position = arena.spawns[arena.player]
	await ticks(370)
	expect(arena.owners[0] == 2, "Reconquista rival")
	for tower in arena.defenses[1]:
		tower.take_damage(1000,1)
	expect(arena.rival_core.shielded, "Las torres no abren la puerta")
	arena.charge[0] = arena.CHARGE_TIME
	await ticks(3)
	var ram: Node3D = arena.titans[0]
	expect(is_instance_valid(ram) and ram.faction == 1, "Invocación")
	var x := ram.position.x
	await ticks(15)
	expect(ram.position.x > x, "El titán avanza")
	ram.position = arena.rival_core.position + Vector3.LEFT * 2
	await ticks(3)
	expect(not arena.rival_core.shielded and arena.rival_core.current_health < arena.rival_core.max_health, "Embestida")
	arena.rival_core.take_damage(1000,1)
	await ticks(90)
	expect(arena.state == 1 and arena.outcome_banner.is_visible_in_tree(), "Victoria al destruir la puerta")
	expect(arena.has_node("LiberatedTitan"), "El titán vencedor emerge al romperse la puerta")
	arena.restore_arena()
	await scene_changed
	arena = current_scene
	expect(arena.owners == [0,0,0] and arena.home_core.shielded and arena.rival_core.shielded and arena.titans == [null,null], "Reinicio")
	arena.charge[1] = arena.CHARGE_TIME
	await ticks(3)
	arena.titans[1].take_damage(2000,1)
	await ticks(3)
	expect(not is_instance_valid(arena.titans[1]) and arena.home_core.shielded, "Defensa ante titán")
	arena.charge[1] = arena.CHARGE_TIME
	await ticks(3)
	arena.titans[1].position = arena.home_core.position
	await ticks(3)
	arena.home_core.take_damage(1000,2)
	await ticks(90)
	expect(arena.state == 2 and arena.outcome_banner.text == "DERROTA", "Derrota por asedio rival")
	print("Nethergate: %d comprobaciones, %d fallos" % [checks, failures])
	quit(int(failures > 0))
