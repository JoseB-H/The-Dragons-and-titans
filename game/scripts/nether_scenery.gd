extends Node3D
## Acabado original inspirado en el video del usuario; sin colisiones nuevas.
var rng := RandomNumberGenerator.new()
var stone := StandardMaterial3D.new()
var foliage := StandardMaterial3D.new()
var paving := StandardMaterial3D.new()

func _ready() -> void:
	rng.seed = 20261127
	stone.albedo_color = Color("#414749")
	stone.roughness = .95
	foliage.albedo_color = Color("#577d29")
	foliage.roughness = 1.0
	paving.albedo_color = Color("#797864")
	paving.roughness = .95
	var noise := FastNoiseLite.new()
	noise.seed = 1127
	noise.frequency = .08
	var texture := NoiseTexture2D.new()
	texture.width = 256
	texture.height = 256
	texture.noise = noise
	var ramp := Gradient.new()
	ramp.set_color(0, Color("#20272a"))
	ramp.set_color(1, Color("#72756b"))
	texture.color_ramp = ramp
	stone.albedo_texture = texture
	for side in [-1, 1]:
		for i in 23:
			var x := -57.0 + i * 5.2
			var z: float = side * (30.0 + 2.5 * sin(i * .8))
			var h := rng.randf_range(5.5, 10.5)
			_cliff(Vector3(x, -3.0, z), Vector3(4.3, h, 4.8))
			_bush(Vector3(x, h * .7 - 3.0, z), rng.randf_range(2.2,3.5))
		for z in [-15.0, 0.0, 15.0]:
			_cliff(Vector3(side * 23.0, -4.0, z), Vector3(3.0,5.0,3.0))
			_bush(Vector3(side * 23.0, .45, z), 2.0)
		_base(side)

func _cliff(center: Vector3, dimensions: Vector3) -> void:
	var mesh := SphereMesh.new()
	mesh.radial_segments = 9
	mesh.rings = 5
	for j in 3:
		var offset := Vector3(rng.randf_range(-1.3,1.3), -j * 2.6, rng.randf_range(-1.3,1.3))
		_put(mesh, stone, center+offset, dimensions * (1.0-j*.08), rng.randf()*TAU)

func _bush(center: Vector3, radius: float) -> void:
	var mesh := SphereMesh.new()
	mesh.radial_segments = 9
	mesh.rings = 5
	for i in 7:
		var angle := i*TAU/7
		var material := foliage.duplicate() as StandardMaterial3D
		material.albedo_color = foliage.albedo_color.lightened(rng.randf_range(-.2,.18))
		_put(mesh, material, center+Vector3(cos(angle),.1,sin(angle))*radius*.42, Vector3(radius*.7,radius*.35,radius*.7), angle)

func _base(side: int) -> void:
	for x in 9:
		for z in 9:
			var p := Vector3(side*38.0+(x-4)*1.23, .21, (z-4)*1.23)
			if Vector2(x-4,z-4).length() > 4.4:
				continue
			_put(BoxMesh.new(),paving,p,Vector3(1.15,rng.randf_range(.13,.23),1.15),rng.randf_range(-.035,.035))
	var energy := StandardMaterial3D.new()
	energy.albedo_color = Color("#42dbcc") if side<0 else Color("#ec943c")
	energy.emission_enabled = true
	energy.emission = energy.albedo_color
	energy.emission_energy_multiplier = 1.6
	for z in [-4.8,4.8]:
		_put(BoxMesh.new(),stone,Vector3(side*38.0,2.0,z),Vector3(1.5,4.0,1.5),0)
		var crystal := PrismMesh.new()
		_put(crystal,energy,Vector3(side*38.0,4.45,z),Vector3(.7,1.8,.7),0)
	var arch := TorusMesh.new()
	arch.inner_radius = 2.6
	arch.outer_radius = 2.87
	arch.rings = 48
	arch.ring_segments = 8
	var portal := _put(arch,energy,Vector3(side*40.0,3.0,0),Vector3.ONE,0)
	portal.rotation.z = PI/2

func _put(mesh: Mesh, mat: Material, point: Vector3, dimensions: Vector3, angle: float) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = mat
	instance.position = point
	instance.scale = dimensions
	instance.rotation.y = angle
	add_child(instance)
	return instance
