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
	for level in 5:
		var shelf := CylinderMesh.new()
		shelf.radial_segments = 13
		shelf.top_radius = radius * (1 - .12 * level)
		shelf.bottom_radius = radius * (.86 - .14 * level)
		shelf.height = 4.0
		_boulder(shelf, shale if level == 0 else basalt, center + Vector3.DOWN * (2.0 + level * 3.8), Vector3.ONE, .16 * level)
	var turf := CylinderMesh.new()
	turf.radial_segments = 9
	turf.top_radius = radius * .92
	turf.bottom_radius = radius
	turf.height = .24
	_boulder(turf, moss, center, Vector3.ONE, 0)
	var rock := SphereMesh.new()
	rock.radial_segments = 6
	rock.rings = 3
	for i in 11:
		var angle := TAU * i / 11
		var offset := Vector3(cos(angle) * radius, -.9, sin(angle) * radius)
		_boulder(rock, basalt, center + offset, Vector3(1.6, rng.randf_range(2,4), 1.5), angle)


func show_rune(i: int, owner_id: int, progress: float) -> void:
	var hue: Color = [Color("#dfc478"), Color("#49cff1"), Color("#f56749")][owner_id]
	rings[i].albedo_color = hue
	rings[i].emission = hue
	signs[i].text = "%s � %s %d%%" % [String.chr(65 + i), ["Neutral", "Aliada", "Rival"][owner_id], roundi(absf(progress)*100)]


