extends "res://scripts/combat_actor.gd"

var gate: Node3D
var step := 0.0
var cooldown := 0.0
var body := preload("res://scripts/nether_effigy.gd").new()


func _ready() -> void:
	super._ready()
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.35
	shape.shape = sphere
	add_child(shape)
	add_child(body)
	body.sculpt(faction)
	look_at(gate.global_position)
	died.connect(queue_free)


func _physics_process(delta: float) -> void:
	if not can_act() or not gate.can_act():
		return
	step += delta * 4
	body.position.y = absf(sin(step)) * .11
	body.arms[0].rotation.x = sin(step) * .31
	body.arms[1].rotation.x = -body.arms[0].rotation.x
	if position.distance_to(gate.position) > 2.5:
		position = position.move_toward(gate.position, delta * 3.6)
		return
	cooldown -= delta
	if cooldown <= 0:
		if gate.shielded:
			gate.drop_shield()
		gate.take_damage(120, faction)
		cooldown = 2.2
