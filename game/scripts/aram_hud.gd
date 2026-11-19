extends "res://scripts/frontier_hud.gd"

func _mode_title() -> String:
	return "HALVALAS · ARAM"

func _mode_objective() -> String:
	return "Balista %d/75 · Maná %d/100" % [arena.bank[0],int(arena.player.mana)]

func _map_field(field: Rect2,factor: float) -> void:
	draw_rect(field,INK)
	draw_line(_map_position(field,Vector3(-42,0,0)),_map_position(field,Vector3(42,0,0)),EDGE,4*factor)
	for actor in arena._match_actors()+arena.constructs:
		if is_instance_valid(actor) and actor.can_act():
			draw_circle(_map_position(field,actor.position),3*factor,BLUE if actor.faction==1 else RED)
