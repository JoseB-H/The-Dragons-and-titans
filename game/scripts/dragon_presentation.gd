extends Node3D
## Arte original procedural. Solo transforma geometría: nunca colisiones ni balance.
var enabled := false
var elapsed := 0.0
var attack_time := 0.0
var hit_time := 0.0
var death_amount := 0.0
var actor: Node3D
var details: Node3D
var rest: Dictionary = {}
var wing_parts: Array[Node3D] = []
var previous_position := Vector3.ZERO
var moving := 0.0
var last_health := 0
var material_skin: StandardMaterial3D
var material_plate: StandardMaterial3D
var material_ivory: StandardMaterial3D

func configure(owner_actor: Node3D) -> void:
	if enabled:
		return
	actor = owner_actor
	enabled = true
	previous_position = actor.position
	last_health = actor.current_health
	material_skin = $Body.get_active_material(0).duplicate()
	material_skin.roughness = 0.62
	material_plate = $Chest.get_active_material(0).duplicate()
	material_plate.roughness = 0.56
	material_ivory = $LeftHorn.get_active_material(0).duplicate()
	details = Node3D.new()
	details.name = "CobreDetails"
	add_child(details)
	_build_details()
	for part in get_children():
		if part is Node3D:
			rest[part] = part.transform
			if "Wing" in str(part.name):
				wing_parts.append(part)
	actor.health_changed.connect(_on_health_changed)
	actor.get_node("Weapon").fired.connect(_on_attack)
	actor.get_node("PowerWeapon").fired.connect(_on_attack)
	actor.get_node("PulseAbility").activated.connect(_on_attack)

func _mesh(name_text: String, mesh: Mesh, at: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = name_text
	part.mesh = mesh
	part.position = at
	part.scale = size
	part.material_override = material
	details.add_child(part)
	return part

func _spike(name_text: String, at: Vector3, length: float, radius: float) -> MeshInstance3D:
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = radius
	cone.height = length
	cone.radial_segments = 7
	return _mesh(name_text, cone, at, Vector3.ONE, material_ivory)

func _build_details() -> void:
	# Secciones elípticas: hocico anguloso continuo, en lugar de una caja.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings := [Vector3(0.29, 0.23, -1.02), Vector3(0.27, 0.16, -1.36), Vector3(0.18, 0.1, -1.76)]
	for ring in range(2):
		for side in range(8):
			var points: Array[Vector3] = []
			for index in [side, (side + 1) % 8]:
				var angle := TAU * float(index) / 8.0
				for section in [ring, ring + 1]:
					var r: Vector3 = rings[section]
					points.append(Vector3(cos(angle) * r.x, 0.26 + sin(angle) * r.y, r.z))
			for index in [0, 1, 2, 2, 1, 3]:
				surface.add_vertex(points[index])
	# Cerrar la punta.
	for side in range(8):
		for index in [(side + 1) % 8, side, -1]:
			var angle := TAU * float(index) / 8.0
			surface.add_vertex(Vector3(cos(angle) * 0.18, 0.26 + sin(angle) * 0.1, -1.76) if index >= 0 else Vector3(0, 0.26, -1.76))
	surface.generate_normals()
	_mesh("SculptedMuzzle", surface.commit(), Vector3.ZERO, Vector3.ONE, material_skin)
	$Snout.visible = false
	var plate := SphereMesh.new()
	plate.radial_segments = 8
	plate.rings = 4
	# Placas dorsales escalonadas y escamas en ambos flancos.
	for row in range(7):
		var z := -0.54 + row * 0.17
		_mesh("DorsalPlate%d" % row, plate, Vector3(0, 0.31, z), Vector3(0.45, 0.17, 0.3), material_plate)
		for sign_value in [-1.0, 1.0]:
			var scale_part := _mesh("Flank%d_%s" % [row, sign_value], plate, Vector3(sign_value * 0.32, 0.13, z), Vector3(0.25, 0.17, 0.3), material_skin)
			scale_part.rotation.z = sign_value * 0.5
	for sign_value in [-1.0, 1.0]:
		var horn := _spike("SweptHorn%s" % sign_value, Vector3(sign_value * 0.25, 0.67, -0.78), 0.58, 0.09)
		horn.rotation = Vector3(0.65, 0, -sign_value * 0.25)
		var brow := _mesh("Brow%s" % sign_value, plate, Vector3(sign_value * 0.27, 0.46, -1.19), Vector3(0.22, 0.12, 0.32), material_skin)
		brow.rotation.z = -sign_value * 0.3
		for tooth in range(4):
			var fang := _spike("Fang%s_%d" % [sign_value, tooth], Vector3(sign_value * 0.2, 0.13, -1.3 - tooth * 0.1), 0.09, 0.026)
			fang.rotation.x = PI
		for leg_z in [-0.48, 0.48]:
			for claw in range(3):
				var talon := _spike("Claw%s_%s_%d" % [sign_value, leg_z, claw], Vector3(sign_value * (0.22 + claw * 0.06), -0.35, leg_z - 0.18), 0.16, 0.035)
				talon.rotation.x = -PI / 2.0
	# Membranas existentes siguen siendo propias; nervaduras adicionales legibles.
	for sign_value in [-1.0, 1.0]:
		for finger in range(3):
			var start := Vector3(sign_value * 0.65, 0.25, -0.6)
			var end := Vector3(sign_value * (1.6 - finger * 0.33), 0.25, 0.35 + finger * 0.15)
			var bone := CylinderMesh.new()
			bone.top_radius = 0.018
			bone.bottom_radius = 0.035
			bone.height = start.distance_to(end)
			bone.radial_segments = 5
			var rib := _mesh("WingRib%s_%d" % [sign_value, finger], bone, (start + end) / 2.0, Vector3.ONE, material_plate)
			rib.quaternion = Quaternion(Vector3.UP, (end - start).normalized())
			# Mantener nervaduras en el mismo espacio que las alas animadas.
			details.remove_child(rib)
			add_child(rib)

func _on_attack() -> void:
	attack_time = 0.24

func _on_health_changed(current: int, _maximum: int) -> void:
	if current < last_health:
		hit_time = 0.22
	last_health = current

func _process(delta: float) -> void:
	if not enabled or not is_instance_valid(actor):
		return
	elapsed += delta
	var speed := actor.position.distance_to(previous_position) / maxf(delta, 0.0001)
	previous_position = actor.position
	moving = lerpf(moving, clampf(speed / maxf(actor.movement_speed, 0.01), 0, 1), minf(delta * 8, 1))
	attack_time = maxf(attack_time - delta, 0)
	hit_time = maxf(hit_time - delta, 0)
	death_amount = move_toward(death_amount, 0.0 if actor.is_alive() else 1.0, delta * 2.0)
	var flap := sin(elapsed * (5.0 + moving * 3.0)) * (0.14 + moving * 0.12) * (1.0 - death_amount)
	var visual_offset := Vector3(0, sin(elapsed * 5.0) * 0.035 * (1.0 - death_amount) - death_amount * 0.65, 0)
	var visual_roll := sin(hit_time * 70.0) * hit_time * 0.3 + death_amount * 0.32
	var visual_pose := Transform3D(Basis(Vector3.BACK, visual_roll), visual_offset)
	for part: Node3D in rest:
		part.transform = rest[part]
		if part in wing_parts:
			var side := -1.0 if str(part.name).begins_with("Left") or "-1" in str(part.name) else 1.0
			var pivot := Vector3(side * 0.3, 0.19, 0)
			var rotation_basis := Basis(Vector3.FORWARD, side * (flap + death_amount * 0.7))
			part.transform = Transform3D(rotation_basis, pivot - rotation_basis * pivot) * part.transform
		elif str(part.name).begins_with("Tail"):
			part.position.x += sin(elapsed * 3.0 + part.position.z) * 0.07 * (1.0 - death_amount)
		elif part.name == &"LowerJaw":
			part.rotation.x += attack_time * 0.9
		part.transform = visual_pose * part.transform
