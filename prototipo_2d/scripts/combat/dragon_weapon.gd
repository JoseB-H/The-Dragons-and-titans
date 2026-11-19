extends Node
const BOLT := preload("res://scenes/combat/bolt.tscn")
@export var basic_damage := 12
@export_range(0.05,3) var basic_interval := 0.28
@export var burst_damage := 30
@export_range(1,250) var burst_radius := 81.6
@export_range(0.1,10) var burst_interval := 2.5
@export_range(1,3000) var speed := 672.0
@export_range(1,2000) var reach := 840.0
var basic_left := 0.0
var burst_left := 0.0
@onready var pilot = get_parent()

func _physics_process(delta: float) -> void:
	basic_left = maxf(0,basic_left-delta)
	burst_left = maxf(0,burst_left-delta)
	if Input.is_action_pressed("basic_fire") and basic_left == 0 and launch(false):
		basic_left = basic_interval
	if Input.is_action_just_pressed("burst_fire") and burst_left == 0 and launch(true):
		burst_left = burst_interval

func launch(burst: bool) -> bool:
	# Congelar la dirección y el destino evita que el proyectil persiga al cursor.
	var span: Vector2 = pilot.aim_point-pilot.global_position
	if span.length() < 2.4: return false
	var bolt = BOLT.instantiate()
	bolt.direction = span.normalized()
	bolt.remaining = minf(span.length(),reach) if burst else reach
	bolt.radius = burst_radius if burst else 0.0
	bolt.damage = burst_damage if burst else basic_damage
	bolt.speed = speed
	pilot.get_parent().add_child(bolt)
	bolt.global_position = pilot.global_position
	bolt.rotation = span.angle()
	return true
