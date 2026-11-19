extends Area2D
const IMPACT := preload("res://scenes/combat/impact.tscn")
var target_mask := 2
const HEALTH := preload("res://scripts/combat/health_component.gd")
var direction := Vector2.RIGHT
var remaining := 0.0
var speed := 0.0
var radius := 0.0
var damage := 0

func _physics_process(delta: float) -> void:
	var step := minf(remaining,speed*delta)
	var end := global_position+direction*step
	remaining -= step
	if radius == 0:
		# El básico barre todo el tramo para no atravesar un blanco a alta velocidad.
		var ray := PhysicsRayQueryParameters2D.create(global_position,end,target_mask)
		ray.hit_from_inside = true
		var hit := get_world_2d().direct_space_state.intersect_ray(ray)
		if not hit.is_empty():
			global_position = hit.position
			resolve([hit.collider])
			return
	global_position = end
	if remaining <= 0:
		if radius > 0: explode()
		else: queue_free()

func explode() -> void:
	# La carga atraviesa el trayecto y consulta el círculo una sola vez en su destino.
	var circle := CircleShape2D.new()
	circle.radius = radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0,global_position)
	query.collision_mask = target_mask
	var targets := []
	for hit in get_world_2d().direct_space_state.intersect_shape(query,64):
		if not targets.has(hit.collider):
			targets.append(hit.collider)
	resolve(targets)

func resolve(targets: Array) -> void:
	set_physics_process(false)
	var applied := false
	for target in targets:
		var health := target.get_node_or_null("HealthComponent") as HEALTH
		if health and health.take_damage(damage):
			applied = true
	var effect = IMPACT.instantiate()
	get_parent().add_child(effect)
	effect.global_position = global_position
	effect.play(radius)
	if applied:
		get_tree().call_group("impact_feedback", "on_hit", radius > 0)
	queue_free()
