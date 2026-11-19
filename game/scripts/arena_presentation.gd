extends Node3D
## Ruinas originales puramente visuales; no crean cuerpos ni áreas de colisión.
func _ready() -> void:
	var stone := _material(Color(0.24, 0.29, 0.31))
	var edge := _material(Color(0.37, 0.42, 0.43))
	var inset := _material(Color(0.19, 0.23, 0.25))
	var amber := _material(Color(0.58, 0.34, 0.12))
	# Juntas discretas bajo el suelo de vuelo. Centro despejado para proyectiles.
	for index in range(-5, 6):
		_box(Vector3(index * 2.0, 0.006, 0), Vector3(0.025, 0.008, 24), inset)
		_box(Vector3(0, 0.006, index * 2.0), Vector3(24, 0.008, 0.025), inset)
	# Borde interior visible: coincide con el límite de centros jugable (+/-10).
	for side in [-1.0, 1.0]:
		_box(Vector3(side * 10.0, 0.015, 0), Vector3(0.09, 0.02, 20), amber)
		_box(Vector3(0, 0.015, side * 10.0), Vector3(20, 0.02, 0.09), amber)
	# Roseta central: 24 segmentos a ras del suelo, sin luz ni transparencia.
	for index in range(24):
		var angle := TAU * index / 24.0
		var mark := _box(Vector3(sin(angle) * 3.4, 0.018, cos(angle) * 3.4), Vector3(0.09, 0.02, 0.65), edge)
		mark.rotation.y = angle
	# Torres rotas en las esquinas: fuera de centros y envergadura del jugador.
	for x in [-12.8, 12.8]:
		for z in [-12.8, 12.8]:
			_box(Vector3(x, 0.15, z), Vector3(1.9, 0.3, 1.9), edge)
			for level in range(4):
				var block := _box(Vector3(x, 0.55 + level * 0.65, z), Vector3(1.2, 0.6, 1.2), stone)
				block.rotation.y = level * 0.11
			_box(Vector3(x, 3.0, z), Vector3(1.6, 0.35, 1.6), edge)
	# Roca facetada reutilizada: posiciones deterministas, siempre al exterior.
	var rock := SphereMesh.new()
	rock.radial_segments = 6
	rock.rings = 3
	for index in range(28):
		var angle := TAU * index / 28.0
		var radius := 15.0 + sin(index * 2.3) * 0.7
		var item := MeshInstance3D.new()
		item.mesh = rock
		item.material_override = stone
		item.position = Vector3(sin(angle) * radius, 0.25, cos(angle) * radius)
		item.scale = Vector3(1.3 + sin(index) * 0.4, 0.7 + absf(cos(index)) * 0.6, 1.2)
		item.rotation.y = angle
		add_child(item)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	return material

func _box(at: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = at
	add_child(instance)
	return instance
