extends "res://scripts/frontier.gd"

const RUNE_POS := [Vector3(-12, 1.5, -15), Vector3(0, 1.5, 0), Vector3(12, 1.5, 15)]
const RAM := preload("res://scripts/nether_titan.gd")
const CHARGE_TIME := 85.0
var charge := [0.0, 0.0]
var titans: Array[Node3D] = [null, null]
var owners := [0, 0, 0]
var influence := [0.0, 0.0, 0.0]
var landscape: Node3D


func _ready() -> void:
	super._ready()
	home_core.shattered.connect(_free_titan.bind(home_core, 2))
	rival_core.shattered.connect(_free_titan.bind(rival_core, 1))


func _free_titan(gate: Node3D, winner: int) -> void:
	var effigy := preload("res://scripts/nether_effigy.gd").new()
	effigy.name = "LiberatedTitan"
	add_child(effigy)
	effigy.sculpt(winner)
	effigy.rotation.y = PI
	effigy.position = gate.position + Vector3.DOWN * 2.4
	effigy.scale = Vector3.ONE * .55
	var rise := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	rise.tween_property(effigy, "position", gate.position + Vector3.UP * 1.2, 1.25)
	rise.tween_property(effigy, "scale", Vector3.ONE * 1.3, 1.25)
	var arch: Node3D = landscape.lintels[gate.faction - 1]
	rise.tween_property(arch, "position:y", -2.5, .75)
	rise.tween_property(arch, "rotation:x", .95, .75)


func _make_landscape() -> Node3D:
	landscape = preload("res://scripts/nether_landscape.gd").new()
	landscape.points = RUNE_POS
	return landscape


func _create_tactical_hud() -> Control:
	return preload("res://scripts/nether_hud.gd").new()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if state != MatchState.PLAYING or _restart_pending:
		return
	for i in RUNE_POS.size():
		var majority := 0
		for side in 2:
			for dragon in teams[side]:
				if dragon.can_act() and dragon.position.distance_squared_to(RUNE_POS[i]) < 16:
					majority += 1 if side == 0 else -1
		influence[i] = clampf(influence[i] + majority * delta / 3.0, -1, 1)
		if absf(influence[i]) >= 1:
			owners[i] = 1 if influence[i] > 0 else 2
		elif (owners[i] == 1 and influence[i] <= 0) or (owners[i] == 2 and influence[i] >= 0):
			owners[i] = 0
		landscape.show_rune(i, owners[i], influence[i])
	for side in 2:
		if is_instance_valid(titans[side]):
			continue
		charge[side] += delta * (1 + owners.count(side + 1))
		if charge[side] >= CHARGE_TIME:
			charge[side] = 0
			var titan := RAM.new()
			titan.faction = side + 1
			titan.max_health = 820
			titan.gate = rival_core if side == 0 else home_core
			titan.position = Vector3(-31 if side == 0 else 31, 1.5, 0)
			add_child(titan)
			titans[side] = titan


func _regroup(dragon: Node3D, delta: float) -> bool:
	# Las órdenes de patrulla duran un tick. La retirada a base tiene prioridad.
	if dragon.rally_position != spawns[dragon]:
		dragon.rally_position = null
	return super._regroup(dragon, delta)


func _frontier_target(dragon: Node3D, opponents: Array[Node3D], side: int) -> Node3D:
	var hostile: Node3D = titans[1 - side]
	if is_instance_valid(hostile) and hostile.can_act() and dragon.position.distance_to(hostile.position) < 12:
		return hostile
	var near := _nearest_target(dragon, opponents, 8)
	if near != null:
		return near
	var gate: Node3D = rival_core if side == 0 else home_core
	if not gate.shielded:
		return gate
	var escort: Node3D = titans[side]
	var lane: int = lanes[dragon]
	if is_instance_valid(escort) and (lane == 1 or owners[lane] == side + 1):
		dragon.rally_position = escort.position + Vector3(0, 0, (lane - 1) * 2)
	else:
		dragon.rally_position = RUNE_POS[lane]
	return null


func _check_shields() -> void:
	# Solo la embestida del titán abre la puerta en este modo.
	pass


func _match_actors() -> Array[Node3D]:
	var actors := super._match_actors()
	for titan in titans:
		if is_instance_valid(titan):
			actors.append(titan)
	return actors
