extends SceneTree
## Q usa el arma y el mundo físico de T03; sin dobles ni colisión simulada.

var checks := 0
var failures := 0
var actor_script: Script = load("res://scripts/combat_actor.gd")
var weapon_script: Script = load("res://scripts/weapon.gd")
var power_scene: PackedScene


func _initialize() -> void:
	_run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func tick(count: int = 1) -> void:
	for frame in range(count):
		await physics_frame
		await process_frame


func make_actor(parent: Node3D, at: Vector3, team: int = 1) -> CharacterBody3D:
	var actor: CharacterBody3D = actor_script.new()
	actor.faction = team
	actor.position = at
	actor.collision_layer = 1
	actor.collision_mask = 0
	var collider := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.8
	collider.shape = sphere
	actor.add_child(collider)
	parent.add_child(actor)
	return actor


func make_weapon(actor: CharacterBody3D, projectiles: Node3D) -> Node3D:
	var weapon: Node3D = weapon_script.new()
	weapon.projectile_scene = power_scene
	weapon.damage = 45
	weapon.projectile_speed = 36.0
	weapon.projectile_lifetime = 2.0
	weapon.cooldown = 2.5
	weapon.spawn_distance = 1.9
	weapon.projectile_parent = projectiles
	actor.add_child(weapon)
	return weapon


func pack_scene(node: Node) -> PackedScene:
	var scene := PackedScene.new()
	expect(scene.pack(node) == OK, "La escena inválida de prueba se empaqueta correctamente")
	node.free()
	return scene


func test_configuration() -> void:
	var world := Node3D.new()
	world.position = Vector3(3, 0, -2)
	root.add_child(world)
	var actor := make_actor(world, Vector3(2, 1.5, 5))
	var shots := Node3D.new()
	shots.position = Vector3(-4, 0, 1)
	world.add_child(shots)
	var weapon := make_weapon(actor, shots)
	weapon.position = Vector3(4, 5, 6)
	expect(weapon.try_fire(Vector3(3, 7, -4)), "Q dispara con dirección XZ válida")
	expect(shots.get_child_count() == 1, "Q crea un único proyectil")
	var projectile: Node3D = shots.get_child(0)
	expect(projectile.scene_file_path == "res://scenes/power_projectile.tscn", "El arma instancia la escena Q configurada")
	expect(projectile.get_script() == load("res://scripts/projectile.gd"), "Q reutiliza el script de proyectil T03")
	expect(projectile.direction.is_equal_approx(Vector3(0.6, 0, -0.8)), "Q elimina altura y normaliza la dirección solicitada")
	expect(projectile.global_position.is_equal_approx(Vector3(6.14, 1.5, 1.48)), "Q conserva offset global con actor y contenedor desplazados")
	expect(projectile.launch_origin == Vector3(5, 1.5, 3), "Q conserva el origen del barrido anterior al offset visual")
	expect(projectile.damage == 45 and is_equal_approx(projectile.speed, 36.0) and is_equal_approx(projectile.lifetime, 2.0), "Q transmite daño, velocidad y duración configurados")
	expect(projectile.source_faction == 1 and projectile.source_rid == actor.get_rid(), "Q transmite facción y RID del emisor")
	expect(is_equal_approx(weapon.cooldown_remaining, 2.5), "El disparo aceptado inicia su recarga configurada")
	var visual: MeshInstance3D = projectile.get_node("Visual")
	var mesh := visual.mesh as SphereMesh
	var material := mesh.material as StandardMaterial3D
	expect(is_equal_approx(mesh.radius, 0.3), "La geometría Q tiene radio 0.3")
	expect(material.albedo_color.r > 0.6 and material.albedo_color.b > 0.6 and material.albedo_color.g < 0.4, "El proyectil Q usa material magenta/púrpura propio")
	var basic: Node3D = weapon_script.new()
	basic.projectile_parent = shots
	actor.add_child(basic)
	expect(basic.try_fire(Vector3.RIGHT), "El arma básica conserva la escena por defecto")
	var basic_projectile: Node3D = shots.get_child(1)
	expect(basic_projectile.scene_file_path == "res://scenes/projectile.tscn" and basic_projectile.damage == 20, "La configuración Q no cambia el proyectil básico T03")
	world.free()


func test_rejections() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var actor := make_actor(world, Vector3(0, 1.5, 0))
	var shots := Node3D.new()
	world.add_child(shots)
	var weapon := make_weapon(actor, shots)
	for invalid_scene: PackedScene in [null, PackedScene.new(), pack_scene(Node.new()), pack_scene(Node3D.new()), pack_scene(actor_script.new())]:
		weapon.projectile_scene = invalid_scene
		expect(not weapon.try_fire(Vector3.RIGHT), "Una escena nula, vacía o incompatible rechaza Q")
		expect(shots.get_child_count() == 0 and weapon.cooldown_remaining == 0.0, "Una escena inválida no añade proyectiles ni consume recarga")
	weapon.projectile_scene = power_scene
	expect(not weapon.try_fire(Vector3.ZERO) and not weapon.try_fire(Vector3.UP), "Q rechaza direcciones sin componente XZ")
	expect(shots.get_child_count() == 0 and weapon.cooldown_remaining == 0.0, "La dirección rechazada no crea efectos ni consume recarga")
	expect(weapon.try_fire(Vector3.RIGHT), "Corregir la escena permite disparar inmediatamente")
	actor.take_damage(100, 2)
	weapon.cooldown_remaining = 0.0
	expect(not weapon.try_fire(Vector3.RIGHT) and shots.get_child_count() == 1, "Un emisor muerto no puede usar Q")
	expect(weapon.cooldown_remaining == 0.0, "Q rechazada por muerte conserva recarga cero")
	world.free()


func test_cooldown_independence() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var actor := make_actor(world, Vector3(0, 1.5, 0))
	var shots := Node3D.new()
	world.add_child(shots)
	var power := make_weapon(actor, shots)
	power.projectile_speed = 0.0
	var basic: Node3D = weapon_script.new()
	basic.projectile_parent = shots
	basic.projectile_speed = 0.0
	actor.add_child(basic)
	expect(power.try_fire(Vector3.RIGHT) and basic.try_fire(Vector3.LEFT), "Q y básico pueden disparar en el mismo tick")
	expect(not power.try_fire(Vector3.RIGHT) and not basic.try_fire(Vector3.LEFT) and shots.get_child_count() == 2, "Cada recarga bloquea su repetición inmediata")
	await tick(2)
	expect(power.cooldown_remaining > 0.0 and power.cooldown_remaining < 2.5, "La recarga Q decrece en física real")
	await tick(30)
	expect(basic.cooldown_remaining == 0.0 and basic.try_fire(Vector3.LEFT), "El básico vuelve a disparar durante la recarga Q")
	expect(not power.try_fire(Vector3.RIGHT) and power.cooldown_remaining > 1.5, "Usar el básico conserva la recarga independiente de Q")
	await tick(130)
	expect(power.cooldown_remaining == 0.0 and power.try_fire(Vector3.RIGHT), "Q vuelve a disparar después de su propia recarga")
	world.free()


func test_swept_impact() -> void:
	var world := Node3D.new()
	root.add_child(world)
	# El emisor pertenece a otra facción para probar la exclusión por RID.
	var emitter := make_actor(world, Vector3(0, 1.5, 0), 2)
	var ally := make_actor(world, Vector3(2, 1.5, 0), 1)
	var dead := make_actor(world, Vector3(4, 1.5, 0), 2)
	dead.take_damage(100, 1)
	var target := make_actor(world, Vector3(6, 1.5, 0), 2)
	var behind := make_actor(world, Vector3(8, 1.5, 0), 2)
	var shots := Node3D.new()
	world.add_child(shots)
	var weapon := make_weapon(emitter, shots)
	weapon.projectile_speed = 600.0
	var impacts: Array[int] = []
	target.health_changed.connect(func(current: int, _maximum: int): impacts.append(current))
	await tick(2)
	expect(weapon.try_fire(Vector3.RIGHT), "Q admite velocidad exportada de 600 u/s")
	var projectile: Node3D = shots.get_child(0)
	projectile.source_faction = 1
	await tick(2)
	expect(emitter.current_health == 100, "El barrido inicial Q excluye el RID del emisor")
	expect(ally.current_health == 100 and dead.current_health == 0, "Q atraviesa aliados y muertos sin dañarlos")
	expect(target.current_health == 55, "El barrido Q a 600 u/s causa 45 de daño al primer hostil vivo")
	expect(behind.current_health == 100, "El primer impacto Q impide dañar al siguiente hostil")
	expect(not is_instance_valid(projectile) and shots.get_child_count() == 0, "Q se elimina tras el impacto físico")
	await tick(6)
	expect(impacts == [55] and target.current_health == 55, "El impacto Q aplica daño y emite cambio una sola vez")
	world.free()


func test_muzzle_gap() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var emitter := make_actor(world, Vector3(0, 1.5, 0))
	# La esfera termina en X=1.8: está completamente antes del offset X=1.9.
	var near_target := make_actor(world, Vector3(1, 1.5, 0), 2)
	var behind := make_actor(world, Vector3(3, 1.5, 0), 2)
	var shots := Node3D.new()
	world.add_child(shots)
	var weapon := make_weapon(emitter, shots)
	await tick(2)
	expect(weapon.try_fire(Vector3.RIGHT), "Q dispara con hostil dentro del offset visual")
	var projectile: Node3D = shots.get_child(0)
	expect(projectile.global_position.is_equal_approx(Vector3(1.9, 1.5, 0)), "El barrido Q conserva el origen visual configurado")
	await tick(2)
	expect(near_target.current_health == 55 and behind.current_health == 100, "Q alcanza primero el hostil anterior al offset")
	expect(not is_instance_valid(projectile), "El impacto cercano retira el proyectil Q")
	await tick(4)
	expect(near_target.current_health == 55, "El objetivo cercano recibe el daño Q una sola vez")
	world.free()


func test_expiry() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var emitter := make_actor(world, Vector3(0, 1.5, 0))
	var target := make_actor(world, Vector3(2.5, 1.5, 0), 2)
	var shots := Node3D.new()
	world.add_child(shots)
	var weapon := make_weapon(emitter, shots)
	weapon.spawn_distance = 0.0
	weapon.projectile_speed = 60.0
	weapon.projectile_lifetime = 0.025
	weapon.cooldown = 0.0
	await tick(2)
	expect(weapon.try_fire(Vector3.RIGHT), "Q transmite una duración fraccionaria configurable")
	var projectile: Node3D = shots.get_child(0)
	await tick(4)
	expect(target.current_health == 100, "Q no recorre un tick adicional después de agotar su vida")
	expect(not is_instance_valid(projectile) and shots.get_child_count() == 0, "Q caduca y se elimina sin impacto")
	weapon.projectile_speed = 0.0
	weapon.projectile_lifetime = 0.03
	expect(weapon.try_fire(Vector3.RIGHT), "Q permite proyectil inmóvil con duración finita")
	await tick(4)
	expect(shots.get_child_count() == 0, "Q inmóvil también caduca sin acumular nodos")
	world.free()


func _run() -> void:
	var probe: Node3D = weapon_script.new()
	var has_scene_property := false
	for property: Dictionary in probe.get_property_list():
		if property.name == "projectile_scene":
			has_scene_property = true
	expect(has_scene_property, "El arma debe permitir configurar la escena del proyectil Q")
	probe.free()
	var has_power_scene := ResourceLoader.exists("res://scenes/power_projectile.tscn")
	expect(has_power_scene, "Debe existir el recurso propio para distinguir visualmente Q")
	if has_scene_property and has_power_scene:
		power_scene = load("res://scenes/power_projectile.tscn")
		test_configuration()
		test_rejections()
		await test_cooldown_independence()
		await test_swept_impact()
		await test_muzzle_gap()
		await test_expiry()
	print("T04 Q: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)
