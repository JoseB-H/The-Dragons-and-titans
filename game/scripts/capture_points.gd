extends "res://scripts/frontier.gd"

const POINTS := [Vector3(-21,1.5,-14),Vector3(18,1.5,-15),Vector3(0,1.5,0),Vector3(-18,1.5,15),Vector3(21,1.5,14)]
var owners := [0,0,0,0,0]
var progress := [0.,0.,0.,0.,0.]
var guards := [[],[],[],[],[]]
var land: Node3D
var home_time := 0.0
var last_hp := 0
var decay := [0.,0.]
var xp := {}
var gold := {}
var level := {}
var pads: Array[Node3D] = []


func _make_landscape() -> Node3D:
	land = preload("res://scripts/nether_landscape.gd").new()
	land.points = POINTS
	return land


func _create_tactical_hud() -> Control:
	return preload("res://scripts/capture_hud.gd").new()


func _ready() -> void:
	super._ready()
	for side in 2:
		for tower in defenses[side]:
			tower.queue_free()
		defenses[side].clear()
		for dragon in teams[side]:
			xp[dragon] = 0.
			gold[dragon] = 0
			level[dragon] = 1
			dragon.position = base(side) + Vector3(0,0,teams[side].find(dragon)-2)
			spawns[dragon] = dragon.position
			dragon.reset_physics_interpolation()
		for i in POINTS.size():
			var pad := MeshInstance3D.new()
			var ring := TorusMesh.new()
			ring.inner_radius = .65
			ring.outer_radius = .85
			pad.mesh = ring
			pad.position = base(side) + Vector3(0,-1.3,(i-2)*2.15)
			add_child(pad)
			pads.append(pad)
			var label := Label3D.new()
			label.text = str(i+1)
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.position.y = .6
			pad.add_child(label)
			_set_pad(side,i)
	last_hp = player.current_health
	player.health_changed.connect(_health_changed)


func base(side: int) -> Vector3:
	return Vector3(-37 if side == 0 else 37,1.5,0)


func _health_changed(hp: int, _maximum: int) -> void:
	if hp < last_hp:
		home_time = 0
	last_hp = hp


func _regroup(dragon: Node3D, delta: float) -> bool:
	if dragon.rally_position != spawns[dragon]:
		dragon.rally_position = null
	return super._regroup(dragon,delta)


func _frontier_target(dragon: Node3D, opponents: Array[Node3D], side: int) -> Node3D:
	var near := _nearest_target(dragon,opponents,7)
	if near != null:
		return near
	var i: int = teams[side].find(dragon)
	if side == 1:
		i = 4-i
	for shift in POINTS.size():
		var idx: int = (i+shift)%POINTS.size()
		if owners[idx] == side+1:
			continue
		for tower in guards[idx]:
			if tower.can_act():
				return tower
		dragon.rally_position = POINTS[idx]
		return null
	return null


func _set_pad(side: int,i: int) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#52e5c5") if owners[i] == side+1 else Color("#535461")
	pads[side*5+i].material_override = mat


func _occupy(i: int, faction: int) -> void:
	for old in guards[i]:
		defenses[old.faction-1].erase(old)
		old.queue_free()
	guards[i].clear()
	owners[i] = faction
	for j in 4:
		var tower := TOWER_SCENE.instantiate()
		var angle := PI/4 + TAU*j/4
		tower.position = POINTS[i] + Vector3(cos(angle),0,sin(angle))*3.2
		tower.faction = faction
		tower.max_health = 55
		tower.team_color = [home_core.team_color,rival_core.team_color][faction-1]
		add_child(tower)
		tower.weapon.projectile_parent = $Projectiles
		defenses[faction-1].append(tower)
		guards[i].append(tower)
	for side in 2:
		_set_pad(side,i)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if state != MatchState.PLAYING or _restart_pending:
		return
	for i in POINTS.size():
		var advantage := 0
		for side in 2:
			for dragon in teams[side]:
				if dragon.can_act() and dragon.position.distance_squared_to(POINTS[i]) <= 16:
					advantage += 1 if side == 0 else -1
		if not guards[i].any(func(tower): return tower.can_act()):
			progress[i] = clampf(progress[i]+advantage*delta/3,-1,1)
			if progress[i] == 1 and owners[i] != 1:
				_occupy(i,1)
			elif progress[i] == -1 and owners[i] != 2:
				_occupy(i,2)
		land.show_rune(i,owners[i],progress[i])
		land.signs[i].text = str(i+1) + land.signs[i].text.substr(1)
	for side in 2:
		var core: Node3D = [home_core,rival_core][side]
		decay[side] += delta * owners.count(2-side) * 2.0
		if decay[side] >= 1 and core.is_alive():
			core.current_health = maxi(0,core.current_health-int(decay[side]))
			decay[side] -= floorf(decay[side])
			core.health_changed.emit(core.current_health,core.max_health)
			if not core.is_alive():
				core.died.emit()
		for dragon in teams[side]:
			xp[dragon] += delta
			if dragon.can_act() and gold[dragon] > 0 and _can_deposit(dragon,side):
				xp[dragon] += gold[dragon]
				gold[dragon] = 0
			var rank := 1 + floori(xp[dragon]/30.)
			if rank > level[dragon]:
				dragon.max_health += (rank-int(level[dragon]))*5
				level[dragon] = rank
	if home_time > 0:
		home_time = maxf(0,home_time-delta)
		if home_time == 0 and player.can_act():
			player.position = base(0) + Vector3.LEFT * 2
			player.reset_physics_interpolation()
	if player.can_act():
		for i in POINTS.size():
			if owners[i] == 1 and player.position.distance_squared_to(pads[i].position + Vector3.UP*1.3) < .8:
				_travel(i)


func _can_deposit(dragon: Node3D,side: int) -> bool:
	if dragon.position.distance_to(base(side)) < 5:
		return true
	for i in POINTS.size():
		if owners[i] == side+1 and dragon.position.distance_to(POINTS[i]) < 4:
			return true
	return false


func _record_defeat(dragon: Node3D) -> void:
	super._record_defeat(dragon)
	for ally in teams[2-dragon.faction]:
		if ally.can_act() and ally.position.distance_to(dragon.position) < 9:
			gold[ally] += 5


func _travel(i: int) -> void:
	if player.can_act() and owners[i] == 1 and player.position.distance_to(base(0)) < 6:
		home_time = 0
		player.position = POINTS[i]
		player.reset_physics_interpolation()


func _unhandled_input(event: InputEvent) -> void:
	if state == MatchState.PLAYING and player.can_act() and event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_T and home_time == 0:
			home_time = 2.5
			return
		if event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_5:
			_travel(event.physical_keycode-KEY_1)
			return
	super._unhandled_input(event)
