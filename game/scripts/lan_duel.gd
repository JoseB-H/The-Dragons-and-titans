extends Node3D

const PORT := 27940
const ACTOR := preload("res://scripts/combat_actor.gd")
const MODELS := [preload("res://assets/dragons/cobre.glb"), preload("res://assets/dragons/jade.glb")]
const SPEED := 7.0
const SHOT_SPEED := 24.0
const RADIUS := 1.05
var players: Array[CharacterBody3D] = []
var moves := [Vector2.ZERO, Vector2.ZERO]
var aims := [Vector2.RIGHT, Vector2.LEFT]
var firing := [false,false]
var cooldown := [0.0,0.0]
var shots := {}
var shot_count := 0
var remote := 0
var running := false
var won_by := -1
var online := false
var clock := 0.0
var input_age := 0.0
var bullet_mesh := SphereMesh.new()
var shot_paints: Array[StandardMaterial3D] = []
var lobby := VBoxContainer.new()
var banner := Label.new()
var address := LineEdit.new()
var host_button := Button.new()
var join_button := Button.new()
var camera := Camera3D.new()


func _ready() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-58,-25,0)
	light.light_energy = 1.6
	add_child(light)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#263b45")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#c9d5df")
	env.ambient_light_energy = .7
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var floor_node := MeshInstance3D.new()
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(33,1,22)
	var floor_paint := StandardMaterial3D.new()
	floor_paint.albedo_color = Color("#384a50")
	floor_mesh.material = floor_paint
	floor_node.mesh = floor_mesh
	add_child(floor_node)
	add_child(preload("res://scripts/arena_presentation.gd").new())
	add_child(camera)
	camera.position = Vector3(0,27,15)
	camera.look_at(Vector3.ZERO)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 25
	camera.current = true
	bullet_mesh.radius = .18
	bullet_mesh.height = .36
	for side in 2:
		var actor := ACTOR.new()
		actor.faction = side + 1
		actor.max_health = 100
		actor.position = Vector3(-8 if side == 0 else 8,1.5,0)
		add_child(actor)
		players.append(actor)
		var model: Node3D = MODELS[side].instantiate()
		actor.add_child(model)
		actor.look_at(Vector3(0,1.5,0))
		var anim := model.find_children("*","AnimationPlayer",true,false)
		if not anim.is_empty():
			var animator: AnimationPlayer = anim[0]
			animator.play("Flight")
			animator.animation_finished.connect(func(_clip): animator.play("Flight"))
		var tint := StandardMaterial3D.new()
		tint.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tint.albedo_color = Color("#ffb460") if side == 0 else Color("#5ef5bc")
		shot_paints.append(tint)
	var ui := CanvasLayer.new()
	add_child(ui)
	ui.add_child(lobby)
	lobby.position = Vector2(22,18)
	lobby.add_theme_constant_override("separation",8)
	lobby.add_child(banner)
	banner.text = "LAS AGUJAS   /   Duelo LAN · 2 jugadores"
	var hint := Label.new()
	hint.text = "WASD para volar · Apunta con el ratón · Clic para disparar"
	lobby.add_child(hint)
	address.placeholder_text = "IP del anfitrión"
	lobby.add_child(address)
	host_button.text = "Crear sala · Cobre"
	join_button.text = "Unirme · Jade"
	lobby.add_child(host_button)
	lobby.add_child(join_button)
	host_button.pressed.connect(host)
	join_button.pressed.connect(func(): join_room(address.text.strip_edges()))
	var back := Button.new()
	back.text = "Salir al atlas"
	lobby.add_child(back)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/world_menu.tscn"))
	multiplayer.connected_to_server.connect(_joined)
	multiplayer.connection_failed.connect(_lost.bind("No se pudo conectar. Revisa la IP y la red."))
	multiplayer.server_disconnected.connect(_lost.bind("El anfitrión salió."))
	multiplayer.peer_disconnected.connect(_disconnected)


func host() -> void:
	if online:
		return
	var net := ENetMultiplayerPeer.new()
	if net.create_server(PORT,1) != OK:
		banner.text = "No se pudo abrir la sala en UDP %d." % PORT
		return
	multiplayer.multiplayer_peer = net
	online = true
	_controls(false)
	var ips := PackedStringArray()
	for ip in IP.get_local_addresses():
		if "." in ip and not ":" in ip and not ip.begins_with("127."):
			ips.append(ip)
	banner.text = "Esperando rival · Dirección del anfitrión: " + ", ".join(ips)


func join_room(ip: String) -> void:
	if online:
		return
	if not ip.is_valid_ip_address():
		banner.text = "Escribe una IP válida."
		return
	var net := ENetMultiplayerPeer.new()
	if net.create_client(ip, PORT) != OK:
		banner.text = "No se pudo iniciar la conexión."
		return
	multiplayer.multiplayer_peer = net
	online = true
	_controls(false)
	banner.text = "Conectando con " + ip


func _controls(enabled: bool) -> void:
	host_button.visible = enabled
	join_button.visible = enabled
	address.visible = enabled


func _joined() -> void:
	ready_to_duel.rpc_id(1)


@rpc("any_peer", "call_remote", "reliable")
func ready_to_duel() -> void:
	if not multiplayer.is_server() or running or remote != 0:
		return
	remote = multiplayer.get_remote_sender_id()
	begin.rpc_id(remote)
	begin()


@rpc("authority", "call_remote", "reliable")
func begin() -> void:
	running = true
	_update_banner()


func _physics_process(delta: float) -> void:
	if not running:
		return
	var side := 0 if multiplayer.is_server() else 1
	var move := Input.get_vector("move_left","move_right","move_forward","move_back")
	var cursor := get_viewport().get_mouse_position()
	var hit: Variant = Plane(Vector3.UP,1.5).intersects_ray(camera.project_ray_origin(cursor),camera.project_ray_normal(cursor))
	var aim: Vector2 = aims[side]
	if hit is Vector3:
		var offset: Vector3 = hit - players[side].position
		if offset.length_squared() > .001:
			aim = Vector2(offset.x,offset.z).normalized()
	var fire := Input.is_action_pressed("attack") and get_viewport().gui_get_hovered_control() == null
	clock += delta
	var send_now := clock >= .033
	if send_now:
		clock = 0
	if side == 1:
		if send_now:
			commands.rpc_id(1,move,aim,fire)
		return
	moves[0] = move
	aims[0] = aim
	firing[0] = fire
	input_age += delta
	if input_age > .4:
		moves[1] = Vector2.ZERO
		firing[1] = false
	_simulate(delta)
	if running and send_now:
		var positions := {}
		for key in shots:
			positions[key] = shots[key].node.position
		snapshot.rpc_id(remote,players[0].position,players[1].position,players[0].rotation.y,players[1].rotation.y,players[0].current_health,players[1].current_health,positions)


@rpc("any_peer","call_remote","unreliable_ordered",1)
func commands(move: Vector2, aim: Vector2, fire: bool) -> void:
	if not multiplayer.is_server() or not running or multiplayer.get_remote_sender_id() != remote:
		return
	if not move.is_finite() or not aim.is_finite():
		return
	moves[1] = move.limit_length()
	if not aim.is_zero_approx():
		aims[1] = aim.normalized()
	firing[1] = fire
	input_age = 0


func _simulate(delta: float) -> void:
	for side in 2:
		var actor := players[side]
		var move: Vector2 = moves[side]
		var dir := Vector3(aims[side].x,0,aims[side].y)
		actor.position = (actor.position + Vector3(move.x,0,move.y)*SPEED*delta).clamp(Vector3(-15,1.5,-10),Vector3(15,1.5,10))
		actor.look_at(actor.position + dir)
		cooldown[side] -= delta
		if firing[side] and cooldown[side] <= 0:
			cooldown[side] = .35
			shot_count += 1
			var key := shot_count * 2 + side
			_spawn_shot(key, actor.position + dir * .8, dir)
	for key in shots.keys():
		var shot: Dictionary = shots[key]
		var node: MeshInstance3D = shot.node
		var start := node.position
		node.position += Vector3(shot.dir)*SHOT_SPEED*delta
		shot.age += delta
		var victim := players[1 - int(key)%2]
		var nearest := Geometry3D.get_closest_point_to_segment(victim.position,start,node.position)
		if nearest.distance_to(victim.position) <= RADIUS:
			victim.take_damage(20, int(key)%2 + 1)
			_remove_shot(key)
			_update_banner()
			if not victim.is_alive():
				var winner := int(key)%2
				finish.rpc_id(remote,winner)
				finish(winner)
				return
		elif shot.age > 1.5:
			_remove_shot(key)


func _spawn_shot(key: int, pos: Vector3, dir: Vector3) -> void:
	var node := MeshInstance3D.new()
	node.mesh = bullet_mesh
	node.material_override = shot_paints[key%2]
	add_child(node)
	node.position = pos
	shots[key] = {"node":node,"dir":dir,"age":0.0}


func _remove_shot(key: int) -> void:
	shots[key].node.queue_free()
	shots.erase(key)


@rpc("authority","call_remote","unreliable_ordered",2)
func snapshot(a: Vector3,b: Vector3,ay: float,by: float,hp_a: int,hp_b: int,positions: Dictionary) -> void:
	if not running:
		return
	players[0].position = a
	players[1].position = b
	players[0].rotation.y = ay
	players[1].rotation.y = by
	players[0].current_health = hp_a
	players[1].current_health = hp_b
	for key in shots.keys():
		if not positions.has(key):
			_remove_shot(key)
	for key in positions:
		if shots.has(key):
			shots[key].node.position = positions[key]
		else:
			_spawn_shot(key,positions[key],Vector3.ZERO)
	_update_banner()


func _update_banner() -> void:
	var side := "Cobre" if multiplayer.is_server() else "Jade"
	banner.text = "Tú: %s    ·    Cobre  %d PV     /     Jade  %d PV" % [side,players[0].current_health,players[1].current_health]


@rpc("authority","call_remote","reliable")
func finish(winner: int) -> void:
	if not running or won_by >= 0:
		return
	get_node("/root/DragonRoster").record_duel()
	won_by = winner
	running = false
	players[1-winner].current_health = 0
	banner.text = "VICTORIA" if (winner == 0) == multiplayer.is_server() else "DERROTA"
	for key in shots.keys():
		_remove_shot(key)


func _disconnected(id: int) -> void:
	if id == remote:
		_lost("El rival salió de la sala.")


func _lost(message: String) -> void:
	var result := banner.text if won_by >= 0 else ""
	_close()
	banner.text = message if result.is_empty() else result + " · " + message
	_controls(false)
	banner.text += " Vuelve al atlas para abrir otra sala."


func _close() -> void:
	running = false
	if online and multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	online = false
	remote = 0


func _exit_tree() -> void:
	_close()
