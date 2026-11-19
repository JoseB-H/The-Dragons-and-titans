extends "res://scripts/frontier.gd"

var bank := [0,0]
var bolts: Array[Dictionary] = []
var potions: Array[Node3D] = []

func _enter_tree() -> void:
	for bot_name in ["Ally","Enemy","Raider"]:
		get_node(bot_name).model_id = _bot_model(0,0)

func _bot_model(_index: int,_side: int) -> StringName:
	return [&"jade",&"cobre"].pick_random()

func _wave_lanes() -> Array:
	return [1]

func _create_tactical_hud() -> Control:
	return preload("res://scripts/aram_hud.gd").new()

func _make_landscape() -> Node3D:
	return preload("res://scripts/halvalas_landscape.gd").new()

func _ready() -> void:
	super._ready()
	player.uses_mana = true
	for side in 2:
		var sign_x := -1 if side == 0 else 1
		for i in 5:
			var dragon: Node3D = teams[side][i]
			dragon.arena_half_size.y = 5.7
			dragon.position = Vector3(sign_x*(33+i%2*2),1.5,(i-2)*1.25)
			spawns[dragon] = dragon.position
			dragon.reset_physics_interpolation()
		for j in 3:
			defenses[side][j].position = Vector3(sign_x*(15+7*j),1.5,0)

func _frontier_target(dragon: Node3D,opponents: Array[Node3D],side: int) -> Node3D:
	var near := _nearest_target(dragon,opponents,8)
	if near != null: return near
	for tower in defenses[1-side]:
		if tower.can_act(): return tower
	return rival_core if side == 0 else home_core

func _regroup(_dragon: Node3D,_delta: float) -> bool:
	return false

func _spawn_wave() -> void:
	super._spawn_wave()
	for unit in constructs:
		if not unit.died.is_connected(_on_minion.bind(unit)):
			unit.died.connect(_on_minion.bind(unit))

func _on_minion(unit: Node3D) -> void:
	bank[2-unit.faction] += 10
	var potion := MeshInstance3D.new()
	var gem := PrismMesh.new()
	gem.size = Vector3(.58,.9,.58)
	potion.mesh = gem
	var mana_drop := randf() < .5
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#40a8ff") if mana_drop else Color("#65e17b")
	potion.material_override = mat
	potion.set_meta("mana",mana_drop)
	potion.set_meta("team",3-unit.faction)
	potion.set_meta("expires",elapsed+25)
	potion.position = unit.position
	potions.append(potion)
	add_child(potion)

func _record_defeat(dragon: Node3D) -> void:
	super._record_defeat(dragon)
	bank[2-dragon.faction] += 25

func _respawn(dragon: Node3D) -> void:
	super._respawn(dragon)
	if dragon == player: player.mana = 100

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if state != MatchState.PLAYING or _restart_pending: return
	for potion in potions.duplicate():
		if elapsed >= float(potion.get_meta("expires")):
			potions.erase(potion)
			potion.queue_free()
			continue
		for dragon in teams[int(potion.get_meta("team"))-1]:
			if not dragon.can_act() or dragon.position.distance_to(potion.position)>1.8: continue
			if potion.get_meta("mana"):
				if dragon != player or player.mana >= 100: continue
				player.mana = minf(100,player.mana+35)
			else:
				if dragon.current_health >= dragon.max_health: continue
				dragon.current_health = mini(dragon.max_health,dragon.current_health+30)
				dragon.health_changed.emit(dragon.current_health,dragon.max_health)
			potions.erase(potion)
			potion.queue_free()
			break
	for side in 2:
		if bank[side] >= 75:
			bank[side] -= 75
			var shot := MeshInstance3D.new()
			var mesh := PrismMesh.new()
			mesh.size = Vector3(2.3,.56,.56)
			shot.mesh = mesh
			var mat := StandardMaterial3D.new()
			mat.albedo_color = [home_core.team_color,rival_core.team_color][side]
			shot.material_override = mat
			shot.position = Vector3(-42 if side == 0 else 42,1.5,0)
			$Effects.add_child(shot)
			bolts.append({"shot":shot,"side":side,"hit":{}})
	for bolt in bolts.duplicate():
		var shot: Node3D = bolt.shot
		var start := shot.position
		shot.position.x += delta*28*(1 if bolt.side == 0 else -1)
		for unit in _match_actors()+constructs:
			if unit.faction == bolt.side+1 or not unit.can_act() or bolt.hit.has(unit.get_instance_id()): continue
			if unit.position.distance_to(Geometry3D.get_closest_point_to_segment(unit.position,start,shot.position)) <= 2.2:
				bolt.hit[unit.get_instance_id()] = true
				unit.take_damage(65,bolt.side+1)
		if absf(shot.position.x)>45:
			shot.queue_free()
			bolts.erase(bolt)
