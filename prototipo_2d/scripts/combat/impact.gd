extends Node2D
## Animación independiente de la detección física.
func play(radius: float) -> void:
	var extent := radius if radius>0 else 13.2
	$Flash.modulate.a = 0.48
	var wave := create_tween()
	wave.tween_property($Flash,"scale",Vector2.ONE*extent,.12)
	wave.parallel().tween_property($Flash,"modulate:a",0.0,.27)
	wave.parallel().tween_property($Flash,"scale",Vector2.ONE*.1,.15).set_delay(.12)
	var count := 9 if radius>0 else 3
	for i in count:
		var puff := Polygon2D.new()
		puff.polygon = $Flash.polygon
		puff.modulate.a = 0.35
		puff.color = Color("#37303d")
		puff.scale = Vector2.ONE*2
		add_child(puff)
		var drift := puff.create_tween()
		drift.tween_property(puff,"position",Vector2.RIGHT.rotated(TAU*i/count)*extent*.72,.32)
		drift.parallel().tween_property(puff,"scale",Vector2.ONE*extent*.36,.32)
		drift.parallel().tween_property(puff,"modulate:a",0.0,.57)
	get_tree().create_timer(.65).timeout.connect(queue_free)
