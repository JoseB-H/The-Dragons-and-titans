extends "res://scripts/combat_actor.gd"

@export var team_color := Color.WHITE

signal shattered
signal shield_dropped

var shielded := true
var gem_node: MeshInstance3D


func drop_shield() -> void:
	shielded = false
	shield_dropped.emit()


func take_damage(amount: int, attacker_faction: int) -> bool:
	return false if shielded else super.take_damage(amount, attacker_faction)

func _ready() -> void:
	super._ready()
	var frame := StandardMaterial3D.new()
	frame.albedo_color = Color(0.27, 0.23, 0.25)
	frame.metallic = 0.45
	var crystal := StandardMaterial3D.new()
	crystal.albedo_color = team_color
	crystal.emission_enabled = true
	crystal.emission = team_color
	crystal.emission_energy_multiplier = 1.8

	var plinth := CylinderMesh.new()
	plinth.top_radius = 1.05
	plinth.bottom_radius = 1.65
	plinth.height = 0.65
	plinth.radial_segments = 8
	_mount(plinth, frame, Vector3.DOWN * 1.12)

	var gem := PrismMesh.new()
	gem.size = Vector3(0.88, 1.92, 0.9)
	gem_node = _mount(gem, crystal, Vector3.UP * 0.15)
	gem_node.rotation.y = PI / 4.0

	var pillar := BoxMesh.new()
	pillar.size = Vector3(0.26, 2.1, 0.32)
	for side in range(4):
		var angle := side * TAU / 4.0
		var post := _mount(pillar, frame, Vector3(cos(angle), -0.1, sin(angle)))
		post.rotation.z = 0.13 * cos(angle)
		post.rotation.x = -0.13 * sin(angle)

	var ring := TorusMesh.new()
	ring.inner_radius = 1.77
	ring.outer_radius = 1.83
	ring.rings = 28
	ring.ring_segments = 8
	var halo := _mount(ring, crystal, Vector3.DOWN * 1.37)
	var shield := SphereMesh.new()
	shield.radius = 1.49
	shield.height = 2.98
	var glass := StandardMaterial3D.new()
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glass.albedo_color = Color(team_color, 0.18)
	var barrier := _mount(shield, glass, Vector3.ZERO)
	barrier.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	shield_dropped.connect(barrier.hide)
	died.connect(func():
		crystal.emission_enabled = false
		halo.hide()
	)


func _mount(mesh: Mesh, material: Material, offset: Vector3) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = offset
	add_child(instance)
	return instance

## Ruptura que se reproduce cuando la cámara llega al núcleo en Frontera.
func shatter() -> void:
	gem_node.hide()
	shattered.emit()
	var shard := PrismMesh.new()
	shard.size = Vector3(0.23, 0.72, 0.25)
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.albedo_color = team_color.lightened(0.45)
	for index in range(18):
		var angle := index * TAU / 18.0
		var outward := Vector3(cos(angle), 0, sin(angle))
		var fragment := _mount(shard, glow, Vector3.UP * 0.3)
		var burst := fragment.create_tween()
		var apex := outward * (1.1 + index % 3 * 0.38) + Vector3.UP * (1.2 + index % 4 * 0.32)
		burst.tween_property(fragment, "position", apex, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		burst.parallel().tween_property(fragment, "rotation", Vector3(angle, angle * 0.5, 1), 0.38)
		burst.tween_property(fragment, "position", apex * 1.45 - Vector3.UP * 2.3, 0.75)
		burst.parallel().tween_property(fragment, "scale", Vector3.ONE * 0.02, 0.75)
		burst.tween_callback(fragment.queue_free)
