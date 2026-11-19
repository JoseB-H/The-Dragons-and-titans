extends "res://scripts/frontier_hud.gd"

func _mode_title() -> String:
	return "CAPTURE POINTS · 5v5"

func _mode_objective() -> String:
	return "Puntos aliados %d/5 · Rivales %d/5" % [arena.owners.count(1),arena.owners.count(2)]

func _map_field(field: Rect2, factor: float) -> void:
	super._map_field(field,factor)
	for i in arena.POINTS.size():
		var color: Color = [GOLD,BLUE,RED][arena.owners[i]]
		draw_arc(_map_position(field,arena.POINTS[i]),6*factor,0,TAU,16,color,2,true)

func _draw() -> void:
	super._draw()
	if not is_instance_valid(arena) or arena.state != 0 or arena.tactical_open:
		return
	var y := get_viewport_rect().size.y - 139
	_caption(Vector2(18,y),"Nivel %d · XP %d · Oro %d" % [arena.level.get(arena.player,1),int(arena.xp.get(arena.player,0)),arena.gold.get(arena.player,0)],GOLD,16)
	_caption(Vector2(18,y+22),"Regreso %.1f s" % arena.home_time if arena.home_time > 0 else "T · Volver a base",Color.WHITE,15)
	_caption(Vector2(18,y+44),"1–5 · Portal aliado desde base",Color.WHITE,15)
