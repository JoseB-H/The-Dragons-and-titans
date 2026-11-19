extends SceneTree
## Catálogo y perfiles reales; el combate jamás debe escribir en los recursos.

var checks := 0
var failures := 0

const SPECS := [
	{"id": &"jade", "name": "Jade", "health": 70, "speed": 8.0, "basic_damage": 15, "basic_cd": 0.3, "power_damage": 35, "power_cd": 2.0, "pulse_damage": 20, "radius": 3.5, "pulse_cd": 3.0},
	{"id": &"cobre", "name": "Cobre", "health": 100, "speed": 6.0, "basic_damage": 20, "basic_cd": 0.4, "power_damage": 45, "power_cd": 2.5, "pulse_damage": 30, "radius": 4.0, "pulse_cd": 4.0},
]


func _initialize() -> void:
	_run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func test_catalogue(roster: Node) -> void:
	expect(roster.selected_id == &"cobre", "La sesión nueva selecciona Cobre")
	var profiles: Array[Resource] = roster.get_profiles()
	expect(profiles.size() == 2, "El catálogo permite elegir entre dos perfiles")
	if profiles.size() != 2:
		return
	var copper: Resource = profiles[0]
	var jade: Resource = profiles[1]
	expect(copper != jade and copper.id == &"cobre" and jade.id == &"jade", "Cobre y Jade son recursos independientes con identidad estable")
	expect(copper.display_name == "Cobre" and jade.display_name == "Jade" and not copper.description.is_empty() and not jade.description.is_empty(), "El catálogo ofrece nombres y descripciones para elegir")
	expect(roster.selected_profile() == copper, "La selección inicial devuelve el recurso Cobre")
	expect(roster.select_dragon(&"jade") and roster.selected_id == &"jade" and roster.selected_profile() == jade, "Elegir Jade cambia la selección de la sesión")
	expect(not roster.select_dragon(&"desconocido") and roster.selected_id == &"jade" and roster.selected_profile() == jade, "Un id desconocido se rechaza sin cambiar Jade")
	expect(not roster.select_dragon(&"") and roster.selected_id == &"jade", "Un id vacío tampoco cambia la selección")
	profiles.clear()
	expect(roster.get_profiles().size() == 2, "Modificar la lista consultada no elimina perfiles del catálogo")
	expect(roster.select_dragon(&"cobre"), "La prueba devuelve la selección a Cobre")


func profile_snapshot(profile: Resource) -> Dictionary:
	var snapshot := {}
	for property in profile.get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			snapshot[property.name] = profile.get(property.name)
	return snapshot


func stop_actor(actor: Node) -> void:
	actor.set_physics_process(false)
	for child in actor.get_children():
		child.set_physics_process(false)


func make_dragon(world: Node3D) -> Node3D:
	var dragon: Node3D = load("res://scenes/dragon.tscn").instantiate()
	world.add_child(dragon)
	stop_actor(dragon)
	return dragon


func material_of(part: Node) -> StandardMaterial3D:
	if part is MeshInstance3D:
		return part.get_active_material(0) as StandardMaterial3D
	return part.material as StandardMaterial3D


func test_profile_combat(roster: Node, spec: Dictionary) -> void:
	roster.select_dragon(spec.id)
	var profile: Resource = roster.selected_profile()
	var before := profile_snapshot(profile)
	var world := Node3D.new()
	root.add_child(world)
	var shots := Node3D.new()
	var effects := Node3D.new()
	world.add_child(shots)
	world.add_child(effects)
	var dragon: Node3D = load("res://scenes/dragon.tscn").instantiate()
	var health_events: Array[Vector2i] = []
	dragon.health_changed.connect(func(current: int, maximum: int): health_events.append(Vector2i(current, maximum)))
	world.add_child(dragon)
	stop_actor(dragon)
	expect(dragon.get("profile_id") == spec.id and dragon.get("profile_name") == spec.name, "%s expone la identidad elegida" % spec.name)
	expect(dragon.max_health == spec.health and dragon.current_health == spec.health and health_events == [Vector2i(spec.health, spec.health)], "%s inicializa y anuncia salud del perfil desde el primer ready" % spec.name)
	var original_position := dragon.position
	Input.action_press("move_right")
	dragon._physics_process(0.25)
	Input.action_release("move_right")
	expect(is_equal_approx(dragon.position.distance_to(original_position), spec.speed * 0.25), "%s se mueve con su velocidad durante un paso real" % spec.name)
	dragon.position = original_position
	var target: Node3D = load("res://scenes/enemy.tscn").instantiate()
	target.position = Vector3(0, 1.5, -5)
	world.add_child(target)
	stop_actor(target)
	var basic: Node = dragon.get_node("Weapon")
	var power: Node = dragon.get_node("PowerWeapon")
	var pulse: Node = dragon.get_node("PulseAbility")
	basic.projectile_parent = shots
	power.projectile_parent = shots
	pulse.effects_parent = effects
	# Los colliders están sincronizados antes de ejercitar el barrido real.
	await physics_frame
	await process_frame
	for attack in [[basic, spec.basic_damage, spec.basic_cd, 28.0], [power, spec.power_damage, spec.power_cd, 36.0]]:
		var weapon: Node = attack[0]
		target.current_health = 80
		expect(weapon.try_fire(Vector3.FORWARD), "%s dispara el ataque configurado" % spec.name)
		var projectile: Node3D = shots.get_child(0)
		projectile.set_physics_process(false)
		expect(projectile.damage == attack[1] and is_equal_approx(projectile.speed, attack[3]) and is_equal_approx(projectile.lifetime, 2.0), "%s transmite daño, velocidad y vida del proyectil desde su perfil" % spec.name)
		expect(projectile.global_position.is_equal_approx(Vector3(0, 1.5, -1.9)), "%s conserva el origen de disparo de su recurso" % spec.name)
		expect(is_equal_approx(weapon.cooldown_remaining, attack[2]) and not weapon.try_fire(Vector3.FORWARD), "%s consume y bloquea su recarga al disparar" % spec.name)
		await physics_frame
		projectile._physics_process(0.2)
		expect(target.current_health == 80 - attack[1], "%s causa su daño de proyectil en una colisión real" % spec.name)
		await process_frame
		weapon._physics_process(attack[2] - 0.01)
		expect(not weapon.try_fire(Vector3.FORWARD), "%s sigue bloqueado antes de completar recarga" % spec.name)
		weapon._physics_process(0.02)
		expect(weapon.try_fire(Vector3.FORWARD), "%s vuelve a disparar al completar su recarga" % spec.name)
		for shot in shots.get_children():
			shot.free()
		weapon.cooldown_remaining = 0.0
	# Probar dentro y justo fuera del radio detecta aplicar el radio de otro perfil.
	target.current_health = 80
	target.position = Vector3(spec.radius - 0.05, 1.5, 0)
	expect(pulse.try_activate() and target.current_health == 80 - spec.pulse_damage, "%s aplica daño de pulso dentro de su radio" % spec.name)
	expect(is_equal_approx(pulse.cooldown_remaining, spec.pulse_cd) and not pulse.try_activate(), "%s consume y bloquea la recarga propia del pulso" % spec.name)
	var effect: Node = effects.get_child(0)
	effect.set_physics_process(false)
	expect(is_equal_approx(effect.radius, spec.radius) and is_equal_approx(effect.lifetime, 0.5), "%s configura radio y duración del efecto con su recurso" % spec.name)
	pulse._physics_process(spec.pulse_cd - 0.01)
	expect(not pulse.try_activate(), "%s no reactiva E antes de su recarga" % spec.name)
	pulse._physics_process(0.02)
	target.position.x = spec.radius + 0.05
	var target_health: int = target.current_health
	expect(pulse.try_activate() and target.current_health == target_health, "%s recarga E y respeta el exterior del radio" % spec.name)
	dragon.take_damage(10, 2)
	expect(dragon.current_health == spec.health - 10 and profile_snapshot(profile) == before, "%s conserva intacto el recurso tras daño, movimiento y todas las recargas" % spec.name)
	world.free()


func test_instance_isolation(roster: Node) -> void:
	var world := Node3D.new()
	root.add_child(world)
	roster.select_dragon(&"cobre")
	var copper := make_dragon(world)
	roster.select_dragon(&"jade")
	var jade := make_dragon(world)
	var another_jade := make_dragon(world)
	var enemy: Node3D = load("res://scenes/enemy.tscn").instantiate()
	world.add_child(enemy)
	stop_actor(enemy)
	var copper_visual := copper.get_node("Facing")
	var jade_visual := jade.get_node("Facing")
	var second_visual := another_jade.get_node("Facing")
	var enemy_visual := enemy.get_node("Facing")
	expect(copper_visual.kind == &"cobre" and jade_visual.kind == &"jade" and enemy_visual.kind == &"sentinela", "Cada actor recibe modelo original de su identidad")
	expect(copper_visual.materials[0] != jade_visual.materials[0] and jade_visual.materials[0] != second_visual.materials[0], "Materiales importados se aíslan por instancia")
	var original_color: Color = second_visual.materials[0].albedo_color
	jade_visual.materials[0].albedo_color = Color.MAGENTA
	expect(second_visual.materials[0].albedo_color == original_color and copper_visual.materials[0].albedo_color != Color.MAGENTA and enemy_visual.materials[0].albedo_color != Color.MAGENTA, "Editar material local no recolorea otros actores")
	var shots := Node3D.new()
	world.add_child(shots)
	jade.get_node("Weapon").projectile_parent = shots
	jade.take_damage(10, 2)
	expect(jade.get_node("Weapon").try_fire(Vector3.RIGHT) and jade.current_health == 60 and another_jade.current_health == 70 and another_jade.get_node("Weapon").cooldown_remaining == 0.0, "Salud y recargas se mantienen independientes entre dos Jade")
	expect(roster.selected_profile().max_health == 70 and is_equal_approx(roster.selected_profile().basic_cooldown, 0.3) and roster.selected_profile().body_color.is_equal_approx(Color(0.12, 0.52, 0.28, 1)), "Daño, recarga y cambio local de material dejan intactos los datos compartidos")
	world.free()
	roster.select_dragon(&"cobre")


func _run() -> void:
	var roster := root.get_node_or_null("DragonRoster")
	expect(roster != null, "Debe existir el catálogo de selección DragonRoster en la sesión")
	if roster != null:
		test_catalogue(roster)
		for spec: Dictionary in SPECS:
			await test_profile_combat(roster, spec)
		test_instance_isolation(roster)
		roster.select_dragon(&"cobre")
	print("V0.2 perfiles: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)
