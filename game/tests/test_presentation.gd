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
func run() -> void:
	var roster := root.get_node("DragonRoster")
	roster.select_dragon(&"cobre")
	change_scene_to_file("res://scenes/arena.tscn")
	await scene_changed
	var player := current_scene.get_node("Dragon")
	var enemy := current_scene.get_node("Enemy")
	player.set_physics_process(false)
	enemy.set_physics_process(false)
	var visual := player.get_node("Facing")
	expect(visual.enabled and visual.get_node_or_null("CobreDetails/SculptedMuzzle") != null, "Cobre tiene modelo enriquecido")
	expect(visual.details.get_child_count() >= 40, "Placas, dientes, garras y cuernos propios presentes")
	var origin: Vector3 = player.position
	var shape: Shape3D = player.get_node("CollisionShape3D").shape
	var wing: Transform3D = visual.get_node("LeftWing").transform
	await ticks(15)
	expect(not visual.get_node("LeftWing").transform.is_equal_approx(wing), "Alas animadas con tiempo real")
	expect(player.position == origin and player.get_node("CollisionShape3D").shape == shape, "Animación no desplaza actor ni cambia colisión")
	var weapon := player.get_node("Weapon")
	expect(weapon.try_fire(Vector3.RIGHT) and visual.attack_time > 0, "Disparo real activa animación")
	var attack_remaining: float = visual.attack_time
	expect(not weapon.try_fire(Vector3.RIGHT) and visual.attack_time == attack_remaining, "Disparo bloqueado no reactiva animación")
	player.take_damage(1, enemy.faction)
	expect(visual.hit_time > 0, "Daño real activa reacción")
	await ticks(22)
	expect(visual.attack_time == 0 and visual.hit_time == 0, "Reacciones temporales terminan")
	if DisplayServer.get_name() != "headless":
		for size in [Vector2i(1280,720), Vector2i(960,540)]:
			root.size = size
			await ticks(3)
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/T03-cobre-%dx%d.png" % [size.x,size.y])
		player.get_node("Camera").size = 6
		visual.look_at(player.get_node("Camera").global_position * Vector3(1, 0, 1) + Vector3(0, visual.global_position.y, 0))
		await ticks(3)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/T03-cobre-detalle.png")
	player.take_damage(player.max_health, enemy.faction)
	await ticks(45)
	expect(visual.death_amount >= 0.99 and not player.can_act(), "Muerte pliega alas sin habilitar combate")
	expect(player.position == origin, "Muerte solo modifica presentación")
	reload_current_scene()
	await scene_changed
	player = current_scene.get_node("Dragon")
	visual = player.get_node("Facing")
	expect(visual.death_amount == 0 and visual.attack_time == 0 and visual.hit_time == 0, "Reinicio crea animación limpia")
	expect(player.get_node("Weapon").fired.get_connections().size() == 1, "Reinicio no duplica conexiones")
	# Volver a selección para permitir cambio legítimo de perfil.
	change_scene_to_file("res://scenes/dragon_selection.tscn")
	await scene_changed
	roster.select_dragon(&"jade")
	change_scene_to_file("res://scenes/arena.tscn")
	await scene_changed
	visual = current_scene.get_node("Dragon/Facing")
	expect(not visual.enabled and visual.get_node_or_null("CobreDetails") == null, "Jade conserva representación anterior")
	print("T03 PRESENTACION: ", checks, " checks, ", failures, " failures")
	quit(1 if failures else 0)
