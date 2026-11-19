extends "res://scripts/siege_hud.gd"


func _mode_title() -> String:
	return "FRONTERA DE CENIZA · 5v5"


func _mode_objective() -> String:
	if arena.rival_core.shielded:
		var remaining: int = arena.defenses[1].filter(func(tower): return tower.is_alive()).size()
		return "Torres rivales en pie · %d/3" % remaining
	return "Destruye el núcleo ígneo"


func _draw() -> void:
	super._draw()
	if not is_instance_valid(arena) or arena.state != 0:
		return
	var viewport := get_viewport_rect().size
	_caption(Vector2(20, 80), "Bajas %d — %d · Oleada %d" % [arena.scores[0], arena.scores[1], arena.wave_number], GOLD, 16)
	_caption(Vector2(20, 105), "M · Vista táctica", Color.WHITE, 15)
	var row_y := 126.0
	for ally in arena.teams[0]:
		var is_player: bool = ally == arena.player
		var ally_name: String = arena.player.profile_name if is_player else "Ala %d" % arena.teams[0].find(ally)
		var row := Rect2(15, row_y, 117, 23)
		_panel(row)
		_caption(row.position + Vector2(5, 14), ally_name if ally.is_alive() else ally_name + " · caído", GOLD if is_player else Color.WHITE, 13)
		_bar(Rect2(row.position + Vector2(5, 17), Vector2(106, 3)), ally, BLUE)
		row_y += 25
	if not arena.player.is_alive():
		var status := Rect2(viewport * 0.5 - Vector2(125, 34), Vector2(250, 68))
		_panel(status)
		_caption(status.position + Vector2(19, 42), "Reaparición en %d s" % arena.seconds_to_respawn(), GOLD, 22)
	if arena.tactical_open:
		var size := Vector2(minf(viewport.x - 100.0, 910.0), minf(viewport.y - 155.0, 500.0))
		var frame := Rect2((viewport - size) / 2, size)
		_panel(frame)
		_caption(frame.position + Vector2(24, 34), _mode_title() + "  /  VISTA TÁCTICA", GOLD, 22)
		_caption(Vector2(frame.position.x + 24, frame.end.y - 18), "M · Cerrar  |  Círculos: dragones  ·  Cuadrados: torres  ·  Rombos: núcleos", Color.WHITE, 16)
		_map_field(Rect2(frame.position + Vector2(22, 56), frame.size - Vector2(44, 106)), 1.8)


func _draw_map(rect: Rect2) -> void:
	var map := Rect2(rect.end - Vector2(206, 132), Vector2(206, 132))
	_panel(map)
	_map_field(map.grow(-8.0), 1.0)


func _map_field(field: Rect2, scale_factor: float) -> void:
	draw_rect(field, Color(0.15, 0.23, 0.34))
	draw_rect(Rect2(field.position + Vector2(field.size.x / 2, 0), Vector2(field.size.x / 2, field.size.y)), Color(0.28, 0.13, 0.13))
	for z in [-15.0, 0.0, 15.0]:
		var start := _map_position(field, Vector3(-35, 0, z))
		var end := _map_position(field, Vector3(35, 0, z))
		draw_line(start, end, Color(0.68, 0.53, 0.39, 0.65), 3.0 * scale_factor, true)
		draw_line(_map_position(field, Vector3(-40, 0, 0)), start, EDGE, 2.0 * scale_factor, true)
		draw_line(end, _map_position(field, Vector3(40, 0, 0)), EDGE, 2.0 * scale_factor, true)
	for unit in arena.constructs:
		if is_instance_valid(unit) and unit.is_alive():
			draw_circle(_map_position(field, unit.position), 2.0 * scale_factor,
				BLUE if unit.faction == 1 else RED)
	for unit in arena._match_actors():
		if not unit.is_alive():
			continue
		var point := _map_position(field, unit.position)
		var color := BLUE if unit.faction == 1 else RED
		if unit == arena.home_core or unit == arena.rival_core:
			var radius := 7.0 * scale_factor
			draw_colored_polygon(PackedVector2Array([point + Vector2.UP * radius, point + Vector2.RIGHT * radius,
				point + Vector2.DOWN * radius, point + Vector2.LEFT * radius]), color)
		elif unit in arena.bots or unit == arena.player:
			draw_circle(point, (4.4 if unit == arena.player else 3.0) * scale_factor, Color.WHITE if unit == arena.player else color)
		else:
			var size := Vector2.ONE * 7.0 * scale_factor
			draw_rect(Rect2(point - size / 2, size), color)


func _map_position(field: Rect2, point: Vector3) -> Vector2:
	return field.position + field.size * (Vector2(point.x / 100.0, point.z / 56.0) + Vector2(0.5, 0.5))
