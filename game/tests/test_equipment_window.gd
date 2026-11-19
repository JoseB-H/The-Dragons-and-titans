extends "res://tests/test_v02_window.gd"
## Reutiliza comprobaciones de navegación/inputs/finales y amplía las cuatro cargas.

func check_fresh(profile_id: StringName) -> void:
	await RenderingServer.frame_post_draw
	var data: Dictionary = PROFILES[profile_id]
	var equipment: Resource = roster.selected_weapon()
	var basic: Node = player.get_node("Weapon")
	var power: Node = player.get_node("PowerWeapon")
	var pulse: Node = player.get_node("PulseAbility")
	expect(arena.scene_file_path == ARENA_SCENE and arena.state == 0 and active_game_scene_count() == 1, "Reinicio vuelve a una sola arena jugando")
	expect(player.profile_id == profile_id and player.profile_name == data.name and roster.selected_id == profile_id, "Arena aplica y conserva perfil %s" % profile_id)
	expect(player.current_health == data.health and player.max_health == data.health and enemy.current_health == 80, "Salud completa propia de %s al iniciar/reiniciar" % profile_id)
	expect(is_equal_approx(player.movement_speed, data.speed), "Velocidad aplicada de %s" % profile_id)
	expect(basic.damage == equipment.damage_for(roster.selected_profile()) and is_equal_approx(basic.cooldown, equipment.cooldown_for(roster.selected_profile())) and power.damage == data.q and is_equal_approx(power.cooldown, data.q_cd), "Básico/Q aplican datos del perfil %s" % profile_id)
	expect(pulse.damage == data.e and is_equal_approx(pulse.radius, data.radius) and is_equal_approx(pulse.cooldown, data.e_cd), "E aplica daño, radio y recarga del perfil %s" % profile_id)
	expect(player.position.is_equal_approx(Vector3(0, 1.5, 0)) and enemy.position.is_equal_approx(Vector3(0, 1.5, -7)), "Reinicio recupera posiciones")
	expect(arena.get_node("Projectiles").get_child_count() == 0 and arena.get_node("Effects").get_child_count() == 0 and shots_spawned == 0, "Reinicio sin proyectiles ni efectos heredados")
	expect(basic.cooldown_remaining == 0 and power.cooldown_remaining == 0 and pulse.cooldown_remaining == 0 and enemy.get_node("Weapon").cooldown_remaining == 0, "Reinicio recupera todas las recargas")
	expect(enemy.target == player and arena.find_children("*", "CharacterBody3D", true, false).size() == 2, "Dos actores y objetivo correcto sin acumulación")
	expect(not hud.result_panel.visible and hud.restart_requested.get_connections().size() == 1 and hud.selection_requested.get_connections().size() == 1, "Panel oculto y conexiones de navegación únicas")

	expect(player.equipment_id == roster.selected_weapon_id and hud.label.text.contains(equipment.display_name), "Arma elegida aplicada e identificada en HUD")

func choose_weapon(id: StringName, method: String) -> void:
	var menu: Control = current_scene
	var button: Button = menu.weapon_buttons[0 if id == &"ascua" else 1]
	if method == "keyboard":
		await focus_with_tab(button)
		await press_key(KEY_ENTER)
	else:
		await click_button(button)
	expect(roster.selected_weapon_id == id and button.button_pressed, "Arma accesible y seleccionada con " + method)
	var item: Resource = roster.selected_weapon()
	var profile: Resource = roster.selected_profile()
	expect(menu.details.text.contains(item.display_name) and menu.details.text.contains(str(item.damage_for(profile))), "Resumen refleja arma y daño calculado")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		printerr("Se requiere ventana real")
		quit(1)
		return
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output-dir="):
			output_dir = argument.trim_prefix("--output-dir=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	roster = root.get_node("DragonRoster")
	scene_changed.connect(pause_new_enemy)
	change_scene_to_file(SELECTION_SCENE)
	await scene_changed
	for size in [Vector2i(1280, 720), Vector2i(960, 540)]:
		root.size = size
		await ticks(3)
		for profile_id: StringName in [&"cobre", &"jade"]:
			for weapon_id: StringName in [&"ascua", &"martillo"]:
				await choose_profile(profile_id, "mouse")
				await choose_profile(profile_id, "keyboard")
				await choose_weapon(&"ascua" if weapon_id == &"martillo" else &"martillo", "mouse")
				await choose_weapon(weapon_id, "keyboard")
				await inspect_menu(profile_id)
				var suffix := "%s-%s-%dx%d.png" % [profile_id, weapon_id, size.x, size.y]
				await capture("T02-selector-" + suffix, size)
				if not await start_match(profile_id, "keyboard" if weapon_id == &"martillo" else "mouse"):
					quit(1)
					return
				await inspect_arena(false, profile_id)
				await capture("T02-arena-" + suffix, size)
				for cycle in range(4):
					expect(player.equipment_id == weapon_id, "Conserva arma tras reinicio")
					if cycle == 0:
						root.warp_mouse(camera.unproject_position(enemy.global_position))
						await ticks(3)
						await click_button_dummy()
						var damage: int = player.get_node("Weapon").damage
						expect(await until(func(): return enemy.current_health == 80 - damage), "Clic causa daño combinado real")
						expect(not player.get_node("Weapon").try_fire(Vector3.FORWARD), "Recarga del arma bloquea repetición inmediata")
					elif cycle == 2:
						await exercise_pulse(profile_id)
					if not await play_to_result(cycle != 1):
						quit(1)
						return
					await inspect_arena(true, profile_id)
					if cycle < 2:
						await capture("T02-%s-%s" % ["victoria" if cycle == 0 else "derrota", suffix], size)
					await check_closed()
					if cycle < 3:
						var held := cycle == 0
						if not held:
							await release_controls()
						if not await restart(profile_id, "R" if cycle == 0 else ("keyboard" if cycle == 1 else "mouse"), held):
							quit(1)
							return
					else:
						await release_controls()
				if not await return_to_menu(profile_id, "keyboard"):
					quit(1)
					return
	expect(results.size() == 32, "32 finales reales sin duplicar señales")
	print("Equipamiento ventana: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)

func click_button_dummy() -> void:
	click(true)
	await ticks()
	click(false)
