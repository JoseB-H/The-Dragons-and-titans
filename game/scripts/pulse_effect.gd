extends Node3D
## Anillo propio sin lógica de daño. El pulso ya se resolvió al activarse.

@export_range(0.01, 30.0, 0.01, "or_greater") var radius: float = 4.0
@export_range(0.01, 10.0, 0.01, "or_greater") var lifetime: float = 0.5

var _remaining_lifetime: float = 0.0


func _ready() -> void:
	if not is_finite(radius) or radius <= 0.0 or not is_finite(lifetime) or lifetime <= 0.0:
		queue_free()
		return
	var torus := $Visual.mesh.duplicate() as TorusMesh
	torus.inner_radius = maxf(radius - 0.10, radius * 0.9)
	torus.outer_radius = radius
	$Visual.mesh = torus
	_remaining_lifetime = lifetime


func _physics_process(delta: float) -> void:
	_remaining_lifetime = maxf(_remaining_lifetime - delta, 0.0)
	if _remaining_lifetime <= 0.0:
		queue_free()
