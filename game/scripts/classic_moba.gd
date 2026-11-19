extends "res://scripts/frontier.gd"

const OBJECTIVE := preload("res://scripts/siege_core.gd")
const EFFIGY := preload("res://scripts/nether_effigy.gd")
var structures := [[],[]]
var hoards := [[],[]]
var veils := [[],[]]
var wallets := {}
var experience := {}
var speed := {}
var team_gold := [0,0]
var chaos: Node3D
var heal_clock := 0.0
var ram_clock := 0.0

func _create_tactical_hud() -> Control:
	return preload("res://scripts/classic_hud.gd").new()

func _ready() -> void:
	super._ready()
	player.uses_mana = true
	for side in 2:
		var sign_x := -1 if side == 0 else 1
		for i in 6:
			var lane := i%3
			var shrine := i in [1,4]
			var actor := OBJECTIVE.new()
			actor.name = ("Santuario" if shrine else "Obelisco")+str(side)+str(i)
			actor.faction = side+1
			actor.max_health = 170 if shrine else 120
			actor.team_color = [home_core.team_color,rival_core.team_color][side]
			actor.position = Vector3(sign_x*(27+5*floori(i/3.0)),1.5,LANES[lane])
			var collider := CollisionShape3D.new()
			var sphere := SphereShape3D.new()
			sphere.radius = 1.2
			collider.shape = sphere
			actor.add_child(collider)
			add_child(actor)
			if not shrine: actor.scale = Vector3(.85,1.35,.85)
			var label := Label3D.new()
			label.text = "Santuario" if shrine else "Obelisco"
			label.position.y = 2.15
			label.pixel_size = .01
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			actor.add_child(label)
			structures[side].append(actor)
			var tower: Node3D = defenses[side][[1,0,2][lane]]
			tower.died.connect(actor.drop_shield)
			actor.died.connect(_check_shields)
			actor.died.connect(actor.hide)
		for dragon in teams[side]:
			wallets[dragon] = 0
			experience[dragon] = 0
			speed[dragon] = dragon.movement_speed
		for lane in 3:
			var point := Vector3(sign_x*36,1.5,LANES[lane])
			hoards[side].append(point)
			_marker(point,Vector3(3,1,3),Color("#efb83b"),true)
			var veil := _marker(Vector3(sign_x*19,1.4,LANES[lane]),Vector3(.4,2.4,5),[home_core.team_color,rival_core.team_color][side],false)
			veils[side].append(veil)
			defenses[side][[1,0,2][lane]].died.connect(veil.hide)

func _marker(pos: Vector3, dims: Vector3, tint: Color, ring: bool) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(tint,.75 if ring else .36)
	instance.mesh = TorusMesh.new() if ring else BoxMesh.new()
	instance.material_override = mat
	instance.scale = dims
	instance.position = pos-Vector3.UP*1.3 if ring else pos
	add_child(instance)
	return instance

func _check_shields() -> void:
	for side in 2:
		var cage: Node3D = [home_core,rival_core][side]
		if cage.shielded and structures[side].size()==6 and structures[side].all(func(obj): return not obj.is_alive()):
			cage.drop_shield()

func _match_actors() -> Array[Node3D]:
	var actors := super._match_actors()
	actors.append_array(structures[0]+structures[1])
	if is_instance_valid(chaos): actors.append(chaos)
	return actors

func _frontier_target(dragon: Node3D, opponents: Array[Node3D], side: int) -> Node3D:
	if is_instance_valid(chaos) and chaos.faction!=side+1 and chaos.can_act() and dragon.position.distance_to(chaos.position)<10:
		return chaos
	var standard := super._frontier_target(dragon,opponents,side)
	if standard==home_core or standard==rival_core:
		for obj in structures[1-side]:
			if obj.can_act() and not obj.shielded: return obj
	return standard

func _regroup(dragon: Node3D, delta: float) -> bool:
	if int(wallets.get(dragon,0)) >= 15 and dragon.can_act():
		dragon.rally_position = hoards[dragon.faction-1][lanes[dragon]]
		dragon.target = null
		return true
	if dragon.rally_position != spawns[dragon]: dragon.rally_position = null
	return super._regroup(dragon,delta)

func _award(at: Vector3, side: int, value: int) -> void:
	var nearest: Node3D
	var best := 14.0
	for dragon in teams[side]:
		var distance: float = dragon.position.distance_to(at)
		if dragon.can_act() and distance<best:
			nearest = dragon
			best = distance
	if nearest!=null: wallets[nearest] += value

func _record_defeat(dragon: Node3D) -> void:
	super._record_defeat(dragon)
	_award(dragon.position,2-dragon.faction,15)

func _spawn_wave() -> void:
	super._spawn_wave()
	for unit in constructs:
		if unit.has_meta("gold"): continue
		unit.set_meta("gold",true)
		unit.died.connect(func(): _award(unit.position,2-unit.faction,5))

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if state!=MatchState.PLAYING or _restart_pending: return
	heal_clock += delta
	var tick := heal_clock>=1
	if tick: heal_clock -= 1
	for side in 2:
		for dragon in teams[side]:
			var safe: bool = hoards[side].any(func(p): return dragon.position.distance_to(p)<3.2)
			var slow: bool = veils[1-side].any(func(v): return v.visible and absf(dragon.position.x-v.position.x)<1 and absf(dragon.position.z-v.position.z)<2.8)
			dragon.hoard_protection = safe
			dragon.movement_speed = speed[dragon]*(.5 if slow and not safe else 1.)
			if not safe or not dragon.can_act(): continue
			if tick:
				_heal(dragon,10)
				if dragon==player: player.mana=minf(100,player.mana+10)
			var earned: int = wallets[dragon]
			if earned>0:
				var before := floori(experience[dragon]/30.)
				experience[dragon]+=earned
				dragon.max_health+=5*(floori(experience[dragon]/30.)-before)
				team_gold[side]+=earned
				wallets[dragon]=0
		if team_gold[side]>=60 and not is_instance_valid(chaos):
			team_gold[side]-=60
			_summon(side)
	if is_instance_valid(chaos) and chaos.can_act():
		var opposite: int = 2-chaos.faction
		var target: Node3D = [home_core,rival_core][opposite]
		for obj in defenses[opposite]+structures[opposite]:
			if obj.can_act():
				target=obj
				break
		var span: float = chaos.position.distance_to(target.position)
		if span>2.5:
			chaos.look_at(target.position)
			chaos.position=chaos.position.move_toward(target.position,delta*4)
		elif ram_clock<=0:
			target.take_damage(60,chaos.faction)
			ram_clock=1.5
		ram_clock-=delta
		if tick:
			for dragon in teams[chaos.faction-1]:
				if dragon.can_act() and dragon.position.distance_to(chaos.position)<6: _heal(dragon,10)

func _summon(side: int) -> void:
	chaos=preload("res://scripts/combat_actor.gd").new()
	chaos.faction=side+1
	chaos.max_health=700
	chaos.position=hoards[side][1]
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius=1.35
	shape.shape=sphere
	chaos.add_child(shape)
	add_child(chaos)
	var body:=EFFIGY.new()
	chaos.add_child(body)
	body.sculpt(side+1)
	chaos.died.connect(chaos.queue_free)

func _heal(dragon: Node3D, amount: int) -> void:
	dragon.current_health=mini(dragon.max_health,dragon.current_health+amount)
	dragon.health_changed.emit(dragon.current_health,dragon.max_health)
