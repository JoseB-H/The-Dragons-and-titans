extends Control

const BLUE := Color(0.4, 0.85, 1.0)
const RED := Color(1.0, 0.49, 0.3)
const INK := Color(0.06, 0.07, 0.10, 0.94)
const EDGE := Color(0.56, 0.43, 0.32)
const GOLD := Color(0.98, 0.86, 0.68)

var arena: Node3D
var _font := ThemeDB.fallback_font


func setup(match_arena: Node3D) -> void:
	arena = match_arena
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _draw() -> void:
	if not is_instance_valid(arena):
		return
	var viewport := get_viewport_rect().size
	var center := viewport.x * 0.5
	var north := Rect2(center - 260, 18, 520, 69)
	_panel(north)
	_caption(Vector2(north.position.x + 15, 44), "Aliado · Escudo" if arena.home_core.shielded else "Núcleo aliado", BLUE, 17)
	_caption(Vector2(north.end.x - 180, 44), "Rival · Escudo" if arena.rival_core.shielded else "Núcleo rival", RED, 17)
	_bar(Rect2(north.position.x + 15, 56, 150, 10), arena.home_core, BLUE)
	_bar(Rect2(north.end.x - 165, 56, 150, 10), arena.rival_core, RED)
	var seconds := int(arena.elapsed)
	_caption(Vector2(center - 25, 58), "%02d:%02d" % [floori(seconds / 60.0), seconds % 60], GOLD, 18)

	var deck := Rect2(center - 249, viewport.y - 95, 498, 77)
	_panel(deck)
	_caption(deck.position + Vector2(14, 24), "%s / %s" % [arena.player.profile_name, arena.player.equipment_name], GOLD, 17)
	_bar(Rect2(deck.position + Vector2(14, 38), Vector2(180, 10)), arena.player, BLUE)
	var weapons := ["Weapon", "PowerWeapon", "PulseAbility"]
	var keys := ["Clic", "Q", "E"]
	for index in range(weapons.size()):
		var remaining: float = arena.player.get_node(weapons[index]).cooldown_remaining
		var text := "Listo" if remaining <= 0 else "%.1f s" % remaining
		var point := deck.position + Vector2(218 + 88 * index, 12)
		_panel(Rect2(point, Vector2(76, 52)))
		_caption(point + Vector2(9, 20), keys[index], GOLD, 15)
		_caption(point + Vector2(9, 40), text, BLUE if remaining <= 0 else Color.LIGHT_GRAY, 14)

	if arena.state == 0:
		_caption(Vector2(20, 32), _mode_title(), GOLD, 18)
		_caption(Vector2(20, 55), _mode_objective(), Color.WHITE, 16)
		var instructions := "WASD / clic der. · Espacio atrás · Rueda zoom"
		if arena.player.waiting_for_release():
			instructions = "Suelta las teclas y el clic para continuar."
		_caption(Vector2(20, viewport.y - 26), instructions, Color.WHITE, 15)
		_draw_world_bars()
		_draw_map(Rect2(viewport.x - 165, viewport.y - 165, 145, 145))


func _draw_world_bars() -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var actors: Array[Node3D] = arena._match_actors()
	for unit in actors:
		if not unit.is_alive():
			continue
		var anchor: Vector3 = unit.global_position + Vector3.UP * (2.1 if unit in arena.bots or unit == arena.player else 1.6)
		if camera.is_position_behind(anchor):
			continue
		var point := camera.unproject_position(anchor)
		_bar(Rect2(point - Vector2(34, 4), Vector2(68, 7)), unit, BLUE if unit.faction == 1 else RED)


func _draw_map(rect: Rect2) -> void:
	_panel(rect)
	var field := rect.grow(-11)
	draw_rect(field, Color(0.20, 0.13, 0.11))
	draw_line(field.position + Vector2(0, field.size.y / 2), field.end - Vector2(0, field.size.y / 2), EDGE)
	for unit in arena._match_actors():
		if not unit.is_alive():
			continue
		var fraction := Vector2(unit.position.x, unit.position.z) / 22.0 + Vector2(0.5, 0.5)
		var point := field.position + field.size * fraction
		var color := BLUE if unit.faction == 1 else RED
		if unit == arena.home_core or unit == arena.rival_core:
			draw_rect(Rect2(point - Vector2(4, 4), Vector2(8, 8)), color)
		elif unit == arena.home_tower or unit == arena.rival_tower:
			draw_rect(Rect2(point - Vector2(2, 2), Vector2(4, 4)), color)
		else:
			draw_circle(point, 5.0 if unit == arena.player else 3.5, Color.WHITE if unit == arena.player else color)


func _panel(rect: Rect2) -> void:
	draw_rect(rect, INK)
	draw_rect(rect, EDGE, false, 1.0)


func _bar(rect: Rect2, actor: Node3D, color: Color) -> void:
	draw_rect(rect.grow(1.0), INK)
	var fill := rect
	fill.size.x *= float(actor.current_health) / actor.max_health
	draw_rect(fill, color)


func _caption(point: Vector2, text: String, color: Color, font_size: int) -> void:
	draw_string(_font, point + Vector2(1, 1), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
	draw_string(_font, point, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _mode_title() -> String:
	return "ASEDIO DE LA CALDERA"


func _mode_objective() -> String:
	return "Derriba la torre rival" if arena.rival_core.shielded else "Destruye el núcleo rival"
