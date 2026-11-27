extends "res://scripts/frontier_landscape.gd"

var points: Array
var lintels: Array[Node3D] = []
var rings: Array[StandardMaterial3D] = []
var signs: Array[Label3D] = []
var rng := RandomNumberGenerator.new()
var basalt := _material(Color("#43454c"))
var shale := _material(Color("#666456"))
var moss := _material(Color("#3a5128"))


func _ready() -> void:
	rng.seed = 81472
	for mat in [basalt, shale, moss]:
		var noise := FastNoiseLite.new()
		noise.seed = 81472
		noise.frequency = .07
		var texture := NoiseTexture2D.new()
		texture.width = 256
		texture.height = 256
		texture.noise = noise
		var gradient := Gradient.new()
		gradient.set_color(0, mat.albedo_color.darkened(.5))
		gradient.set_color(1, mat.albedo_color.lightened(.16))
		texture.color_ramp = gradient
		mat.albedo_color = Color.WHITE
		mat.albedo_texture = texture
		mat.uv1_triplanar = true
		mat.uv1_scale = Vector3.ONE*.35
	_plane(Vector2(240, 170), -9, preload("res://assets/nether_water.gdshader"))
	for edge in [-1, 1]:
		for i in 14:
			var x := -56 + i * 8.5
			_island(Vector3(x, rng.randf_range(0.0, 4.0), edge * rng.randf_range(30, 35)), rng.randf_range(5, 8))
		_island(Vector3(edge * 38, 0, 0), 9)
		for z in [-15, 0, 15]:
			_island(Vector3(edge * 23, -.15, z), 3.4)
		for z in [-2.2, 2.2]:
			var tower := CylinderMesh.new()
			tower.radial_segments = 8
			_boulder(tower, shale, Vector3(edge * 40, 1.6, z), Vector3(1.8, 2.1, 1.8), 0)
		var lintel := BoxMesh.new()
		_boulder(lintel, basalt, Vector3(edge * 40, 3.8, 0), Vector3(1.6, .75, 5.8), 0)
		lintels.append(get_child(-1))
	for i in points.size():
		var center: Vector3 = points[i]
		center.y = 0
		_island(center, 5)
		var mat := _material(Color.WHITE)
		mat.emission_enabled = true
		rings.append(mat)
		var ring := TorusMesh.new()
		ring.inner_radius = 3.5
		ring.outer_radius = 3.8
		ring.rings = 48
		ring.ring_segments = 6
		_boulder(ring, mat, center + Vector3.UP * .26, Vector3.ONE, 0)
		for j in 8:
			var angle := TAU * j / 8
			_boulder(BoxMesh.new(), mat, center + Vector3(2.6*cos(angle), .29, 2.6*sin(angle)), Vector3(.52,.11,.52), angle + PI/4)
		var sign_node := Label3D.new()
		sign_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sign_node.position = center + Vector3.UP * 2.7
		sign_node.pixel_size = .011
		add_child(sign_node)
		signs.append(sign_node)
		show_rune(i, 0, 0)
	add_child(preload("res://scripts/nether_scenery.gd").new())


func _island(center: Vector3, radius: float) -> void:
	var noise := FastNoiseLite.new()
	noise.seed = int(center.x*43.0+center.z*97.0)+81472
	noise.frequency = .23
	var contours: Array[PackedVector3Array] = []
	const SEGMENTS := 48
	for layer in 8:
		var contour := PackedVector3Array()
		for i in SEGMENTS:
			var angle := TAU*i/SEGMENTS
			var scallop := .12*sin(angle*5.0+center.x)+.07*sin(angle*9.0+center.z)
			var r := radius*(1.0+scallop-layer*.025)
			r += noise.get_noise_3d(cos(angle)*radius,layer*2.1,sin(angle)*radius)*radius*.17
			var height := -layer*1.9
			if layer == 0:
				height = .05+noise.get_noise_2d(cos(angle)*radius,sin(angle)*radius)*.4
			contour.append(Vector3(cos(angle)*r,height,sin(angle)*r))
		contours.append(contour)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for layer in 7:
		for i in SEGMENTS:
			var j := (i+1)%SEGMENTS
			for p in [contours[layer][i],contours[layer+1][i],contours[layer][j],contours[layer][j],contours[layer+1][i],contours[layer+1][j]]:
				surface.add_vertex(p)
	surface.generate_normals()
	var rock_material := ShaderMaterial.new()
	rock_material.shader = preload("res://assets/nether_cliff.gdshader")
	_boulder(surface.commit(),rock_material,center,Vector3.ONE,0)
	var top := SurfaceTool.new()
	top.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in SEGMENTS:
		for p in [Vector3(0,.04,0),contours[0][(i+1)%SEGMENTS],contours[0][i]]:
			top.add_vertex(p)
	top.generate_normals()
	var top_material := ShaderMaterial.new()
	top_material.shader = rock_material.shader
	top_material.set_shader_parameter("turf",true)
	_boulder(top.commit(),top_material,center,Vector3.ONE,0)


func show_rune(i: int, owner_id: int, progress: float) -> void:
	var hue: Color = [Color("#dfc478"), Color("#49cff1"), Color("#f56749")][owner_id]
	rings[i].albedo_color = hue
	rings[i].emission = hue
	signs[i].text = "%s · %s %d%%" % [String.chr(65 + i), ["Neutral", "Aliada", "Rival"][owner_id], roundi(absf(progress)*100)]

