extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void:
	run.call_deferred()
func expect(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: ", message)
func ticks(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func capture(path: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(path)
func run() -> void:
	var roster := root.get_node("DragonRoster")
	for id: StringName in [&"cobre", &"jade"]:
		change_scene_to_file("res://scenes/dragon_selection.tscn")
		await scene_changed
		roster.select_dragon(id)
		change_scene_to_file("res://scenes/arena.tscn")
		await scene_changed
		var player := current_scene.get_node("Dragon")
		var enemy := current_scene.get_node("Enemy")
		player.set_physics_process(false)
		enemy.set_physics_process(false)
		var visual := player.get_node("Facing")
		var foe := enemy.get_node("Facing")
		expect(visual.enabled and visual.kind == id and foe.kind == &"sentinela", "Jugador y enemigo usan modelos importados correctos")
		expect(visual.skeleton != null and visual.skeleton.get_bone_count() >= 16, "Modelo tiene esqueleto real importado")
		for clip in [&"Flight", &"Attack", &"Hit", &"Death"]:
			expect(visual.animation.has_animation(clip) and visual.animation.get_animation(clip).get_track_count() > 0, "Clip importado tiene pistas: " + str(clip))
		expect(visual.animation.get_animation(&"Flight").loop_mode == Animation.LOOP_LINEAR and visual.animation.get_animation(&"Death").loop_mode == Animation.LOOP_NONE, "Vuelo repite y muerte termina")
		var origin: Vector3 = player.position
		var shape: Shape3D = player.get_node("CollisionShape3D").shape
		var bone_index: int = visual.skeleton.find_bone("WingL")
		await ticks(2)
		var wing_pose: Quaternion = visual.skeleton.get_bone_pose_rotation(bone_index)
		await ticks(10)
		expect(not visual.skeleton.get_bone_pose_rotation(bone_index).is_equal_approx(wing_pose), "Clip de vuelo mueve hueso del ala")
		expect(player.position == origin and player.get_node("CollisionShape3D").shape == shape and absf(visual.global_basis.z.y) < 0.001, "Animación no mueve colisión ni eje de apuntado")
		var mesh: MeshInstance3D = visual.model.find_children("*", "MeshInstance3D", true, false)[0]
		expect(mesh.skin != null and visual.materials.size() >= 6, "Malla skinned con materiales diferenciados")
		var textured := false
		var relief_count := 0
		for material: StandardMaterial3D in visual.materials:
			textured = textured or material.albedo_texture != null
			if material.normal_enabled and material.normal_texture != null:
				relief_count += 1
		expect(relief_count >= 2, "Piel y membrana conservan mapas de normales")
		expect(textured, "Textura de escamas importada presente")
		expect(visual.materials[0] != foe.materials[0], "Materiales de enemigo y jugador aislados")
		var decoration := current_scene.get_node("ArenaPresentation")
		expect(decoration.find_children("*", "CollisionObject3D", true, false).is_empty(), "Decoración no agrega obstáculos físicos")
		var weapon := player.get_node("Weapon")
		expect(weapon.try_fire(Vector3.RIGHT) and visual.active_clip == &"Attack", "Ataque real activa clip importado")
		var attack_remaining: float = visual.attack_time
		expect(not weapon.try_fire(Vector3.RIGHT) and visual.attack_time == attack_remaining, "Recarga bloqueada no reinicia clip")
		player.take_damage(1, enemy.faction)
		expect(visual.active_clip == &"Hit", "Daño real activa reacción importada")
		await ticks(60)
		expect(visual.attack_time == 0 and visual.hit_time == 0 and visual.active_clip == &"Flight", "Reacciones vuelven a vuelo")
		for size in [Vector2i(1280,720), Vector2i(960,540)]:
			root.size = size
			await ticks(3)
			await capture("/tmp/T05-%s-juego-%dx%d.png" % [id,size.x,size.y])
		player.get_node("Camera").size = 6.5
		player.get_node("Camera").position = Vector3(6,4.8,-7)
		player.get_node("Camera").look_at(player.global_position + Vector3(0,0.1,0))
		await ticks(3)
		await capture("/tmp/T05-%s-detalle.png" % id)
		player.take_damage(player.max_health, enemy.faction)
		await ticks(80)
		expect(visual.active_clip == &"Death" and visual.death_amount >= 0.99 and not player.can_act(), "Muerte sostiene pose y bloquea combate")
		expect(player.position == origin, "Clip de muerte no mueve actor")
		await capture("/tmp/T05-%s-muerte.png" % id)
		reload_current_scene()
		await scene_changed
		player = current_scene.get_node("Dragon")
		visual = player.get_node("Facing")
		expect(visual.kind == id and visual.death_amount == 0 and visual.hit_time == 0, "Reinicio conserva modelo y limpia reacciones")
		var fired: Signal = player.get_node("Weapon").fired
		expect(fired.is_connected(Callable(visual, "_on_attack")), "El disparo activa la animación tras reiniciar")
		if id == &"cobre":
			expect(fired.is_connected(Callable(visual.breath, "restart")), "Cobre conserva la llamarada tras reiniciar")
		expect(fired.get_connections().size() == (2 if id == &"cobre" else 1), "Cada perfil conserva exactamente sus conexiones")
		var foe_visual := current_scene.get_node("Enemy/Facing")
		current_scene.get_node("Enemy").take_damage(80, player.faction)
		await ticks(3)
		expect(foe_visual.active_clip == &"Death", "Enemigo también reproduce muerte")
	print("T05 MODELOS: ", checks, " checks, ", failures, " failures")
	quit(1 if failures else 0)
