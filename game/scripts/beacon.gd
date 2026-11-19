extends Node3D

const RADIUS := 2.4
const CAPTURE_SECONDS := 2.0
const INACTIVE := Color(1.0, 0.68, 0.24)
const CAPTURED := Color(0.33, 1.0, 0.72)

@export var beacon_name := ""

var progress := 0.0
var captured := false
var _marker := Label3D.new()
var _material := StandardMaterial3D.new()


func _ready() -> void:
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var disk := CylinderMesh.new()
	disk.top_radius = RADIUS
	disk.bottom_radius = RADIUS
	disk.height = 0.06
	var zone := MeshInstance3D.new()
	zone.mesh = disk
	zone.material_override = _material
	zone.position.y = 0.08
	add_child(zone)

	_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_marker.font_size = 36
	_marker.pixel_size = 0.012
	_marker.position.y = 2.65
	add_child(_marker)
	_refresh_marker()


func update_capture(player_position: Vector3, delta: float) -> void:
	if captured:
		return
	var offset := player_position - global_position
	if Vector2(offset.x, offset.z).length_squared() <= RADIUS * RADIUS:
		progress = minf(progress + delta, CAPTURE_SECONDS)
	else:
		progress = 0.0
	captured = progress >= CAPTURE_SECONDS
	_refresh_marker()


func _refresh_marker() -> void:
	var fraction := progress / CAPTURE_SECONDS
	_material.albedo_color = Color(0.32, 0.21, 0.08).lerp(Color(0.12, 0.48, 0.33), fraction)
	_marker.modulate = CAPTURED if captured else INACTIVE
	_marker.text = "%s · %d%%" % [beacon_name, int(fraction * 100)]
