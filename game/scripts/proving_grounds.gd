extends Node3D

enum Phase { FLIGHT, DEFEND, BANK, DUEL, TOWERS, SHRINE, CAGE, WON, LOST }
const INSTRUCTIONS := [
	"Vuela con WASD hasta la flecha. Apunta con el cursor.",
	"Defiende el obelisco. Usa clic para disparar, Q para un tiro potente y E para el pulso.",
	"Lleva el oro al círculo dorado del tesoro aliado.",
	"Vence al dragón rival. Retrocede mientras mantienes la mira sobre él.",
	"Destruye ambas torres elementales para retirar el escudo del santuario.",
	"Derriba el santuario para exponer la jaula.",
	"Destruye la jaula y libera a tu titán.",
	"Victoria · Has liberado al titán.",
	"Derrota · El obelisco ha caído."
]
const BASE := Vector3(-40,1.5,0)
const BANK := Vector3(-34,1.5,0)
const OBELISK := Vector3(-12,1.5,0)
const LIMIT := 25
@onready var player = $Dragon
var phase := Phase.FLIGHT
var purse := 0
var intro_time := 1.6
var bars: Array[ProgressBar] = []
var points := 0
var respawn := 0.0
var impact_pause := 0.0
var shake := 0.0
var obelisk: Node3D
var shrine: Node3D
var cage: Node3D
var rival: Node3D
var towers: Array[Node3D] = []
var minions: Array[Node3D] = []
var arrow := Label3D.new()
var overlay := CanvasLayer.new()
var top := Label.new()
var objective := Label.new()
var stats := Label.new()
var radar := Control.new()
var upgrade := Button.new()
var goal := OBELISK
var defeats := 0

func _ready() -> void:
	player.uses_mana = true
	if get_node("/root/DragonRoster").training_record().get_value("mission","trail",false):
		player.weapon.luminous_trail = true
		player.weapon.projectile_tint = Color.AQUAMARINE
	player.weapon.projectile_parent = $Effects
	player.power_weapon.projectile_parent = $Effects
	player.pulse_ability.effects_parent = $Effects
	player.died.connect(func(): respawn = 3.0; player.facing.hide())
	player.camera.position = Vector3(3,23,13)
	player.camera.look_at(player.global_position)
	player.camera.size = 10
	player.combat_enabled = false
	_core(BASE-Vector3.RIGHT*2, "Jaula aliada", 1, 250)
	obelisk = _core(OBELISK, "Obelisco", 1, 320)
	obelisk.drop_shield()
	obelisk.died.connect(_end.bind(false))
	shrine = _core(Vector3(25,1.5,0), "Santuario", 2, 140)
	cage = _core(Vector3(39,1.5,0), "Jaula del titán", 2, 230)
	shrine.died.connect(func(): phase = Phase.CAGE; cage.drop_shield(); shrine.shatter())
	cage.died.connect(_end.bind(true))
	for z in [-4,4]:
		var tower = preload("res://scenes/siege_tower.tscn").instantiate()
		tower.position = Vector3(20,1.5,z)
		tower.faction = 2
		tower.team_color = Color.CORAL
		tower.max_health = 85
		add_child(tower)
		tower.combat_enabled = false
		tower.weapon.projectile_parent = $Effects
		tower.died.connect(tower.hide)
		_watch(tower)
		towers.append(tower)
	var ring := MeshInstance3D.new()
	ring.mesh = TorusMesh.new()
	ring.scale = Vector3(2,.4,2)
	ring.position = BANK - Vector3.UP*1.25
	var gold := StandardMaterial3D.new()
	gold.albedo_color = Color.GOLD
	ring.material_override = gold
	add_child(ring)
	arrow.text = "➤"
	arrow.modulate = Color.GREEN_YELLOW
	arrow.font_size = 96
	arrow.pixel_size = .018
	arrow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(arrow)
	_build_hud()

func _core(at: Vector3, title: String, side: int, hp: int) -> Node3D:
	var actor = preload("res://scripts/siege_core.gd").new()
	actor.position = at
	actor.faction = side
	actor.max_health = hp
	actor.team_color = Color.SKY_BLUE if side == 1 else Color.ORANGE_RED
	var collider := CollisionShape3D.new()
	collider.shape = SphereShape3D.new()
	collider.shape.radius = 1.2
	actor.add_child(collider)
	add_child(actor)
	var label := Label3D.new()
	label.text = title
	label.position.y = 2
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	actor.add_child(label)
	_watch(actor)
	return actor

func _watch(actor: Node3D) -> void:
	var previous := [int(actor.current_health)]
	actor.health_changed.connect(func(hp: int, _maximum: int):
		var damage := int(previous[0])-hp
		previous[0] = hp
		if damage <= 0: return
		if not actor.is_inside_tree(): return
		shake = .12
		if damage >= 25 and impact_pause <= 0:
			impact_pause = .045
			get_tree().paused = true
			get_tree().create_timer(impact_pause,true,false,true).timeout.connect(_resume_impact)
		var number := Label3D.new()
		number.text = "−%d" % damage
		number.modulate = Color.GOLD
		number.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		number.position = actor.position + Vector3.UP*2
		add_child(number)
		var fade := number.create_tween()
		fade.tween_interval(.06)
		fade.tween_property(number,"position:y",number.position.y+1.3,.4)
		fade.parallel().tween_property(number,"modulate:a",0,.4)
		fade.tween_callback(number.queue_free))

func _wave() -> void:
	for i in 3:
		var unit = preload("res://scripts/lane_construct.gd").new()
		unit.faction = 2
		unit.max_health = 35
		unit.position = OBELISK + Vector3(5+i,0,(i-1)*2)
		add_child(unit)
		unit.weapon.projectile_parent = $Effects
		unit.target = obelisk
		unit.died.connect(func(): defeats += 1; purse = mini(LIMIT,purse+10))
		minions.append(unit)
		_watch(unit)

func _spawn_rival() -> void:
	rival = preload("res://scenes/enemy.tscn").instantiate()
	rival.arena_half_size = Vector2(48,22)
	rival.position = Vector3(4,1.5,0)
	rival.max_health = 95
	add_child(rival)
	rival.weapon.projectile_parent = $Effects
	rival.target = player
	_watch(rival)
	rival.died.connect(func():
		rival.hide()
		phase = Phase.TOWERS
		for tower in towers: tower.combat_enabled = true)

func _physics_process(delta: float) -> void:
	if phase >= Phase.WON: return
	if intro_time > 0:
		intro_time = maxf(0,intro_time-delta)
		player.camera.size = lerpf(18,10,smoothstep(0,1.6,intro_time))
		objective.text = "La jaula aliada · Aquí reaparecerás si caes"
		if intro_time == 0: player.combat_enabled = true
		return
	if respawn > 0:
		respawn = maxf(0,respawn-delta)
		if respawn == 0:
			player.position = BASE
			player.reset_physics_interpolation()
			player.current_health = player.max_health
			player.health_changed.emit(player.current_health,player.max_health)
			player.mana = 100
			player.facing.show()
	player.mana = minf(100,player.mana+delta*3)
	shake = maxf(0,shake-delta)
	player.camera.h_offset = sin(shake*115)*shake
	match phase:
		Phase.FLIGHT:
			if player.position.distance_to(OBELISK)<4:
				phase = Phase.DEFEND
				_wave()
		Phase.DEFEND:
			if defeats == 3: phase = Phase.BANK
		Phase.BANK:
			goal = BANK
			if player.can_act() and player.position.distance_to(BANK)<3:
				purse = 0
				points += 1
				phase = Phase.DUEL
				_spawn_rival()
		Phase.DUEL: goal = rival.position
		Phase.TOWERS:
			var live := towers.filter(func(t): return t.is_alive())
			if live.is_empty():
				phase = Phase.SHRINE
				shrine.drop_shield()
			else:
				goal = live[0].position
				var targets: Array[Node3D] = [player]
				for tower in live: tower.defend(targets)
		Phase.SHRINE: goal = shrine.position
		Phase.CAGE: goal = cage.position
	var direction: Vector3 = goal-player.position
	arrow.position = player.position + direction.limit_length(4) + Vector3.UP*.8
	var screen_dir: Vector2 = player.camera.unproject_position(goal)-player.camera.unproject_position(player.position)
	arrow.text = ["→","↘","↓","↙","←","↖","↑","↗"][posmod(roundi(screen_dir.angle()/(PI/4)),8)]
	_refresh()

func _end(won: bool) -> void:
	if phase >= Phase.WON: return
	phase = Phase.WON if won else Phase.LOST
	player.camera.h_offset = 0
	if won:
		cage.shatter()
		if get_node("/root/DragonRoster").award_training() != OK:
			push_warning("No se pudo guardar la recompensa del tutorial.")
	arrow.hide()
	for actor in get_tree().get_nodes_in_group("combat_actors"):
		actor.combat_enabled = false
	_refresh()
	var back := Button.new()
	back.text = "Volver al atlas"
	overlay.add_child(back)
	back.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/world_menu.tscn"))
	back.grab_focus()

func _build_hud() -> void:
	add_child(overlay)
	for label in [top,objective,stats]:
		overlay.add_child(label)
		label.add_theme_constant_override("outline_size",6)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	objective.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	objective.offset_top = 32
	stats.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	stats.offset_top = -52
	for label in [top,objective,stats]:
		label.offset_left = -355
		label.offset_right = 355
	overlay.add_child(radar)
	radar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	radar.offset_left = -175
	radar.offset_right = -12
	radar.offset_top = -100
	radar.offset_bottom = -15
	radar.draw.connect(_draw_radar)
	for i in 2:
		var bar := ProgressBar.new()
		overlay.add_child(bar)
		bar.show_percentage = false
		bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
		bar.offset_left = -124 if i==0 else 4
		bar.offset_right = -4 if i==0 else 124
		bar.offset_top = -65
		bar.offset_bottom = -55
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color.SEA_GREEN if i==0 else Color.DEEP_SKY_BLUE
		bar.add_theme_stylebox_override("fill",fill)
		bars.append(bar)
	overlay.add_child(upgrade)
	upgrade.text = "+ Mejorar disparo"
	upgrade.position = Vector2(12,60)
	upgrade.pressed.connect(func():
		if points>0 and phase<Phase.WON:
			player.weapon.damage += 5
			points -= 1
			_refresh())
	_refresh()

func _refresh() -> void:
	bars[0].max_value = player.max_health
	bars[0].value = player.current_health
	bars[1].value = player.mana
	var target = cage if phase >= Phase.CAGE else shrine
	top.text = "OBELISCO  %d     ◆     %s  %d" % [obelisk.current_health,"JAULA" if target==cage else "ESCUDO",target.current_health]
	objective.text = INSTRUCTIONS[phase] if respawn<=0 or phase>=Phase.WON else "Reaparición en %d s" % ceili(respawn)
	stats.text = "Vida %d/%d    Energía %d    Oro %d/%d%s\nQ  %.1f s     E  %.1f s" % [player.current_health,player.max_health,int(player.mana),purse,LIMIT," · Bolsa llena" if purse==LIMIT else "",player.power_weapon.cooldown_remaining,player.pulse_ability.cooldown_remaining]
	upgrade.visible = points>0 and phase<Phase.WON
	radar.queue_redraw()

func _draw_radar() -> void:
	radar.draw_rect(Rect2(Vector2.ZERO,radar.size),Color("#151e26df"))
	radar.draw_rect(Rect2(Vector2.ZERO,radar.size),Color.TAN,false)
	for point in [BASE,OBELISK,shrine.position,cage.position,goal,player.position]:
		var uv := Vector2((point.x+48)/96,(point.z+22)/44)
		radar.draw_circle(uv*radar.size,3,Color.WHITE if point==player.position else (Color.GREEN_YELLOW if point==goal else Color.TAN))

func _resume_impact() -> void:
	if impact_pause > 0:
		impact_pause = 0
		get_tree().paused = false

func _exit_tree() -> void:
	_resume_impact()
