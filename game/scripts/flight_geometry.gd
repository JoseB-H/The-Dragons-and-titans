extends RefCounted
## Convierte entrada de pantalla en direcciones horizontales para el piloto y la práctica.

static func movement(camera: Camera3D, input: Vector2) -> Vector3:
	var right := camera.global_basis.x
	var back := camera.global_basis.z
	right.y = 0
	back.y = 0
	return (right.normalized()*input.x + back.normalized()*input.y).limit_length(1.0)

static func aim(camera: Camera3D, origin: Vector3, cursor: Vector2) -> Vector3:
	if not camera.get_viewport().get_visible_rect().has_point(cursor):
		return Vector3.ZERO
	var plane := Plane(Vector3.UP, origin.y)
	var hit: Variant = plane.intersects_ray(camera.project_ray_origin(cursor), camera.project_ray_normal(cursor))
	if hit == null or origin.distance_squared_to(hit) < 0.0001:
		return Vector3.ZERO
	return origin.direction_to(hit)
