extends CharacterBody2D
enum State { MOVER, ATACAR, MORIR }
const IMPACT := preload("res://scenes/combat/impact.tscn")
@export var speed := 68.0
@export var aggro_range := 115.0
@export var melee_range := 32.0
@export var damage := 6
@export_range(0.1, 10) var attack_interval := 1.1
var state := State.MOVER
var player: CharacterBody2D
var obelisk: Node2D
var target: Node2D
var cooldown := 0.0
var repath := 0.0

func _ready() -> void:
	$HealthComponent.died.connect(_die)

func _physics_process(delta: float) -> void:
	if state == State.MORIR: return
	cooldown = maxf(0, cooldown-delta)
	var next_target := obelisk
	if player.visible and global_position.distance_to(player.global_position) <= aggro_range:
		next_target = player
	repath -= delta
	if target != next_target or repath <= 0:
		target = next_target
		$Agent.target_position = target.global_position
		repath = 0.2
	if global_position.distance_to(target.global_position) <= melee_range:
		state = State.ATACAR
		velocity = Vector2.ZERO
		if cooldown <= 0:
			target.get_node("HealthComponent").take_damage(damage)
			cooldown = attack_interval
	else:
		state = State.MOVER
		# El mapa requiere un paso de física para sincronizar sus polígonos.
		if NavigationServer2D.map_get_iteration_id(get_world_2d().navigation_map) == 0: return
		var waypoint: Vector2 = $Agent.get_next_path_position()
		velocity = global_position.direction_to(waypoint)*speed
		move_and_slide()
	if not velocity.is_zero_approx(): $Body.rotation = velocity.angle()

func _die() -> void:
	state = State.MORIR
	set_physics_process(false)
	remove_from_group("minions")
	var fx = IMPACT.instantiate()
	get_parent().add_child(fx)
	fx.global_position = global_position
	fx.play(25)
	hide()
	queue_free()
