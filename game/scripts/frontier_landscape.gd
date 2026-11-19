extends Node3D

const SURFACE := preload("res://assets/frontier_ground.gdshader")
const MIST := preload("res://assets/caldera_mist.gdshader")


func _ready() -> void:
	_plane(Vector2(101, 58), 0.0, SURFACE)
	_plane(Vector2(205, 135), -11.0, MIST)
	var random := RandomNumberGenerator.new()
	random.seed = 5504
	var rock := SphereMesh.new()
	rock.radial_segments = 8
	rock.rings = 5
	var ice := _material(Color(0.29, 0.38, 0.49))
	var snow := _material(Color(0.56, 0.68, 0.80))
	var ash := _material(Color(0.25, 0.14, 0.16))
	var ember := _material(Color(0.41, 0.19, 0.14))
	for edge in [-1.0, 1.0]:
		for index in range(23):
			var x := -50.0 + index * 4.55
			var z: float = edge * random.randf_range(26.5, 29.1)
			var height := random.randf_range(6.2, 11.0)
			var width := random.randf_range(3.5, 5.7)
			var cold := x < 0
			_boulder(rock, ice if cold else ash, Vector3(x, 0.0, z), Vector3(width, height, 5.3), random.randf() * TAU)
			_boulder(rock, snow if cold else ember, Vector3(x, height * 0.37, z), Vector3(width * .78, height * .30, 4.3), 0.0)
	var basin := TorusMesh.new()
	basin.inner_radius = 4.6
	basin.outer_radius = 4.8
	basin.rings = 40
	basin.ring_segments = 6
	for end in [-1.0, 1.0]:
		var energy := _material(Color(0.28, 0.66, 0.92) if end < 0 else Color(0.92, 0.25, 0.1))
		energy.emission_enabled = true
		energy.emission = energy.albedo_color
		_boulder(basin, energy, Vector3(end * 40.0, 0.09, 0), Vector3.ONE, 0)
	for row in [-7.5, 7.5]:
		for index in range(19):
			var x := -35.0 + index * 3.85 + random.randf_range(-.6, .6)
			var z: float = row + random.randf_range(-1.0, 1.0)
			var height := random.randf_range(1.1, 3.6)
			_boulder(rock, ice if x < 0 else ash, Vector3(x, 0.0, z), Vector3(2.1, height, 1.65), random.randf() * TAU)
			if x < 0:
				_boulder(rock, snow, Vector3(x, height * .37, z), Vector3(1.45, height * .34, 1.1), 0.0)


func _plane(size: Vector2, height: float, shader: Shader) -> void:
	var plane := PlaneMesh.new()
	plane.size = size
	var material := ShaderMaterial.new()
	material.shader = shader
	var instance := MeshInstance3D.new()
	instance.mesh = plane
	instance.material_override = material
	instance.position.y = height
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)


func _material(color: Color) -> StandardMaterial3D:
	var stone := StandardMaterial3D.new()
	stone.albedo_color = color
	stone.roughness = .92
	return stone


func _boulder(mesh: Mesh, material: Material, point: Vector3, dimensions: Vector3, angle: float) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = point
	instance.scale = dimensions
	instance.rotation.y = angle
	add_child(instance)
