extends SceneTree
# Ejecutar dos procesos de Godot con este script, uno con -- host y otro con -- join.
func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var host_side := "host" in OS.get_cmdline_user_args()
	change_scene_to_file("res://scenes/world_menu.tscn")
	await scene_changed
	var atlas := current_scene
	await process_frame
	for i in atlas.MODES.size():
		atlas.markers[i].pressed.emit()
		if atlas.description.text.is_empty() or not ResourceLoader.exists("res://scenes/%s.tscn" % atlas.MODES[i][3]):
			quit(1)
			return
	atlas.select_mode(5)
	atlas.enter.pressed.emit()
	await scene_changed
	var room := current_scene
	if host_side:
		room.host_button.pressed.emit()
	else:
		room.address.text = "127.0.0.1"
		room.join_button.pressed.emit()
	var deadline := Time.get_ticks_msec() + 12000
	var moved := false
	var damaged := false
	while Time.get_ticks_msec() < deadline and room.won_by < 0:
		await physics_frame
		if not room.running:
			continue
		moved = moved or room.players[1].position.x < 7.75
		damaged = damaged or room.players[0].current_health < 100
		if not host_side:
			room.set_physics_process(false)
			room.commands.rpc_id(1, Vector2.ZERO if moved else Vector2.LEFT, Vector2.LEFT, true)
	var ok: bool = moved and damaged and room.won_by == 1
	ok = ok and room.banner.text.begins_with("DERROTA" if host_side else "VICTORIA")
	print("Duelo LAN ", "host" if host_side else "invitado", " movimiento=",moved," daño=",damaged," ganador=",room.won_by," resultado=",room.banner.text)
	await create_timer(.5 if host_side else .15).timeout
	quit(0 if ok else 1)
