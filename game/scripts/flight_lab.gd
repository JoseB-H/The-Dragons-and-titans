extends Node3D

func _ready() -> void:
	$UI/Atlas.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/world_menu.tscn"))

func _unhandled_key_input(event: InputEvent) -> void:
	# Guarda el fotograma real del motor para compararlo con la ficha 13 o 16.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F12:
		await RenderingServer.frame_post_draw
		var shot := get_viewport().get_texture().get_image()
		var target := "user://vuelo_%d.png" % Time.get_ticks_usec()
		if shot and shot.save_png(target) == OK:
			$UI/Status.text = ProjectSettings.globalize_path(target)
