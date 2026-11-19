extends Node3D

const MIST_SHADER := preload("res://assets/caldera_mist.gdshader")

@export var ground_shader: Shader


func _ready() -> void:
	var surface := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(29, 31)
	surface.mesh = plane
	surface.position.y = 0.026
	var ground := ShaderMaterial.new()
	ground.shader = ground_shader
	surface.material_override = ground
	add_child(surface)
	get_parent().get_node("ArenaPresentation").hide()
	_add_atmosphere()

	var random := RandomNumberGenerator.new()
	random.seed = 480211
	var slate := StandardMaterial3D.new()
	slate.albedo_color = Color(0.36, 0.29, 0.23)
	slate.roughness = 0.94
	var tile := BoxMesh.new()
	tile.size = Vector3(0.72, 0.08, 0.63)
	for row in range(-11, 12):
		var center := sin(row * 0.42) * 1.5
		for lane in range(-2, 3):
			if row % 3 != 0 and random.randf() < 0.18:
				continue
			var point := Vector3(center + lane * 0.78, 0.06, row * 0.87)
			var paving := _piece(tile, slate, point)
			paving.rotation.y = random.randf_range(-0.17, 0.17)
			paving.scale = Vector3.ONE * random.randf_range(0.81, 1.06)

	var rock := SphereMesh.new()
	rock.radial_segments = 7
	rock.rings = 4
	var obsidian := StandardMaterial3D.new()
	obsidian.albedo_color = Color(0.19, 0.14, 0.16)
	obsidian.roughness = 0.9
	var rock_noise := FastNoiseLite.new()
	rock_noise.seed = 6631
	rock_noise.frequency = 0.085
	rock_noise.fractal_octaves = 3
	var rock_texture := NoiseTexture2D.new()
	rock_texture.width = 192
	rock_texture.height = 192
	rock_texture.seamless = true
	rock_texture.noise = rock_noise
	var tones := Gradient.new()
	tones.colors = PackedColorArray([Color(0.34, 0.30, 0.33), Color(0.92, 0.86, 0.84)])
	rock_texture.color_ramp = tones
	obsidian.albedo_texture = rock_texture
	var rock_normal := NoiseTexture2D.new()
	rock_normal.width = 256
	rock_normal.height = 256
	rock_normal.seamless = true
	rock_normal.as_normal_map = true
	rock_normal.bump_strength = 5.0
	rock_normal.noise = rock_noise
	obsidian.normal_enabled = true
	obsidian.normal_texture = rock_normal
	obsidian.normal_scale = 0.64
	_build_escarpment(obsidian, random)
	for side in [-1.0, 1.0]:
		for index in range(31):
			var z := random.randf_range(-15, 15)
			var x: float = side * random.randf_range(8.2, 13.8)
			var height := random.randf_range(0.4, 2.5) if absf(x) > 11.0 else 0.4
			var boulder := _piece(rock, obsidian, Vector3(x, 0.1, z))
			boulder.scale = Vector3(random.randf_range(0.5, 2.3), height, random.randf_range(0.8, 2.1))
			boulder.rotation.y = random.randf_range(0.0, TAU)


func _add_atmosphere() -> void:
	var environment: Environment = get_parent().get_node("WorldEnvironment").environment.duplicate()
	environment.background_color = Color(0.24, 0.29, 0.40)
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.42, 0.48, 0.59)
	environment.fog_density = 0.0035
	environment.fog_height = -5.0
	environment.fog_height_density = 0.08
	get_parent().get_node("WorldEnvironment").environment = environment

	var haze := ShaderMaterial.new()
	haze.shader = MIST_SHADER
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(190, 190)
	var mist := _piece(floor_mesh, haze, Vector3.DOWN * 13.0)
	mist.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var bounce := DirectionalLight3D.new()
	bounce.rotation_degrees = Vector3(-18, 155, 0)
	bounce.light_color = Color(0.52, 0.69, 1.0)
	bounce.light_energy = 0.24
	add_child(bounce)


func _build_escarpment(stone: Material, random: RandomNumberGenerator) -> void:
	var columns: Array[ArrayMesh] = []
	for variant in range(4):
		columns.append(_cliff_mesh(random))

	for side in [-1.0, 1.0]:
		for index in range(11):
			var x := float(side) * random.randf_range(12.7, 14.9)
			var height := random.randf_range(5.0, 9.2)
			var offset := Vector3(x, -height * 0.49 + 0.08, -14.5 + index * 2.9)
			var cliff := _piece(columns[index % columns.size()], stone, offset)
			cliff.scale = Vector3(random.randf_range(1.3, 2.3), height, random.randf_range(1.28, 2.3))
			cliff.rotation.y = random.randf_range(0.0, TAU)
		for index in range(7):
			var x := float(side) * random.randf_range(20.0, 32.0)
			var y := random.randf_range(-4.0, 3.5)
			var offset := Vector3(x, y - 4.5, -28.0 + index * 8.4)
			var island := _piece(columns[index % columns.size()], stone, offset)
			island.scale = Vector3(random.randf_range(2.0, 4.1), random.randf_range(7.0, 11.5), random.randf_range(2.2, 4.5))
			island.rotation = Vector3(random.randf_range(-.12, .12), random.randf_range(0.0, TAU), random.randf_range(-.15, .15))


func _cliff_mesh(random: RandomNumberGenerator) -> ArrayMesh:
	const SIDES := 9
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	var rings: Array[PackedVector3Array] = []
	var heights := [-0.5, -0.32, 0.17, 0.49]
	var radii := [0.37, 0.67, 0.94, 1.0]
	for layer in range(heights.size()):
		var ring := PackedVector3Array()
		for index in range(SIDES):
			var angle := TAU * float(index) / SIDES
			var radius: float = radii[layer] * random.randf_range(0.81, 1.14)
			var height: float = heights[layer] + random.randf_range(-0.065, 0.065)
			ring.append(Vector3(cos(angle) * radius, height, sin(angle) * radius))
		rings.append(ring)
	for layer in range(rings.size() - 1):
		for index in range(SIDES):
			var adjacent := (index + 1) % SIDES
			var u := float(index) / SIDES
			var next_u := float(index + 1) / SIDES
			var v := float(layer) / (rings.size() - 1)
			var next_v := float(layer + 1) / (rings.size() - 1)
			_emit_triangle(surface, [rings[layer][index], rings[layer][adjacent], rings[layer + 1][adjacent]],
				[Vector2(u, v), Vector2(next_u, v), Vector2(next_u, next_v)])
			_emit_triangle(surface, [rings[layer][index], rings[layer + 1][adjacent], rings[layer + 1][index]],
				[Vector2(u, v), Vector2(next_u, next_v), Vector2(u, next_v)])
	var cap := rings[rings.size() - 1]
	for index in range(SIDES):
		var a := cap[index]
		var b := cap[(index + 1) % SIDES]
		_emit_triangle(surface, [Vector3.UP * 0.52, a, b],
			[Vector2(0.5, 0.5), Vector2(a.x, a.z) * 0.5 + Vector2(0.5, 0.5),
			Vector2(b.x, b.z) * 0.5 + Vector2(0.5, 0.5)])
	surface.generate_normals()
	surface.generate_tangents()
	return surface.commit()


func _emit_triangle(surface: SurfaceTool, points: Array[Vector3], uvs: Array[Vector2]) -> void:
	for index in range(3):
		surface.set_uv(uvs[index])
		surface.add_vertex(points[index])


func _piece(mesh: Mesh, material: Material, point: Vector3) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.mesh = mesh
	item.material_override = material
	item.position = point
	add_child(item)
	return item
