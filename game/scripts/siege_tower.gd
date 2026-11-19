extends "res://scripts/combat_actor.gd"

@export var team_color := Color.WHITE
@export var attack_range := 4.8

@onready var weapon: Node3D = $Weapon


func _ready() -> void:
	super._ready()
	var tower := CylinderMesh.new()
	tower.top_radius = 0.62
	tower.bottom_radius = 1.05
	tower.height = 2.65
	tower.radial_segments = 6
	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color(0.30, 0.23, 0.22)
	_mount(tower, stone, -0.1)

	var lens := SphereMesh.new()
	lens.radius = 0.50
	lens.height = 1.0
	var light := StandardMaterial3D.new()
	light.albedo_color = team_color
	light.emission_enabled = true
	light.emission = team_color
	var beacon := _mount(lens, light, 1.25)
	died.connect(beacon.hide)


func defend(opponents: Array[Node3D]) -> void:
	if not can_act():
		return
	var nearest := Vector3.ZERO
	var limit := attack_range * attack_range
	for opponent in opponents:
		if not opponent.can_act():
			continue
		var offset := opponent.global_position - global_position
		offset.y = 0.0
		var distance := offset.length_squared()
		if distance > 0.0001 and distance < limit:
			nearest = offset
			limit = distance
	if not nearest.is_zero_approx():
		weapon.try_fire(nearest)


func _mount(mesh: Mesh, material: Material, height: float) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position.y = height
	add_child(instance)
	return instance
