extends "res://scripts/combat/practice_target.gd"
const BOLT := preload("res://scenes/combat/bolt.tscn")
@export var player: CharacterBody2D
@export_range(1, 100) var shot_damage := 25
@export_range(0.1, 8) var shot_interval := 1.0
@export_range(10, 900) var attack_range := 220.0
@export_range(30, 1200) var shot_speed := 260.0
var remaining := 1.0

func _physics_process(delta: float) -> void:
	if not visible or not player.visible: return
	remaining = maxf(0, remaining-delta)
	var offset := player.global_position-global_position
	if offset.length() > attack_range or offset.is_zero_approx(): return
	$Barrel.rotation = offset.angle()
	if remaining > 0: return
	remaining = shot_interval
	var bolt = BOLT.instantiate()
	bolt.target_mask = 1  # Solo la capa del piloto.
	bolt.damage = shot_damage
	bolt.speed = shot_speed
	bolt.remaining = attack_range
	bolt.direction = offset.normalized()
	get_parent().add_child(bolt)
	bolt.global_position = global_position
	bolt.rotation = offset.angle()
	bolt.modulate = Color.ORANGE_RED
