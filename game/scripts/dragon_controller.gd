extends "res://scripts/combat_actor.gd"
## Controles provisionales: movimiento relativo a pantalla y apuntado en plano XZ.
## La raíz solo se traslada; Facing gira y Camera hereda únicamente la traslación.

@export_range(0.0, 50.0, 0.1) var movement_speed := 6.0
@export var flight_height := 1.5
@export var arena_half_size := Vector2(12.0, 12.0)
@export_range(0.0, 12.0, 0.1) var bounds_margin := 2.0

@onready var camera: Camera3D = $Camera
@onready var facing: Node3D = $Facing
@onready var weapon: Node3D = $Weapon
@onready var power_weapon: Node3D = $PowerWeapon
@onready var pulse_ability: Node3D = $PulseAbility

var profile_id: StringName
var profile_name: String

var _q_held := false
var _e_held := false
var _held_at_start: Array[StringName] = []

const ENTRY_ACTIONS := [&"move_left", &"move_right", &"move_forward", &"move_back", &"attack", &"ability_q", &"ability_e", &"restore_arena", &"ui_accept"]


func _enter_tree() -> void:
	# El setter de CombatActor ya emite señales dentro de _ready. Preparar la
	# máxima antes evita anunciar 0 de salud al inicializar un perfil distinto.
	max_health = get_node("/root/DragonRoster").selected_profile().max_health


func _ready() -> void:
	_apply_profile(get_node("/root/DragonRoster").selected_profile())
	super._ready()
	for action: StringName in ENTRY_ACTIONS:
		if Input.is_action_pressed(action):
			_held_at_start.append(action)
	_q_held = Input.is_action_pressed("ability_q")
	_e_held = Input.is_action_pressed("ability_e")
	_constrain_position()
	reset_physics_interpolation()


func _apply_profile(profile: Resource) -> void:
	profile_id = profile.id
	profile_name = profile.display_name
	max_health = profile.max_health
	movement_speed = profile.movement_speed
	weapon.damage = profile.basic_damage
	weapon.cooldown = profile.basic_cooldown
	weapon.projectile_speed = profile.basic_projectile_speed
	weapon.projectile_lifetime = profile.basic_projectile_lifetime
	weapon.spawn_distance = profile.basic_spawn_distance
	power_weapon.damage = profile.power_damage
	power_weapon.cooldown = profile.power_cooldown
	power_weapon.projectile_speed = profile.power_projectile_speed
	power_weapon.projectile_lifetime = profile.power_projectile_lifetime
	power_weapon.spawn_distance = profile.power_spawn_distance
	pulse_ability.damage = profile.pulse_damage
	pulse_ability.radius = profile.pulse_radius
	pulse_ability.cooldown = profile.pulse_cooldown
	pulse_ability.effect_duration = profile.pulse_effect_duration
	_apply_palette(profile)


func _apply_palette(profile: Resource) -> void:
	# Los meshes de la escena siguen compartidos: solo copiar sus materiales.
	# Las referencias originales identifican cuerpo, acentos y membranas sin
	# acoplar el color al id del dragón ni recolorear ojos/cuernos.
	var palette := {
		facing.get_node("Body").get_active_material(0): profile.body_color,
		facing.get_node("Chest").get_active_material(0): profile.accent_color,
		facing.get_node("LeftWing").material: profile.wing_color,
	}
	for part in facing.get_children():
		var source: StandardMaterial3D
		if part is MeshInstance3D:
			source = part.get_active_material(0) as StandardMaterial3D
		elif part is CSGPolygon3D:
			source = part.material as StandardMaterial3D
		if source == null:
			continue
		var local_material := source.duplicate() as StandardMaterial3D
		if palette.has(source):
			local_material.albedo_color = palette[source]
		if part is MeshInstance3D:
			part.material_override = local_material
		else:
			part.material = local_material


func _physics_process(delta: float) -> void:
	_refresh_input_release()
	velocity = Vector3.ZERO
	if not can_act() or waiting_for_release():
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var right := camera.global_basis.x
	var back := camera.global_basis.z
	right.y = 0.0
	back.y = 0.0
	var direction := (right.normalized() * input.x + back.normalized() * input.y).limit_length(1.0)
	position += direction * movement_speed * delta
	_constrain_position()
	_aim_at_cursor(get_viewport().get_mouse_position())
	if Input.is_action_pressed("attack"):
		weapon.try_fire(-facing.global_basis.z)


func _input(_event: InputEvent) -> void:
	# También observar releases que consume el botón antes de unhandled_input.
	_refresh_input_release()


func _unhandled_input(event: InputEvent) -> void:
	_refresh_input_release()
	if not event is InputEventKey:
		return
	if event.is_action("ability_q"):
		# Marcar antes de activar: los callbacks de daño pueden retirar la escena.
		get_viewport().set_input_as_handled()
		if not event.pressed:
			_q_held = false
		elif not event.echo and not _q_held:
			_q_held = true
			if can_act() and not waiting_for_release():
				power_weapon.try_fire(-facing.global_basis.z)
	elif event.is_action("ability_e"):
		get_viewport().set_input_as_handled()
		if not event.pressed:
			_e_held = false
		elif not event.echo and not _e_held:
			_e_held = true
			if can_act() and not waiting_for_release():
				pulse_ability.try_activate()


func waiting_for_release() -> bool:
	return not _held_at_start.is_empty()


func _refresh_input_release() -> void:
	for index in range(_held_at_start.size() - 1, -1, -1):
		if not Input.is_action_pressed(_held_at_start[index]):
			_held_at_start.remove_at(index)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_q_held = false
		_e_held = false


func _constrain_position() -> void:
	var limit := (arena_half_size - Vector2.ONE * bounds_margin).max(Vector2.ZERO)
	position = Vector3(clampf(position.x, -limit.x, limit.x), flight_height, clampf(position.z, -limit.y, limit.y))


func _aim_at_cursor(cursor: Vector2) -> void:
	if not get_viewport().get_visible_rect().has_point(cursor):
		return
	var plane := Plane(Vector3.UP, global_position.y)
	var hit: Variant = plane.intersects_ray(camera.project_ray_origin(cursor), camera.project_ray_normal(cursor))
	if hit == null or global_position.distance_squared_to(hit) < 0.0001:
		return
	facing.look_at(hit, Vector3.UP)
