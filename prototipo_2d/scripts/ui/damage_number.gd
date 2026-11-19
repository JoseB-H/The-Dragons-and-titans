extends RefCounted

static func show_at(parent: Node2D, origin: Vector2, amount: int, tint: Color) -> void:
	# El daño flota encima del blanco y usa contorno para destacar sobre el destello.
	var number := Label.new()
	number.text = "−%d" % amount
	number.modulate = tint
	number.add_theme_font_size_override("font_size",22)
	number.add_theme_constant_override("outline_size",5)
	number.add_theme_color_override("font_outline_color",Color.BLACK)

	number.z_index = 12
	parent.add_child(number)
	number.global_position = origin + Vector2(-16,-48)
	var fade := number.create_tween()
	fade.tween_property(number,"position:y",number.position.y-26,0.5)
	fade.parallel().tween_property(number,"modulate:a",0,0.5)
	fade.tween_callback(number.queue_free)
