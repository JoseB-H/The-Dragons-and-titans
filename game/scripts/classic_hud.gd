extends "res://scripts/frontier_hud.gd"

func _mode_title() -> String:
	return "EL PACTO · MOBA"

func _mode_objective() -> String:
	return "Destruye las defensas de la jaula" if arena.rival_core.shielded else "¡Jaula rival vulnerable!"

func _draw() -> void:
	super._draw()
	if not is_instance_valid(arena) or arena.state!=0 or arena.tactical_open: return
	var y:=get_viewport_rect().size.y-111
	_caption(Vector2(18,y),"Oro %d · Tesoro %d/60" % [arena.wallets.get(arena.player,0),arena.team_gold[0]],GOLD,16)
	_caption(Vector2(18,y+22),"XP %d · Maná %d" % [arena.experience.get(arena.player,0),int(arena.player.mana)],BLUE,16)
