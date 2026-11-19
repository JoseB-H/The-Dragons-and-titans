extends "res://scripts/siege_arena.gd"

const BOT_SCENE := preload("res://scenes/enemy.tscn")
const TOWER_SCENE := preload("res://scenes/siege_tower.tscn")
const FRONTIER_HUD := preload("res://scripts/frontier_hud.gd")
const LANDSCAPE := preload("res://scripts/frontier_landscape.gd")
const CONSTRUCT := preload("res://scripts/lane_construct.gd")
const WAVE_INTERVAL := 12.0
const LANES := [-15.0, 0.0, 15.0]

var teams: Array[Array] = [[], []]
var defenses: Array[Array] = [[], []]
var lanes: Dictionary = {}
var spawns: Dictionary = {}
var returns: Dictionary = {}
var scores := [0, 0]
var tactical_open := false
var outcome_banner: Label
var wave_number := 0
var next_wave_at := 5.0
var constructs: Array[Node3D] = []


func _ready() -> void:
	teams = [[player, ally], [enemy, raider]]
	defenses = [[home_tower], [rival_tower]]
	home_tower.team_color = Color(0.32, 0.8, 1.0)
	for side in range(2):
		var sign_x := -1.0 if side == 0 else 1.0
		var core: Node3D = [home_core, rival_core][side]
		core.position = Vector3(sign_x * 40, 1.5, 0)
		core.max_health = 600
		core.current_health = core.max_health
		defenses[side][0].position = Vector3(sign_x * 23, 1.5, 0)
		for lane in [0, 2]:
			var tower := TOWER_SCENE.instantiate()
			tower.faction = side + 1
			tower.team_color = core.team_color
			tower.position = Vector3(sign_x * 23, 1.5, LANES[lane])
			add_child(tower)
			defenses[side].append(tower)
		for index in range(3):
			var dragon := BOT_SCENE.instantiate()
			dragon.faction = side + 1
			dragon.model_id = _bot_model(index,side)
			add_child(dragon)
			teams[side].append(dragon)
		for index in range(5):
			var dragon: Node3D = teams[side][index]
			var lane: int = [0, 1, 2, 0, 2][index]
			lanes[dragon] = lane
			dragon.arena_half_size = Vector2(47, 27)
			dragon.position = Vector3(sign_x * (34 + (index % 2) * 3), 1.5, LANES[lane] + (index % 2) * 2)
			dragon.reset_physics_interpolation()
			spawns[dragon] = dragon.position
			dragon.died.connect(_record_defeat.bind(dragon))
			if dragon != player:
				dragon.movement_speed = 5.2
				dragon.attack_range = 6.2

	bots.assign(teams[0].slice(1) + teams[1])
	super._ready()
	home_tower.died.disconnect(home_core.drop_shield)
	rival_tower.died.disconnect(rival_core.drop_shield)
	for side in range(2):
		for tower in defenses[side]:
			tower.max_health = 185
			tower.current_health = 185
			tower.attack_range = 7.5
			tower.weapon.projectile_parent = $Projectiles
			tower.weapon.luminous_trail = true
			tower.weapon.projectile_tint = tower.team_color
			tower.died.connect(_check_shields)
		for bot in teams[side]:
			bot.get_node("Facing").bank_enabled = true
			if bot != player:
				bot.weapon.projectile_tint = [home_core.team_color, rival_core.team_color][side]
	$Ground.hide()
	$CalderaArt.hide()
	add_child(_make_landscape())
	$Sun.directional_shadow_max_distance = 68
	player.camera.position = Vector3(8, 22, 12)
	player.camera.look_at(player.global_position)
	player.camera.size = 17.2


func _bot_model(index: int,side: int) -> StringName:
	return [&"jade", &"sentinela", &"cobre"][(index + side) % 3]


func _wave_lanes() -> Array:
	return [0,1,2]


func _make_landscape() -> Node3D:
	return LANDSCAPE.new()


func _physics_process(delta: float) -> void:
	if state != MatchState.PLAYING or _restart_pending:
		return
	if _defeat_ready():
		_finish_match(MatchState.DEFEAT)
		return
	if _victory_ready(delta):
		_finish_match(MatchState.VICTORY)
		return
	elapsed += delta
	constructs = constructs.filter(func(unit): return is_instance_valid(unit) and unit.can_act())
	if elapsed >= next_wave_at:
		_spawn_wave()
		next_wave_at += WAVE_INTERVAL
	for dragon in returns.keys():
		if elapsed >= returns[dragon]:
			_respawn(dragon)
	for side in range(2):
		var opponents: Array[Node3D] = []
		opponents.assign(teams[1 - side])
		var enemy_towers: Array = defenses[1 - side]
		var enemy_core: Node3D = rival_core if side == 0 else home_core
		var units: Array[Node3D] = []
		for unit in constructs:
			if unit.faction == side + 1:
				units.append(unit)
			else:
				opponents.append(unit)
		var targets := opponents.duplicate()
		targets.append_array(enemy_towers)
		if not enemy_core.shielded:
			targets.append(enemy_core)
		for unit in units:
			unit.target = _nearest_target(unit, targets, 4.0)
		for tower in defenses[side]:
			tower.defend(opponents)
		for dragon in teams[side]:
			if dragon != player:
				if _regroup(dragon, delta):
					continue
				dragon.target = _frontier_target(dragon, opponents, side)


func _frontier_target(dragon: Node3D, opponents: Array[Node3D], side: int) -> Node3D:
	var nearest := _nearest_target(dragon, opponents, 10.0)
	if nearest != null:
		return nearest
	var towers := defenses[1 - side]
	var assigned: Node3D = towers[[1, 0, 2][lanes[dragon]]]
	if assigned.is_alive():
		return assigned
	for tower in towers:
		if tower.is_alive():
			return tower
	return rival_core if side == 0 else home_core


func _nearest_target(actor: Node3D, targets: Array[Node3D], radius: float) -> Node3D:
	var nearest: Node3D
	var threshold := radius * radius
	for candidate in targets:
		var distance := actor.position.distance_squared_to(candidate.position)
		if candidate.can_act() and distance < threshold:
			nearest = candidate
			threshold = distance
	return nearest


func _spawn_wave() -> void:
	wave_number += 1
	for side in range(2):
		var sign_x := -1.0 if side == 0 else 1.0
		for lane in _wave_lanes():
			var active := constructs.filter(func(unit): return unit.faction == side + 1 and unit.lane == lane)
			if active.size() >= 2:
				continue
			var unit := CONSTRUCT.new()
			unit.lane = lane
			unit.faction = side + 1
			unit.max_health = 32
			unit.collision_mask = 0
			unit.advance_direction = -sign_x
			unit.position = Vector3(sign_x * 33.0, 1.5, LANES[lane])
			add_child(unit)
			unit.weapon.projectile_parent = $Projectiles
			constructs.append(unit)


func _regroup(dragon: Node3D, delta: float) -> bool:
	if not dragon.is_alive():
		return false
	if dragon.rally_position == null:
		if dragon.current_health * 4 > dragon.max_health:
			return false
		dragon.rally_position = spawns[dragon]
		dragon.target = null
	var rally: Vector3 = dragon.rally_position
	if dragon.position.distance_squared_to(rally) < 2.25:
		var healed := mini(dragon.max_health, dragon.current_health + maxi(1, roundi(60.0 * delta)))
		dragon.current_health = healed
		dragon.health_changed.emit(healed, dragon.max_health)
		if healed * 4 >= dragon.max_health * 3:
			dragon.rally_position = null
	return dragon.rally_position != null


func _finish_match(result: MatchState) -> void:
	if state != MatchState.PLAYING:
		return
	tactical_open = false
	hud.hide()
	for unit in constructs:
		if is_instance_valid(unit):
			unit.combat_enabled = false
			unit.queue_free()
	constructs.clear()
	super._finish_match(result)
	var core: Node3D = rival_core if result == MatchState.VICTORY else home_core
	var shot := Camera3D.new()
	add_child(shot)
	var start: Camera3D = player.camera
	shot.projection = Camera3D.PROJECTION_ORTHOGONAL
	shot.global_transform = start.global_transform
	shot.size = start.size
	shot.make_current()
	var focus := core.global_position
	var end_position := focus + Vector3(6, 9, 9)
	var flight := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	flight.tween_property(shot, "global_transform", Transform3D(
		Basis.looking_at(focus - end_position), end_position), 1.25)
	flight.parallel().tween_property(shot, "size", 8.5, 1.25)
	flight.tween_callback(func():
		core.shatter()
		var overlay := CanvasLayer.new()
		add_child(overlay)
		outcome_banner = Label.new()
		overlay.add_child(outcome_banner)
		outcome_banner.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		outcome_banner.offset_top = get_viewport().get_visible_rect().size.y * 0.13
		outcome_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		outcome_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		outcome_banner.text = "VICTORIA" if result == MatchState.VICTORY else "DERROTA"
		outcome_banner.add_theme_font_size_override("font_size", 54)
		outcome_banner.add_theme_constant_override("outline_size", 8)
		outcome_banner.add_theme_color_override("font_outline_color", Color("#34221e"))
		outcome_banner.modulate = Color("#ffe3a0") if result == MatchState.VICTORY else Color("#ff9c83")
	)
	flight.tween_interval(1.45)
	flight.tween_callback(func():
		outcome_banner.hide()
		_tactical_hud.hide()
		hud.get_node("ResultPanel/Margin/Content/Hint").text = "Bajas %d — %d   ·   %02d:%02d   ·   Oleada %d" % [
			scores[0], scores[1], floori(elapsed / 60), int(elapsed) % 60, wave_number]
		hud.show()
		hud.restart_button.grab_focus()
	)


func _check_shields() -> void:
	for side in range(2):
		var core: Node3D = [home_core, rival_core][side]
		if core.shielded and defenses[side].all(func(tower): return not tower.is_alive()):
			core.drop_shield()


func _record_defeat(dragon: Node3D) -> void:
	returns[dragon] = elapsed + 6.0
	scores[2 - dragon.faction] += 1


func _respawn(dragon: Node3D) -> void:
	returns.erase(dragon)
	dragon.position = spawns[dragon]
	if dragon != player:
		dragon.rally_position = null
	dragon.reset_physics_interpolation()
	dragon.current_health = dragon.max_health
	dragon.health_changed.emit(dragon.current_health, dragon.max_health)
	for ability in [&"Weapon", &"PowerWeapon", &"PulseAbility"]:
		var item := dragon.get_node_or_null(NodePath(ability))
		if item != null:
			item.cooldown_remaining = 0.0
	dragon.get_node("Facing").death_amount = 0.0


func _defeat_ready() -> bool:
	return not home_core.is_alive()


func _match_actors() -> Array[Node3D]:
	var actors: Array[Node3D] = []
	actors.assign(teams[0] + teams[1] + defenses[0] + defenses[1] + [home_core, rival_core])
	return actors


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == KEY_M and event.pressed and not event.echo:
		if state == MatchState.PLAYING:
			tactical_open = not tactical_open
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)


func _create_tactical_hud() -> Control:
	return FRONTIER_HUD.new()


func seconds_to_respawn() -> int:
	return maxi(0, ceili(returns.get(player, elapsed) - elapsed))
