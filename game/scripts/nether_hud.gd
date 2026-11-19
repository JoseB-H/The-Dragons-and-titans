extends "res://scripts/frontier_hud.gd"


func _mode_title() -> String:
	return "NETHERGATE · 5v5"


func _mode_objective() -> String:
	if not arena.rival_core.shielded:
		return "Puerta abierta · Ataca el cristal"
	if is_instance_valid(arena.titans[0]):
		return "Escolta a tu titán hasta la puerta"
	return "Captura runas · Titán %d%%" % mini(100, int(arena.charge[0] * 100 / arena.CHARGE_TIME))


func _map_field(field: Rect2, factor: float) -> void:
	super._map_field(field, factor)
	for i in arena.RUNE_POS.size():
		var color: Color = [GOLD, BLUE, RED][arena.owners[i]]
		draw_arc(_map_position(field, arena.RUNE_POS[i]), 5.5 * factor, 0, TAU, 16, color, 2, true)
	for titan in arena.titans:
		if is_instance_valid(titan):
			draw_circle(_map_position(field, titan.position), 4.5 * factor, GOLD)
