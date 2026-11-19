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
func ticks(count := 3) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func click(button: Button) -> void:
	root.warp_mouse(button.get_global_rect().get_center())
	await ticks(2)
	var pos := Vector2(DisplayServer.mouse_get_position() - DisplayServer.window_get_position())
	for pressed in [true,false]:
		var event := InputEventMouseButton.new()
		event.position = pos
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		Input.parse_input_event(event)
		await ticks(2)
func capture(path: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(path)
func run() -> void:
	var roster := root.get_node("DragonRoster")
	for size in [Vector2i(1280,720),Vector2i(960,540)]:
		root.size = size
		change_scene_to_file("res://scenes/dragon_selection.tscn")
		await scene_changed
		current_scene.select_profile(&"jade")
		current_scene.select_weapon(&"martillo")
		await ticks()
		var gallery_button := current_scene.get_node("Margin/Content/Footer/GalleryButton")
		expect(root.get_visible_rect().encloses(gallery_button.get_global_rect()) and not gallery_button.get_global_rect().intersects(current_scene.play_button.get_global_rect()), "Acceso galería visible sin solapar Jugar")
		await capture("/tmp/T05-menu-%dx%d.png" % [size.x,size.y])
		await click(gallery_button)
		await ticks()
		expect(current_scene.scene_file_path == "res://scenes/model_gallery.tscn", "Botón real abre galería")
		if current_scene.scene_file_path != "res://scenes/model_gallery.tscn":
			quit(1)
			return
		var gallery := current_scene
		var buttons := gallery.find_children("*","Button",true,false)
		for button: Button in buttons:
			expect(root.get_visible_rect().encloses(button.get_global_rect()), "Control galería cabe: "+button.text)
		for id in ["Cobre","Jade","Sentinela"]:
			for button: Button in buttons:
				if button.text == id:
					await click(button)
			await ticks(8)
			expect(gallery.chosen == StringName(id.to_lower()) and gallery.animation.is_playing(), "Selector muestra modelo animado: "+id)
			await capture("/tmp/T05-galeria-%s-%dx%d.png" % [id.to_lower(),size.x,size.y])
			for pair in [["Ataque",&"Attack"],["Impacto",&"Hit"],["Muerte",&"Death"],["Vuelo",&"Flight"]]:
				for button: Button in buttons:
					if button.text == pair[0]:
						await click(button)
				expect(gallery.animation.current_animation == pair[1], "Botón reproduce clip real: "+str(pair[1]))
		var old_angle: float = gallery.angle
		var down := InputEventMouseButton.new()
		down.position = Vector2(size)*Vector2(.7,.5)
		down.button_index = MOUSE_BUTTON_LEFT
		down.pressed = true
		Input.parse_input_event(down)
		await ticks()
		var motion := InputEventMouseMotion.new()
		motion.position = down.position + Vector2(100,0)
		motion.relative = Vector2(100,0)
		Input.parse_input_event(motion)
		await ticks()
		expect(gallery.angle > old_angle, "Arrastrar fondo gira vista")
		down.pressed = false
		Input.parse_input_event(down)
		await ticks()
		expect(not gallery.dragging, "Soltar arrastre termina giro")
		var old_distance: float = gallery.distance
		var scroll := InputEventMouseButton.new()
		scroll.position = down.position
		scroll.button_index = MOUSE_BUTTON_WHEEL_UP
		scroll.pressed = true
		Input.parse_input_event(scroll)
		await ticks()
		expect(gallery.distance < old_distance, "Rueda acerca modelo")
		for button: Button in buttons:
			if button.text == "Volver":
				await click(button)
		await ticks()
		expect(current_scene.scene_file_path == "res://scenes/dragon_selection.tscn" and roster.selected_id == &"jade" and roster.selected_weapon_id == &"martillo", "Volver conserva selección y equipo")
	print("T05 GALERIA: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)
