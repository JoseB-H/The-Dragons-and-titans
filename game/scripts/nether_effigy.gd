extends Node3D

var arms: Array[MeshInstance3D] = []


func sculpt(side: int) -> void:
	var rock := StandardMaterial3D.new()
	rock.albedo_color = Color("#514857")
	rock.metallic = 0.45
	var rune := StandardMaterial3D.new()
	rune.albedo_color = Color("#45edec") if side == 1 else Color("#ff6748")
	rune.emission_enabled = true
	rune.emission = rune.albedo_color
	_block(Vector3.ZERO, Vector3(1.05, 1.1, .76), rock)
	_block(Vector3(0, 1.26, -.16), Vector3(.54, .61, .54), rock)
	_block(Vector3(0, .12, -.68), Vector3(.38, .52, .16), rune)
	_block(Vector3(0, 1.34, -.62), Vector3(.41, .09, .10), rune)
	for s in [-1, 1]:
		_block(Vector3(s * 1.12, .60, 0), Vector3(.74, .69, .73), rock)
		arms.append(_block(Vector3(s * 1.43, -.15, -.14), Vector3(.55, .90, .56), rock))
		_block(Vector3(s * .55, -.95, .07), Vector3(.47, .64, .54), rock)
		_block(Vector3(s * 1.23, .89, -.38), Vector3(.30, .13, .35), rune)


func _block(point: Vector3, dims: Vector3, material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radial_segments = 6
	mesh.rings = 3
	node.mesh = mesh
	node.material_override = material
	node.position = point
	node.scale = dims * 2
	add_child(node)
	return node


