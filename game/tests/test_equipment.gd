extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void:
	_run.call_deferred()
func expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: ", message)
func ticks(n: int = 1) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func _run() -> void:
	var roster: Node = root.get_node("DragonRoster")
	expect(not roster.select_weapon(&"invalid"), "Rechaza arma inexistente")
	for dragon_id: StringName in [&"cobre", &"jade"]:
		for weapon_id: StringName in [&"ascua", &"martillo"]:
			roster.select_dragon(dragon_id)
			expect(roster.select_weapon(weapon_id), "Selecciona arma fuera de combate")
			var profile: Resource = roster.selected_profile()
			var equipment: Resource = roster.selected_weapon()
			var original_damage: int = profile.basic_damage
			change_scene_to_file("res://scenes/arena.tscn")
			await scene_changed
			for restart in range(4):
				var arena: Node = current_scene
				var player: Node3D = arena.get_node("Dragon")
				var enemy: Node3D = arena.get_node("Enemy")
				player.set_physics_process(false)
				enemy.set_physics_process(false)
				var weapon: Node = player.get_node("Weapon")
				expect(player.equipment_id == weapon_id and player.profile_id == dragon_id, "Conserva combinación al reiniciar")
				expect(weapon.damage == equipment.damage_for(profile), "Daño combinado real")
				expect(is_equal_approx(weapon.cooldown, equipment.cooldown_for(profile)), "Recarga combinada real")
				expect(player.max_health == profile.max_health and player.movement_speed == profile.movement_speed, "Arma no cambia salud/movimiento")
				expect(player.get_node("PowerWeapon").damage == profile.power_damage and player.get_node("PulseAbility").damage == profile.pulse_damage, "Q/E conservadas")
				expect(not roster.select_weapon(&"ascua"), "Impide equipar durante arena")
				player.position = Vector3(0, 1.5, 0)
				enemy.position = Vector3(0, 1.5, -3)
				player.reset_physics_interpolation()
				enemy.reset_physics_interpolation()
				await ticks(2)
				var health: int = enemy.current_health
				expect(weapon.try_fire(Vector3.FORWARD), "Disparo real")
				expect(not weapon.try_fire(Vector3.FORWARD), "Recarga bloquea segundo disparo")
				await ticks(12)
				expect(enemy.current_health == health - weapon.damage, "Impacto real aplica daño una vez")
				await ticks(ceili(weapon.cooldown * 60) + 2)
				expect(weapon.cooldown_remaining == 0.0, "Recarga termina")
				if restart % 2 == 0:
					enemy.take_damage(10000, player.faction)
				else:
					player.take_damage(10000, enemy.faction)
				await ticks(2)
				expect(arena.state == (1 if restart % 2 == 0 else 2), "Victoria y derrota reales")
				expect(not weapon.try_fire(Vector3.FORWARD), "Final bloquea disparos")
				expect(profile.basic_damage == original_damage, "No muta recurso compartido")
				if restart < 3:
					arena.restore_arena()
					await scene_changed
			expect(current_scene.return_to_selection() == OK, "Retorna a equipamiento")
			await scene_changed
			expect(current_scene.selected_profile_id() == dragon_id, "Selector conserva dragón")
			expect(current_scene.select_weapon(weapon_id), "Selector permite equipar después del final")
	print("Equipment checks: %d, failures: %d" % [checks, failures])
	quit(0 if failures == 0 else 1)
