extends SceneTree
## Selección, daño real, reinicio conservando perfil y vuelta al selector.

var checks := 0
var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func expect(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: ", description)


func ticks(count: int = 1) -> void:
	for frame in range(count):
		await physics_frame
		await process_frame


func pause_enemy() -> void:
	if is_instance_valid(current_scene) and current_scene.has_node("Enemy"):
		current_scene.get_node("Enemy").set_physics_process(false)


func hit(arena: Node3D, weapon: Node3D, direction: Vector3) -> void:
	expect(weapon.try_fire(direction), "Arma configurada dispara un proyectil real")
	for frame in range(60):
		await ticks()
		if arena.get_node("Projectiles").get_child_count() == 0:
			return
	expect(false, "El proyectil real debe impactar dentro del plazo")


func _run() -> void:
	var probe: Node3D = load("res://scenes/arena.tscn").instantiate()
	var integrated := probe.has_method("return_to_selection")
	expect(integrated, "Arena ofrece retorno a selección después de terminar")
	probe.free()
	if not integrated:
		finish()
		return
	scene_changed.connect(pause_enemy)
	var roster: Node = root.get_node("DragonRoster")
	for id: StringName in [&"cobre", &"jade"]:
		expect(roster.select_dragon(id), "Catálogo acepta el perfil de la partida")
		change_scene_to_file("res://scenes/arena.tscn")
		await scene_changed
		var arena: Node3D = current_scene
		var player: Node3D = arena.get_node("Dragon")
		var enemy: Node3D = arena.get_node("Enemy")
		var profile: Resource = roster.selected_profile()
		player.set_physics_process(false)
		expect(player.profile_id == id and player.current_health == profile.max_health, "Partida usa elección con salud completa")
		expect(arena.return_to_selection() == ERR_UNAVAILABLE, "No se cambia de dragón durante combate")
		player.position = Vector3(0, 1.5, 0)
		enemy.position = Vector3(0, 1.5, -3)
		player.reset_physics_interpolation()
		enemy.reset_physics_interpolation()
		await ticks(2)
		await hit(arena, enemy.get_node("Weapon"), Vector3.BACK)
		expect(player.current_health == profile.max_health - enemy.get_node("Weapon").damage, "Salud del perfil recibe daño real del enemigo")
		await hit(arena, player.get_node("Weapon"), Vector3.FORWARD)
		expect(enemy.current_health == enemy.max_health - profile.basic_damage, "Básico aplica daño desde datos")
		await hit(arena, player.get_node("PowerWeapon"), Vector3.FORWARD)
		expect(enemy.current_health == maxi(0, enemy.max_health - profile.basic_damage - profile.power_damage), "Q aplica daño desde datos sin compartir recarga")
		var before: int = enemy.current_health
		expect(player.get_node("PulseAbility").try_activate(), "E disponible después de básico y Q")
		expect(enemy.current_health == maxi(0, before - profile.pulse_damage), "E aplica radio y daño del perfil")
		if enemy.is_alive():
			while player.get_node("Weapon").cooldown_remaining > 0.0:
				await ticks()
			await hit(arena, player.get_node("Weapon"), Vector3.FORWARD)
		await ticks(2)
		expect(arena.state == 1 and not player.can_act() and not enemy.can_act(), "Ambos perfiles pueden ganar y quedan bloqueados")
		var hud: CanvasLayer = arena.get_node("Controls")
		expect(hud.label.text.contains(profile.display_name), "HUD identifica el dragón elegido")
		var previous: WeakRef = weakref(arena)
		expect(arena.restore_arena() == OK, "Reinicio conserva el flujo de arena")
		await scene_changed
		arena = current_scene
		player = arena.get_node("Dragon")
		expect(previous.get_ref() == null and player.profile_id == id and arena.state == 0, "Reinicio elimina escena anterior y conserva elección")
		expect(player.current_health == profile.max_health and player.get_node("Weapon").cooldown_remaining == 0.0 and player.get_node("PowerWeapon").cooldown_remaining == 0.0 and player.get_node("PulseAbility").cooldown_remaining == 0.0, "Reinicio restaura salud y recargas según perfil")
		expect(arena.get_node("Projectiles").get_child_count() == 0 and arena.get_node("Effects").get_child_count() == 0, "Reinicio limpia proyectiles y efectos")
		player.take_damage(profile.max_health, 2)
		await ticks(2)
		expect(arena.state == 2, "Salud propia del perfil decide derrota")
		previous = weakref(arena)
		expect(arena.return_to_selection() == OK, "Final permite volver a elegir")
		expect(arena.return_to_selection() == OK, "Peticiones rápidas no duplican navegación")
		await scene_changed
		var selection: Control = current_scene
		expect(previous.get_ref() == null and selection.selected_profile_id() == id, "Selector conserva elección y libera arena anterior")
		var other: StringName = &"jade" if id == &"cobre" else &"cobre"
		expect(selection.select_profile(other) and roster.selected_id == other, "Tras acabar se puede elegir otro perfil")
	roster.select_dragon(&"cobre")
	finish()


func finish() -> void:
	print("V0.2 partida: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)
