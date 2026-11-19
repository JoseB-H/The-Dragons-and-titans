extends Node3D
## Modelos originales GLB: esqueleto y clips importados, aislados del actor físico.
const MODELS := {
	&"cobre": preload("res://assets/dragons/cobre.glb"),
	&"jade": preload("res://assets/dragons/jade.glb"),
	&"sentinela": preload("res://assets/dragons/sentinela.glb"),
}
var enabled := false
var bank_enabled := false
var actor: Node3D
var model: Node3D
var skeleton: Skeleton3D
var animation: AnimationPlayer
var kind: StringName
var breath: CPUParticles3D
var attack_time := 0.0
var hit_time := 0.0
var death_amount := 0.0
var last_health := 0
var previous_position := Vector3.ZERO
var active_clip: StringName
var materials: Array[StandardMaterial3D] = []

func configure(owner_actor: Node3D, model_kind: StringName = &"") -> void:
	if enabled:
		return
	actor = owner_actor
	kind = model_kind if model_kind != &"" else actor.profile_id
	if not MODELS.has(kind):
		push_error("Modelo de dragón desconocido: " + str(kind))
		return
	enabled = true
	last_health = actor.current_health
	previous_position = actor.position
	model = MODELS[kind].instantiate()
	model.name = "Model"
	add_child(model)
	for node in model.find_children("*", "Skeleton3D", true, false):
		skeleton = node
	for node in model.find_children("*", "AnimationPlayer", true, false):
		animation = node
	# Los recursos importados se comparten; efectos y edición local nunca los mutan.
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		for index in range(mesh.mesh.get_surface_count()):
			var source := mesh.get_active_material(index) as StandardMaterial3D
			if source != null:
				var local := source.duplicate() as StandardMaterial3D
				mesh.set_surface_override_material(index, local)
				materials.append(local)
	if animation != null:
		# Los Animation son compartidos de solo lectura; duplicar para fijar loop local.
		for library_name in animation.get_animation_library_list():
			var library := animation.get_animation_library(library_name).duplicate() as AnimationLibrary
			animation.remove_animation_library(library_name)
			animation.add_animation_library(library_name, library)
		for clip in animation.get_animation_list():
			var anim := animation.get_animation(clip).duplicate() as Animation
			anim.loop_mode = Animation.LOOP_LINEAR if clip == &"Flight" else Animation.LOOP_NONE
			animation.get_animation_library(&"").remove_animation(clip)
			animation.get_animation_library(&"").add_animation(clip, anim)
		_play(&"Flight")
	if kind == &"cobre":
		_setup_breath()
		actor.get_node("Weapon").fired.connect(breath.restart)
	actor.health_changed.connect(_on_health_changed)
	actor.get_node("Weapon").fired.connect(_on_attack)
	if actor.has_node("PowerWeapon"):
		actor.get_node("PowerWeapon").fired.connect(_on_attack)
	if actor.has_node("PulseAbility"):
		actor.get_node("PulseAbility").activated.connect(_on_attack)

func _on_attack() -> void:
	attack_time = animation.get_animation(&"Attack").length
	if actor.is_alive():
		_play(&"Attack", true)

func _on_health_changed(current: int, _maximum: int) -> void:
	if current < last_health:
		hit_time = animation.get_animation(&"Hit").length
		if current > 0:
			_play(&"Hit", true)
	last_health = current

func _play(clip: StringName, restart := false) -> void:
	if animation == null or not animation.has_animation(clip):
		return
	if active_clip != clip or restart:
		animation.play(clip, 0.07)
		active_clip = clip

func _process(delta: float) -> void:
	if not enabled or not is_instance_valid(actor):
		return
	attack_time = maxf(0, attack_time - delta)
	hit_time = maxf(0, hit_time - delta)
	if not actor.is_alive():
		death_amount = minf(1, death_amount + delta)
		animation.speed_scale = 1.0
		_play(&"Death")
		return
	if bank_enabled:
		var lateral_speed: float = actor.velocity.dot(global_basis.x)
		var roll := clampf(lateral_speed * 0.042, -0.32, 0.32)
		model.rotation.z = lerpf(model.rotation.z, roll, 1.0 - exp(-8.0 * delta))
	var speed := actor.position.distance_to(previous_position) / maxf(delta, 0.0001)
	previous_position = actor.position
	if hit_time > 0:
		_play(&"Hit")
	elif attack_time > 0:
		_play(&"Attack")
	else:
		_play(&"Flight")
	animation.speed_scale = 1.0 + minf(speed / 24.0, 0.35) if active_clip == &"Flight" else 1.0

func _setup_breath() -> void:
	breath = CPUParticles3D.new()
	breath.emitting = false
	breath.one_shot = true
	breath.amount = 28
	breath.lifetime = 0.27
	breath.explosiveness = 0.67
	breath.local_coords = true
	breath.direction = Vector3.FORWARD
	breath.spread = 14.0
	breath.gravity = Vector3(0, 0.35, 0)
	breath.initial_velocity_min = 4.2
	breath.initial_velocity_max = 9.5
	breath.scale_amount_min = 0.09
	breath.scale_amount_max = 0.25
	var colors := Gradient.new()
	colors.colors = PackedColorArray([Color("#fff9a5"), Color("#ff8d17"), Color("#b6351600")])
	colors.offsets = PackedFloat32Array([0, 0.46, 1])
	breath.color_ramp = colors
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var ember := SphereMesh.new()
	ember.radial_segments = 6
	ember.rings = 3
	ember.material = material
	breath.mesh = ember
	breath.position = Vector3(0, 0.28, -1.78)
	model.add_child(breath)
