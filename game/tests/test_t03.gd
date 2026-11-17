extends SceneTree
## Integración de escena T03: entrada, IA, muerte y tres restauraciones reales.

var checks := 0
var failures := 0


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


func clear_projectiles(arena: Node) -> void:
	for projectile in arena.get_node("Projectiles").get_children():
		projectile.queue_free()
	await ticks(2)


func _run() -> void:
	var arena: Node3D = load("res://scenes/arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	var enemy: Node3D = arena.get_node_or_null("Enemy")
	expect(enemy != null, "T03 añade enemigo a la arena T02 conservada")
	if enemy == null:
		arena.free()
		quit(1)
		return
	var player: Node3D = arena.get_node("Dragon")
	var weapon: Node = player.get_node("Weapon")
	var enemy_weapon: Node = enemy.get_node("Weapon")
	var shots: Node = arena.get_node("Projectiles")
	enemy.set_physics_process(false)
	player.set_physics_process(false)
	await ticks(2)
	expect(player.current_health == 100 and enemy.current_health == 80, "Salud inicial jugador/enemigo")
	expect(player.faction != enemy.faction, "Facciones rivales")
	expect(enemy.target == player, "Arena asigna jugador como objetivo")

	# El clic usa el Facing conservado de T02 y respeta recarga.
	player.get_node("Facing").look_at(enemy.global_position, Vector3.UP)
	Input.action_press("attack")
	player._physics_process(0.0)
	Input.action_release("attack")
	expect(shots.get_child_count() == 1, "Entrada de ataque genera un solo proyectil")
	if shots.get_child_count() == 1:
		expect(shots.get_child(0).direction.dot(Vector3.FORWARD) > 0.999, "Disparo sale hacia hocico -Z")
	expect(not weapon.try_fire(Vector3.FORWARD), "Recarga bloquea el segundo ataque")
	await ticks(20)
	expect(enemy.current_health == 60, "Proyectil de escena causa 20 de daño una vez")
	expect(player.current_health == 100, "Proyectil no daña a su emisor")
	expect(shots.get_child_count() == 0, "Impacto retira proyectil de la escena")
	await ticks(10)
	expect(weapon.try_fire(Vector3.RIGHT), "Arma disponible al finalizar intervalo")
	expect(shots.get_child(0).direction.dot(Vector3.RIGHT) > 0.999, "Arma conserva dirección solicitada")
	await clear_projectiles(arena)

	# Persecución en física real y alcance: sin ataque fuera de rango.
	enemy.position = Vector3(0, 1.5, -10)
	enemy.reset_physics_interpolation()
	enemy.set_physics_process(true)
	var before_distance := enemy.position.distance_to(player.position)
	await ticks(12)
	expect(enemy.position.distance_to(player.position) < before_distance, "Enemigo persigue en pasos físicos reales")
	expect(shots.get_child_count() == 0, "No ataca fuera de rango")
	enemy.set_physics_process(false)
	enemy.position = Vector3(0, 1.5, -6)
	enemy_weapon.cooldown_remaining = 0.0
	enemy._physics_process(0.0)
	expect(shots.get_child_count() == 1, "Entra en rango y ataca")
	enemy._physics_process(0.0)
	expect(shots.get_child_count() == 1, "Recarga enemiga impide ataque duplicado")
	await ticks(20)
	expect(player.current_health == 90, "Ataque enemigo impacta con daño configurable")
	await clear_projectiles(arena)
	player.position = Vector3(0, 1.5, 10)
	enemy_weapon.cooldown_remaining = 0.0
	enemy._physics_process(0.0)
	expect(shots.get_child_count() == 0, "Salir de rango bloquea nuevos ataques")
	enemy.position = Vector3(100, -20, -100)
	enemy._physics_process(0.0)
	expect(absf(enemy.position.x) <= 10.0 and absf(enemy.position.z) <= 10.0 and is_equal_approx(enemy.position.y, 1.5), "Enemigo respeta límites y altura")

	# Objetivo muerto/propio actor muerto: ni persecución ni disparos nuevos.
	player.take_damage(1000, enemy.faction)
	var stopped := enemy.position
	enemy_weapon.cooldown_remaining = 0.0
	enemy._physics_process(1.0)
	expect(enemy.position.is_equal_approx(stopped) and shots.get_child_count() == 0, "Enemigo se detiene cuando muere objetivo")
	var player_stopped := player.position
	Input.action_press("move_forward")
	Input.action_press("attack")
	player._physics_process(1.0)
	Input.action_release("move_forward")
	Input.action_release("attack")
	expect(player.position.is_equal_approx(player_stopped), "Jugador muerto no se mueve")
	expect(not weapon.try_fire(Vector3.FORWARD) and shots.get_child_count() == 0, "Jugador muerto no dispara")
	enemy.take_damage(1000, player.faction)
	expect(not enemy_weapon.try_fire(Vector3.BACK), "Enemigo muerto no dispara")

	# Reload de la escena real tres veces, no una simulación de restauración.
	for iteration in range(3):
		if not player.is_alive():
			arena.restore_arena()
			await scene_changed
			arena = current_scene
			player = arena.get_node("Dragon")
			enemy = arena.get_node("Enemy")
			enemy.set_physics_process(false)
		player.take_damage(10, enemy.faction)
		enemy.take_damage(10, player.faction)
		player.position = Vector3(3, 1.5, 4)
		enemy.position = Vector3(-3, 1.5, -4)
		weapon = player.get_node("Weapon")
		weapon.cooldown_remaining = 0.0
		expect(weapon.try_fire(Vector3.RIGHT), "Crear estado sucio antes de restauración")
		var old_player: WeakRef = weakref(player)
		var old_projectile: WeakRef = weakref(arena.get_node("Projectiles").get_child(0))
		expect(arena.restore_arena() == OK, "Restauración %d aceptada" % (iteration + 1))
		await scene_changed
		arena = current_scene
		player = arena.get_node("Dragon")
		enemy = arena.get_node("Enemy")
		enemy.set_physics_process(false)
		expect(player.current_health == 100 and enemy.current_health == 80, "Restauración recupera toda la salud")
		expect(player.position.is_equal_approx(Vector3(0, 1.5, 0)) and enemy.position.is_equal_approx(Vector3(0, 1.5, -7)), "Restauración recupera posiciones")
		expect(player.get_node("Weapon").cooldown_remaining == 0.0 and enemy.get_node("Weapon").cooldown_remaining == 0.0, "Restauración borra recargas")
		expect(arena.get_node("Projectiles").get_child_count() == 0 and old_projectile.get_ref() == null, "Restauración elimina proyectiles antiguos")
		expect(old_player.get_ref() == null and arena.find_children("*", "CharacterBody3D", true, false).size() == 2, "Sin actores duplicados ni actores anteriores")
		expect(player.get_signal_connection_list("died").is_empty() and enemy.get_signal_connection_list("died").is_empty(), "Sin conexiones heredadas en actores nuevos")
	await process_frame
	var hud: Label = arena.get_node("Controls/Panel/Margin/Label")
	expect(hud.text.contains("100 / 100") and hud.text.contains("80 / 80"), "HUD muestra salud restaurada de ambos actores")
	var stopped_enemy := enemy.position
	enemy.target = null
	enemy._physics_process(1.0)
	expect(enemy.position.is_equal_approx(stopped_enemy) and arena.get_node("Projectiles").get_child_count() == 0, "Objetivo nulo detiene IA sin errores")
	enemy.target = player
	enemy.faction = player.faction
	enemy._physics_process(1.0)
	expect(enemy.position.is_equal_approx(stopped_enemy) and arena.get_node("Projectiles").get_child_count() == 0, "Objetivo aliado no se persigue ni ataca")
	enemy.faction = 2
	arena.remove_child(player)
	enemy._physics_process(0.1)
	expect(enemy.position.is_equal_approx(stopped_enemy) and arena.get_node("Projectiles").get_child_count() == 0, "Objetivo vivo fuera del árbol no se persigue ni ataca")
	arena.add_child(player)
	await clear_projectiles(arena)
	enemy.take_damage(1000, player.faction)
	enemy._physics_process(1.0)
	expect(enemy.position.is_equal_approx(stopped_enemy) and arena.get_node("Projectiles").get_child_count() == 0, "Enemigo muerto no se mueve con jugador vivo")
	arena.free()
	print("T03 integración: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)
