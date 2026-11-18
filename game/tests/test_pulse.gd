extends SceneTree
## Pulso E real: centros XZ, facciones, recarga y VFX sin daño periódico.

var checks := 0
var failures := 0
var actor_script: Script
var pulse_script: Script
var effect_scene: PackedScene


func _initialize() -> void:
	_run.call_deferred()


func expect(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: ", description)


func ticks(count: int) -> void:
	for frame in range(count):
		await physics_frame
		await process_frame


func make_actor(parent: Node3D, at: Vector3, team: int = 2) -> CharacterBody3D:
	var actor: CharacterBody3D = actor_script.new()
	actor.position = at
	actor.faction = team
	actor.collision_layer = 1
	actor.collision_mask = 0
	var collider := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.8
	collider.shape = sphere
	actor.add_child(collider)
	parent.add_child(actor)
	# Explícito para que el núcleo pueda probarse antes de integrar Arena.
	actor.add_to_group("combat_actors")
	return actor


func fixture() -> Dictionary:
	var world := Node3D.new()
	root.add_child(world)
	var actor := make_actor(world, Vector3(2, 1.5, -3), 1)
	var effects := Node3D.new()
	world.add_child(effects)
	var pulse: Node3D = pulse_script.new()
	pulse.effects_parent = effects
	actor.add_child(pulse)
	return {"world": world, "actor": actor, "effects": effects, "pulse": pulse}


func test_targets() -> void:
	var f := fixture()
	var world: Node3D = f.world
	var actor: CharacterBody3D = f.actor
	var pulse: Node3D = f.pulse
	# Desplazar el nodo de habilidad no desplaza el centro de daño.
	pulse.position = Vector3(20, 8, 20)
	var near := make_actor(world, Vector3(3, 1.5, -3))
	var diagonal := make_actor(world, Vector3(4, 1.5, -5))
	var boundary := make_actor(world, Vector3(6, 1.5, -3))
	var high := make_actor(world, Vector3(2, 100, -6))
	var low := make_actor(world, Vector3(2, -100, -3))
	var outside := make_actor(world, Vector3(6.001, 1.5, -3))
	var touching_collider := make_actor(world, Vector3(6.5, 1.5, -3))
	var ally := make_actor(world, Vector3(3, 1.5, -4), 1)
	var dead := make_actor(world, Vector3(2, 1.5, -4))
	dead.take_damage(100, 1)
	var emissions: Array[int] = []
	for target in [near, diagonal, boundary, high, low]:
		target.health_changed.connect(func(current: int, _maximum: int): emissions.append(current))
	expect(pulse.try_activate(), "E admite varios hostiles con una activación")
	expect(near.current_health == 70 and diagonal.current_health == 70, "Cada hostil interior recibe 30 de daño instantáneo")
	expect(boundary.current_health == 70, "La frontera exacta de radio 4 es inclusiva")
	expect(high.current_health == 70 and low.current_health == 70, "El radio usa solo centros XZ e ignora altura")
	expect(outside.current_health == 100, "Un centro a 4.001 queda fuera del pulso")
	expect(touching_collider.current_health == 100, "El collider dentro del radio no sustituye la distancia entre centros")
	expect(actor.current_health == 100 and ally.current_health == 100 and dead.current_health == 0, "E ignora emisor, aliados y muertos")
	expect(emissions.size() == 5, "Cada hostil válido emite un único cambio de salud antes de retornar")
	expect(f.effects.get_child_count() == 1, "Una activación crea un solo efecto")
	await ticks(8)
	expect(emissions.size() == 5 and near.current_health == 70, "La permanencia del efecto no repite daño")
	expect(f.effects.get_child_count() == 1, "El VFX aún existe antes de terminar su duración")
	world.free()


func test_invalid_targets() -> void:
	var f := fixture()
	var world: Node3D = f.world
	var queued := make_actor(world, Vector3(2, 1.5, -3))
	queued.queue_free()
	var detached := make_actor(world, Vector3(2, 1.5, -3))
	world.remove_child(detached)
	var freed := make_actor(world, Vector3(2, 1.5, -3))
	freed.free()
	var non_spatial := Node.new()
	world.add_child(non_spatial)
	non_spatial.add_to_group("combat_actors")
	var unrelated := Node3D.new()
	world.add_child(unrelated)
	unrelated.add_to_group("combat_actors")
	var unregistered := make_actor(world, Vector3(2, 1.5, -3))
	unregistered.remove_from_group("combat_actors")
	var valid := make_actor(world, Vector3(2, 1.5, -3))
	expect(f.pulse.try_activate(), "Candidatos inválidos no impiden procesar un hostil válido")
	expect(queued.current_health == 100 and detached.current_health == 100, "Objetivos encolados o retirados no reciben daño")
	expect(unregistered.current_health == 100 and valid.current_health == 70, "Solo actores registrados y válidos reciben el pulso")
	detached.free()
	world.free()


func test_configuration_and_gates() -> void:
	# Cada mutación detecta una guardia omitida sin consumir CD ni crear VFX.
	var invalid_values := [
		["damage", 0], ["damage", -1],
		["radius", 0.0], ["radius", -1.0], ["radius", INF], ["radius", NAN],
		["cooldown", -1.0], ["cooldown", INF], ["cooldown", NAN],
		["effect_duration", 0.0], ["effect_duration", -1.0],
		["effect_duration", INF], ["effect_duration", NAN]
	]
	for invalid in invalid_values:
		var f := fixture()
		var target := make_actor(f.world, Vector3(2, 1.5, -3))
		f.pulse.set(invalid[0], invalid[1])
		expect(not f.pulse.try_activate(), "Configuración inválida rechazada: %s=%s" % [invalid[0], invalid[1]])
		expect(f.pulse.cooldown_remaining == 0.0 and f.effects.get_child_count() == 0 and target.current_health == 100, "Configuración inválida conserva recarga, salud y contenedor")
		f.world.free()
	var f := fixture()
	f.pulse.effects_parent = null
	expect(not f.pulse.try_activate() and f.pulse.cooldown_remaining == 0.0, "Sin contenedor se rechaza sin consumir recarga")
	var detached_parent := Node3D.new()
	f.pulse.effects_parent = detached_parent
	expect(not f.pulse.try_activate() and detached_parent.get_child_count() == 0, "Contenedor retirado no admite VFX")
	detached_parent.free()
	expect(not f.pulse.try_activate() and f.pulse.cooldown_remaining == 0.0, "Contenedor eliminado se rechaza sin acceso inválido")
	f.pulse.effects_parent = f.effects
	f.effects.queue_free()
	expect(not f.pulse.try_activate() and f.pulse.cooldown_remaining == 0.0 and f.effects.get_child_count() == 0, "Contenedor encolado no recibe efectos ni consume recarga")
	f.world.free()
	f = fixture()
	f.actor.take_damage(100, 2)
	expect(not f.pulse.try_activate() and f.pulse.cooldown_remaining == 0.0 and f.effects.get_child_count() == 0, "Emisor muerto no activa ni consume recarga")
	f.world.free()
	f = fixture()
	f.actor.queue_free()
	expect(not f.pulse.try_activate() and f.pulse.cooldown_remaining == 0.0 and f.effects.get_child_count() == 0, "Emisor encolado no activa ni consume recarga")
	f.world.free()
	f = fixture()
	f.pulse.queue_free()
	expect(not f.pulse.try_activate() and f.pulse.cooldown_remaining == 0.0 and f.effects.get_child_count() == 0, "Habilidad encolada no activa ni consume recarga")
	f.world.free()
	f = fixture()
	f.world.remove_child(f.actor)
	expect(not f.pulse.try_activate() and f.pulse.cooldown_remaining == 0.0 and f.effects.get_child_count() == 0, "Emisor fuera del árbol no activa ni consume recarga")
	f.actor.free()
	f.world.free()
	f = fixture()
	f.actor.remove_child(f.pulse)
	f.world.add_child(f.pulse)
	expect(not f.pulse.try_activate() and f.pulse.cooldown_remaining == 0.0 and f.effects.get_child_count() == 0, "Habilidad sin padre CombatActor no activa ni consume recarga")
	f.world.free()


func test_cooldown_and_empty_cast() -> void:
	var f := fixture()
	f.pulse.cooldown = 0.10
	f.pulse.effect_duration = 0.04
	expect(f.pulse.try_activate(), "E sin hostiles es una activación válida")
	expect(is_equal_approx(f.pulse.cooldown_remaining, 0.10) and f.effects.get_child_count() == 1, "E vacío consume su recarga y crea VFX")
	var before: float = f.pulse.cooldown_remaining
	expect(not f.pulse.try_activate() and f.pulse.cooldown_remaining == before and f.effects.get_child_count() == 1, "Durante recarga el rechazo no reinicia CD ni crea otro VFX")
	await ticks(2)
	expect(f.pulse.cooldown_remaining > 0.0 and f.pulse.cooldown_remaining < 0.10, "La recarga decrece mediante física real")
	await ticks(10)
	expect(f.pulse.cooldown_remaining == 0.0 and f.effects.get_child_count() == 0, "Recarga llega exactamente a cero y el VFX caduca")
	expect(f.pulse.try_activate(), "E vuelve a activarse al terminar recarga")
	await ticks(10)
	expect(f.effects.get_child_count() == 0, "Activaciones repetidas no acumulan efectos caducados")
	f.pulse.cooldown = 0.0
	expect(f.pulse.try_activate() and f.pulse.cooldown_remaining == 0.0, "Recarga cero permite activaciones discretas sin tiempo de espera")
	f.world.free()


func test_visual_and_expiry() -> void:
	var f := fixture()
	f.effects.position = Vector3(8, -3, 7)
	f.effects.rotation = Vector3(0.4, 0.7, 0.1)
	f.effects.scale = Vector3(2, 3, 4)
	f.pulse.radius = 2.75
	f.pulse.effect_duration = 0.15
	expect(f.pulse.try_activate(), "Pulso acepta radio y duración configurados")
	var effect: Node3D = f.effects.get_child(0)
	expect(effect.global_position.is_equal_approx(Vector3(2, 1.5, -3)), "El anillo aparece centrado en el actor a su altura de vuelo")
	expect(effect.global_basis.is_equal_approx(Basis.IDENTITY), "Transformar Effects no distorsiona el radio visual global")
	expect(is_equal_approx(effect.radius, 2.75) and is_equal_approx(effect.lifetime, 0.15), "Radio y duración llegan antes de inicializar el VFX")
	var visual := effect.get_node_or_null("Visual") as MeshInstance3D
	expect(visual != null and visual.mesh is TorusMesh, "VFX usa un anillo propio de geometría Godot")
	if visual != null and visual.mesh is TorusMesh:
		var torus := visual.mesh as TorusMesh
		expect(is_equal_approx(torus.outer_radius, 2.75), "El borde exterior visual coincide con el radio de daño")
		var material := torus.material as StandardMaterial3D
		expect(material != null and material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED, "El material permanece visible sin depender de iluminación")
		expect(material != null and material.albedo_color.g > material.albedo_color.r and material.albedo_color.b > material.albedo_color.r, "El anillo es cian verde y distinguible del disparo básico")
	await ticks(3)
	expect(is_instance_valid(effect), "El VFX conserva la duración exportada sin desaparecer en el primer tick")
	await ticks(12)
	expect(not is_instance_valid(effect) and f.effects.get_child_count() == 0, "El VFX se elimina al agotar su duración")
	# Instanciar el VFX por sí solo no tiene autoridad de daño.
	var target := make_actor(f.world, Vector3(2, 1.5, -3))
	var standalone: Node3D = effect_scene.instantiate()
	standalone.lifetime = 0.03
	f.effects.add_child(standalone)
	await ticks(5)
	expect(target.current_health == 100 and not is_instance_valid(standalone), "El efecto independiente caduca sin aplicar daño")
	f.world.free()


func test_reentrant_damage() -> void:
	var f := fixture()
	var first := make_actor(f.world, Vector3(2, 1.5, -3))
	var second := make_actor(f.world, Vector3(3, 1.5, -3))
	var reentrant_results: Array[bool] = []
	first.health_changed.connect(func(_current: int, _maximum: int): reentrant_results.append(f.pulse.try_activate()))
	expect(f.pulse.try_activate(), "Pulso externo se activa aunque un callback intente repetirlo")
	expect(reentrant_results == [false] and first.current_health == 70 and second.current_health == 70, "La reserva de recarga bloquea activación reentrante y daño duplicado")
	expect(f.effects.get_child_count() == 1, "Callback reentrante no crea un segundo VFX")
	f.world.free()
	f = fixture()
	f.pulse.cooldown = 0.0
	first = make_actor(f.world, Vector3(2, 1.5, -3))
	var zero_results: Array[bool] = []
	first.health_changed.connect(func(_current: int, _maximum: int): zero_results.append(f.pulse.try_activate()))
	expect(f.pulse.try_activate() and zero_results == [false] and first.current_health == 70, "Recarga cero también bloquea reentrada durante la misma descarga")
	f.world.free()


func test_candidates_changed_by_callback() -> void:
	var f := fixture()
	var first := make_actor(f.world, Vector3(2, 1.5, -3))
	var queued := make_actor(f.world, Vector3(2, 1.5, -3))
	var detached := make_actor(f.world, Vector3(2, 1.5, -3))
	var freed := make_actor(f.world, Vector3(2, 1.5, -3))
	var ally := make_actor(f.world, Vector3(2, 1.5, -3))
	var killed := make_actor(f.world, Vector3(2, 1.5, -3))
	var moved := make_actor(f.world, Vector3(2, 1.5, -3))
	var remaining := make_actor(f.world, Vector3(2, 1.5, -3))
	first.health_changed.connect(func(_current: int, _maximum: int):
		queued.queue_free()
		f.world.remove_child(detached)
		freed.free()
		ally.faction = 1
		killed.take_damage(100, 1)
		moved.position.x = 50
	)
	expect(f.pulse.try_activate(), "Un callback puede cambiar los siguientes candidatos sin romper la activación")
	expect(queued.current_health == 100 and detached.current_health == 100 and not is_instance_valid(freed), "Revalidar cada objetivo evita daño a encolados, retirados o liberados por callback")
	expect(ally.current_health == 100 and killed.current_health == 0 and moved.current_health == 100, "Revalidar facción, salud y posición usa el estado vigente de cada objetivo")
	expect(remaining.current_health == 70, "Un candidato aún válido recibe exactamente un daño tras callbacks anteriores")
	detached.free()
	f.world.free()


func _run() -> void:
	actor_script = load("res://scripts/combat_actor.gd")
	if ResourceLoader.exists("res://scripts/pulse_ability.gd"):
		pulse_script = load("res://scripts/pulse_ability.gd")
	if ResourceLoader.exists("res://scenes/pulse_effect.tscn"):
		effect_scene = load("res://scenes/pulse_effect.tscn")
	expect(pulse_script != null, "Debe existir PulseAbility para activar daño de área real")
	expect(effect_scene != null, "Debe existir el efecto temporal propio del pulso")
	if pulse_script != null and effect_scene != null:
		await test_targets()
		test_invalid_targets()
		test_configuration_and_gates()
		await test_cooldown_and_empty_cast()
		await test_visual_and_expiry()
		test_reentrant_damage()
		test_candidates_changed_by_callback()
	print("T04 pulso: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)
