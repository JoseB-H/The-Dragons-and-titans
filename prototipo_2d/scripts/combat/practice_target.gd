extends StaticBody2D
var total := 0

func receive_hit(amount: int) -> void:
	total += amount
	$Readout.text = str(total)
	# El daño flota encima del blanco y usa contorno para destacar sobre el destello.
	var number := Label.new()
	number.text = "−%d" % amount
	number.modulate = Color.GOLD
	number.add_theme_font_size_override("font_size",22)
	number.add_theme_constant_override("outline_size",5)
	number.add_theme_color_override("font_outline_color",Color.BLACK)
	number.position = Vector2(-16,-48)
	number.z_index = 12
	add_child(number)
	var fade := number.create_tween()
	fade.tween_property(number,"position:y",-74,0.5)
	fade.parallel().tween_property(number,"modulate:a",0,0.5)
	fade.tween_callback(number.queue_free)
