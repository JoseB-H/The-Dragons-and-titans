extends SceneTree
## Núcleo de combate real: señales, recarga y consultas del mundo físico, sin mocks.

var checks := 0
var failures := 0
var actor_script: Script
var weapon_script: Script
var projectile_scene: PackedScene


func _initialize() -> void:
	_run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func make_actor(parent: Node3D, at: Vector3, team: int = 1, health: int = 100) -> CharacterBody3D:
	var actor: CharacterBody3D = actor_script.new()
	actor.faction = team
	actor.max_health = health
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


func tick(count: int = 1) -> void:
	for frame in range(count):
		await physics_frame
		await process_frame


func test_health() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var actor: CharacterBody3D = actor_script.new()
	actor.max_health = 75
	actor.faction = 1
	var health_events: Array[Vector2i] = []
	var deaths: Array[bool] = []
	actor.health_changed.connect(func(current: int, maximum: int): health_events.append(Vector2i(current, maximum)))
	actor.died.connect(func(): deaths.append(true))
	world.add_child(actor)
	expect(actor.current_health == 75 and actor.is_alive(), "La salud inicia en la máxima configurada")
	var initial_events := health_events.size()
	expect(not actor.take_damage(0, 2), "Daño cero se rechaza")
	expect(not actor.take_damage(-30, 2), "Daño negativo se rechaza sin curar")
	expect(not actor.take_damage(20, 1), "La misma facción no causa daño")
	expect(actor.current_health == 75 and health_events.size() == initial_events, "Daño inválido no modifica salud ni emite cambio")
	expect(actor.take_damage(20, 2) and actor.current_health == 55, "Daño hostil resta la cantidad configurada")
	expect(health_events.back() == Vector2i(55, 75), "Cambio de salud informa valor actual y máximo")
	expect(actor.take_damage(1000, 2) and actor.current_health == 0, "Daño letal limita la salud a cero")
	expect(not actor.is_alive() and deaths.size() == 1, "Muerte se emite una vez al llegar a cero")
	expect(not actor.take_damage(10, 2) and deaths.size() == 1, "Un muerto no recibe daño ni duplica muerte")
	expect(health_events.size() == initial_events + 2, "Solo daños efectivos emiten cambios de salud")
	var minimal := make_actor(world, Vector3.ZERO, 2, 0)
	expect(minimal.max_health == 1 and minimal.current_health == 1, "Salud máxima inválida se normaliza a uno")
	var chained := make_actor(world, Vector3.ZERO)
	var chained_deaths: Array[bool] = []
	chained.died.connect(func(): chained_deaths.append(true))
	chained.health_changed.connect(func(current: int, _maximum: int):
		if current == 80:
			chained.take_damage(100, 2)
	)
	chained.take_damage(20, 2)
	expect(chained.current_health == 0 and chained_deaths.size() == 1, "Daño desde una señal tampoco duplica la muerte")
	var resized := make_actor(world, Vector3.ZERO, 1, 120)
	resized.take_damage(30, 2)
	var resize_events: Array[Vector2i] = []
	resized.health_changed.connect(func(current: int, maximum: int): resize_events.append(Vector2i(current, maximum)))
	resized.max_health = 50
	expect(resized.current_health == 50 and resize_events == [Vector2i(50, 50)], "Reducir máximo limita salud y notifica ambos valores")
	resized.max_health = 80
	expect(resized.current_health == 50 and resize_events.back() == Vector2i(50, 80), "Aumentar máximo conserva la salud y notifica el nuevo límite")
	resized.max_health = 0
	expect(resized.max_health == 1 and resized.current_health == 1, "El mínimo de salud máxima también se conserva en runtime")
	resized.take_damage(100, 2)
	resized.max_health = 20
	expect(resized.current_health == 0 and not resized.is_alive(), "Modificar máximo no revive a un actor muerto")
	world.free()


func test_weapon() -> void:
	var world := Node3D.new()
	world.position = Vector3(2, 0, 1)
	root.add_child(world)
	var actor := make_actor(world, Vector3(0, 1.5, 0))
	var projectiles := Node3D.new()
	projectiles.position = Vector3(-3, 0, 4)
	world.add_child(projectiles)
	var weapon: Node3D = weapon_script.new()
	weapon.position = Vector3(0.7, 0, 0.8)
	weapon.damage = 17
	weapon.projectile_speed = 31.0
	weapon.projectile_lifetime = 0.25
	weapon.cooldown = 0.07
	weapon.spawn_distance = 1.25
	actor.add_child(weapon)
	expect(not weapon.try_fire(Vector3.RIGHT) and weapon.cooldown_remaining == 0.0, "Sin contenedor no dispara ni consume recarga")
	weapon.projectile_parent = projectiles
	expect(not weapon.try_fire(Vector3.ZERO) and not weapon.try_fire(Vector3.UP), "Dirección XZ nula se rechaza")
	expect(weapon.cooldown_remaining == 0.0, "Dirección inválida conserva el arma disponible")
	expect(weapon.try_fire(Vector3(3, 9, 0)), "El arma viva dispara con dirección horizontal válida")
	expect(projectiles.get_child_count() == 1, "Un disparo crea un solo proyectil")
	var projectile: Node3D = projectiles.get_child(0)
	expect(projectile.global_position.is_equal_approx(actor.global_position + Vector3(1.25, 0, 0)), "Aparece en coordenadas globales delante del actor")
	expect(projectile.direction.is_equal_approx(Vector3.RIGHT), "La dirección elimina altura y normaliza magnitud")
	expect(projectile.damage == 17 and is_equal_approx(projectile.speed, 31.0) and is_equal_approx(projectile.lifetime, 0.25), "El disparo transmite daño, velocidad y duración configurados")
	expect(projectile.source_faction == 1 and projectile.source_rid == actor.get_rid(), "El disparo conserva facción y RID del emisor")
	expect(not weapon.try_fire(Vector3.RIGHT) and projectiles.get_child_count() == 1, "La recarga impide repetir inmediatamente")
	await tick(2)
	expect(weapon.cooldown_remaining > 0.0 and weapon.cooldown_remaining < 0.07, "La recarga decrece mediante ticks físicos reales")
	expect(not weapon.try_fire(Vector3.RIGHT), "La recarga aún activa rechaza el ataque")
	await tick(8)
	expect(weapon.cooldown_remaining == 0.0 and weapon.try_fire(Vector3.RIGHT), "La recarga acaba en cero y permite otro disparo")
	await tick(8)
	actor.take_damage(100, 2)
	var count_before := projectiles.get_child_count()
	expect(not weapon.try_fire(Vector3.RIGHT) and projectiles.get_child_count() == count_before, "Un emisor muerto no produce ataques nuevos")
	var another_actor := make_actor(world, Vector3(0, 1.5, 4))
	var another_weapon: Node3D = weapon_script.new()
	another_actor.add_child(another_weapon)
	var detached := Node3D.new()
	another_weapon.projectile_parent = detached
	expect(not another_weapon.try_fire(Vector3.RIGHT), "Un contenedor fuera del árbol no admite disparos")
	detached.free()
	expect(not another_weapon.try_fire(Vector3.RIGHT) and another_weapon.cooldown_remaining == 0.0, "Un contenedor eliminado se rechaza sin recarga ni acceso inválido")
	world.free()


func make_projectile(parent: Node3D, at: Vector3, travel_direction: Vector3, damage: int, speed: float, lifetime: float, source_rid: RID = RID()) -> Node3D:
	var projectile: Node3D = projectile_scene.instantiate()
	projectile.position = at
	projectile.direction = travel_direction
	projectile.damage = damage
	projectile.speed = speed
	projectile.lifetime = lifetime
	projectile.source_faction = 1
	projectile.source_rid = source_rid
	parent.add_child(projectile)
	return projectile


func test_muzzle_gap() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var emitter := make_actor(world, Vector3(0, 1.5, 0), 1)
	# La esfera cercana termina en X=1.8, antes del origen visual X=1.9.
	var target := make_actor(world, Vector3(1, 1.5, 0), 2)
	var behind := make_actor(world, Vector3(3, 1.5, 0), 2)
	var projectiles := Node3D.new()
	world.add_child(projectiles)
	var weapon: Node3D = weapon_script.new()
	weapon.spawn_distance = 1.9
	weapon.projectile_parent = projectiles
	emitter.add_child(weapon)
	var impacts: Array[int] = []
	target.health_changed.connect(func(current: int, _maximum: int): impacts.append(current))
	await tick(2)
	expect(weapon.try_fire(Vector3.RIGHT), "El arma dispara aunque haya un hostil entre actor y hocico")
	var projectile: Node3D = projectiles.get_child(0)
	expect(projectile.global_position.is_equal_approx(Vector3(1.9, 1.5, 0)), "El barrido inicial conserva el origen visual configurado")
	await tick(2)
	expect(target.current_health == 80, "El barrido inicial alcanza al hostil anterior al origen visual")
	expect(behind.current_health == 100, "El hostil cercano absorbe el disparo antes del segundo objetivo")
	expect(not is_instance_valid(projectile), "El impacto en el tramo inicial también elimina el proyectil")
	await tick(4)
	expect(impacts.size() == 1 and target.current_health == 80, "El tramo inicial aplica daño una única vez")
	world.free()


func test_swept_collision() -> void:
	var world := Node3D.new()
	root.add_child(world)
	# El emisor tiene otra facción a propósito: su RID debe excluirlo por sí solo.
	var emitter := make_actor(world, Vector3(0, 1.5, 0), 2)
	var ally := make_actor(world, Vector3(2, 1.5, 0), 1)
	var dead := make_actor(world, Vector3(4, 1.5, 0), 2)
	dead.take_damage(100, 1)
	var target := make_actor(world, Vector3(6, 1.5, 0), 2)
	var behind := make_actor(world, Vector3(8, 1.5, 0), 2)
	var impacts: Array[int] = []
	target.health_changed.connect(func(current: int, _maximum: int): impacts.append(current))
	await tick(2)
	# 600 u/s avanza 10 unidades en un tick de 60 Hz: cruza las cinco esferas.
	var projectile := make_projectile(world, emitter.position, Vector3.RIGHT, 27, 600.0, 2.0, emitter.get_rid())
	await tick(2)
	expect(emitter.current_health == 100, "Un barrido que nace dentro del emisor excluye su RID")
	expect(ally.current_health == 100 and dead.current_health == 0, "Aliados y muertos no absorben ni reciben el proyectil")
	expect(target.current_health == 73, "Barrido continuo alcanza al primer hostil incluso a 600 u/s")
	expect(behind.current_health == 100, "El primer impacto impide dañar otro hostil en el mismo tick")
	expect(not is_instance_valid(projectile), "El proyectil se retira después del impacto real")
	await tick(8)
	expect(impacts.size() == 1 and target.current_health == 73, "Un impacto emite y aplica daño una sola vez")
	world.free()


func test_expiry() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var target := make_actor(world, Vector3(2.5, 1.5, 0), 2)
	await tick(2)
	# Dura 0.025 s: solo recorre 1.5 unidades y no alcanza la esfera que empieza en 1.7.
	var projectile := make_projectile(world, Vector3(0, 1.5, 0), Vector3.RIGHT, 50, 60.0, 0.025)
	await tick(4)
	expect(target.current_health == 100, "La fracción final de vida no permite viajar un tick completo adicional")
	expect(not is_instance_valid(projectile), "El proyectil caduca aunque no impacte")
	var stationary := make_projectile(world, Vector3(0, 1.5, 0), Vector3.RIGHT, 50, 0.0, 0.03)
	await tick(4)
	expect(not is_instance_valid(stationary), "Un proyectil inmóvil también caduca y se elimina")
	expect(world.get_child_count() == 1, "No se acumulan proyectiles tras caducar")
	world.free()


func _run() -> void:
	if ResourceLoader.exists("res://scripts/combat_actor.gd"):
		actor_script = load("res://scripts/combat_actor.gd")
	expect(actor_script != null, "Debe existir el actor de combate para recibir daño real")
	if actor_script != null:
		test_health()
		if ResourceLoader.exists("res://scripts/weapon.gd"):
			weapon_script = load("res://scripts/weapon.gd")
		if ResourceLoader.exists("res://scenes/projectile.tscn"):
			projectile_scene = load("res://scenes/projectile.tscn")
		expect(weapon_script != null and projectile_scene != null, "Arma y proyectil deben permitir disparo y colisión reales")
		if weapon_script != null and projectile_scene != null:
			await test_weapon()
			await test_muzzle_gap()
			await test_swept_collision()
			await test_expiry()
	print("T03 núcleo: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)
