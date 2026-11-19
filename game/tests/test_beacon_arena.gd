extends SceneTree

var failures := 0
var checks := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr(description)

func ticks(count: int) -> void:
	for frame in range(count):
		await physics_frame
		await process_frame

func run() -> void:
	change_scene_to_file("res://scenes/dragon_selection.tscn")
	await scene_changed
	var roster: Node = root.get_node("DragonRoster")
	current_scene.select_profile(&"jade")
	current_scene.select_weapon(&"martillo")
	var weapon_id: StringName = roster.selected_weapon_id
	check(weapon_id == &"martillo", "El selector equipa Martillo astral")
	current_scene.get_node("Margin/Content/BeaconButton").pressed.emit()
	await scene_changed
	var arena: Node3D = current_scene
	arena.enemy.set_physics_process(false)
	arena.player.set_physics_process(false)
	var west: Node3D = arena.beacons[0]
	var east: Node3D = arena.beacons[1]
	check(arena.player.profile_id == &"jade", "La modalidad usa el perfil seleccionado")
	check(not roster.select_weapon(&"ascua"), "El arma se bloquea en la arena")
	check(arena.hud.label.text.contains("0/2"), "Objetivo inicial en HUD")
	arena.player.position = west.position + Vector3.UP * 1.5
	await ticks(40)
	check(west.progress > 0.0 and not west.captured, "Captura parcial por permanencia")
	arena.player.position = Vector3.UP * 1.5
	await ticks(2)
	check(is_zero_approx(west.progress), "Salir cancela una captura parcial")
	arena.enemy.take_damage(arena.enemy.max_health, arena.player.faction)
	await ticks(2)
	check(arena.state == 0 and not arena.enemy.is_alive(), "Derrotar al enemigo no basta")
	arena.player.position = west.position + Vector3.UP * 1.5
	await ticks(125)
	check(west.captured and arena.state == 0, "La primera baliza no basta")
	check(arena.hud.label.text.contains("1/2"), "HUD refleja la primera captura")
	arena.player.position = east.position + Vector3.UP * 1.5
	await ticks(125)
	check(west.captured and east.captured and arena.state == 1, "Ambas capturas completan la victoria")
	check(not arena.player.can_act(), "El final detiene el combate")
	arena.restore_arena()
	await scene_changed
	arena = current_scene
	check(arena.state == 0 and not arena.beacons[0].captured and not arena.beacons[1].captured, "Reinicio restaura el objetivo")
	check(arena.enemy.is_alive() and arena.player.profile_id == &"jade" and roster.selected_weapon_id == weapon_id, "Reinicio restaura actores y equipo")
	arena.player.take_damage(arena.player.max_health, arena.enemy.faction)
	await ticks(2)
	check(arena.state == 2, "Perder toda la salud causa derrota")
	arena.return_to_selection()
	await scene_changed
	check(current_scene.has_node("Margin/Content/BeaconButton"), "La derrota permite volver al selector")
	print("Balizas: %d comprobaciones, %d fallos" % [checks, failures])
	quit(int(failures != 0))
