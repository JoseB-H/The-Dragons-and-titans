extends Node3D
## Barrido continuo en cada tick: un proyectil rápido no atraviesa a los actores.

@export_range(1, 10000, 1, "or_greater") var damage: int = 20
@export_range(0.0, 1000.0, 0.1, "or_greater") var speed: float = 28.0
@export_range(0.0, 30.0, 0.01, "or_greater") var lifetime: float = 2.0

var direction: Vector3 = Vector3.FORWARD
var source_faction: int = 1
var source_rid: RID = RID()
# Vector3 global opcional: el primer barrido incluye actor → origen visual.
var launch_origin: Variant = null

var visual_tint: Color = Color.WHITE
var visual_scale: float = 1.0

var _remaining_lifetime: float = 0.0
var _spent := false


func _ready() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.scale *= visual_scale
			if visual_tint != Color.WHITE:
				var material := StandardMaterial3D.new()
				material.albedo_color = visual_tint
				child.material_override = material
	direction = Vector3(direction.x, 0.0, direction.z).normalized()
	_remaining_lifetime = maxf(lifetime, 0.0)


func _physics_process(delta: float) -> void:
	if _spent:
		return
	if _remaining_lifetime <= 0.0:
		_retire()
		return
	var travel_time := minf(delta, _remaining_lifetime)
	var sweep_origin := global_position
	if launch_origin is Vector3:
		sweep_origin = launch_origin
		launch_origin = null
	var destination := global_position + direction * maxf(speed, 0.0) * travel_time
	if not destination.is_equal_approx(sweep_origin):
		var query := PhysicsRayQueryParameters3D.create(sweep_origin, destination, 1)
		query.collide_with_areas = false
		query.hit_from_inside = true
		var exclusions: Array[RID] = []
		if source_rid.is_valid():
			exclusions.append(source_rid)
		var space := get_world_3d().direct_space_state
		while true:
			query.exclude = exclusions
			var hit := space.intersect_ray(query)
			if hit.is_empty():
				break
			var actor := hit["collider"] as Node
			if actor != null and actor.has_method("is_alive") and actor.has_method("take_damage"):
				if actor.is_alive() and actor.faction != source_faction:
					_show_impact(hit["position"], actor)
					actor.take_damage(damage, source_faction)
					_retire()
					return
			# Repetir el mismo tramo excluyendo aliados/muertos permite alcanzar
			# al primer hostil que esté detrás, incluso dentro del mismo tick.
			exclusions.append(hit["rid"])
	global_position = destination
	_remaining_lifetime = maxf(_remaining_lifetime - delta, 0.0)
	if _remaining_lifetime <= 0.0:
		_retire()


func _retire() -> void:
	_spent = true
	queue_free()

func _show_impact(point: Vector3, actor: Node) -> void:
	if visual_tint == Color.WHITE:
		return
	var flash := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.22
	sphere.height = 0.44
	flash.mesh = sphere
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = visual_tint if visual_tint != Color.WHITE else Color(1, 0.8, 0.35)
	flash.material_override = material
	actor.add_child(flash)
	flash.add_to_group("equipment_impacts")
	flash.global_position = point
	var tween := flash.create_tween()
	tween.tween_property(flash, "scale", Vector3.ONE * 0.05, 0.12)
	tween.tween_callback(flash.queue_free)
