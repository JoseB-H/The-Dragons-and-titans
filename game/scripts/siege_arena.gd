extends "res://scripts/arena.gd"

const TacticalHud := preload("res://scripts/siege_hud.gd")
const SiegeTower := preload("res://scripts/siege_tower.gd")

@onready var ally: Node3D = $Ally
@onready var raider: Node3D = $Raider
@onready var home_core: Node3D = $HomeCore
@onready var rival_core: Node3D = $RivalCore
@onready var home_tower: SiegeTower = $HomeTower
@onready var rival_tower: SiegeTower = $RivalTower
@onready var bots: Array[Node3D] = [ally, enemy, raider]

var _tactical_hud: Control
var elapsed := 0.0


func _ready() -> void:
	super._ready()
	$Sun.shadow_enabled = true
	$Sun.directional_shadow_max_distance = 48.0
	for bot in bots:
		bot.weapon.projectile_parent = $Projectiles
		bot.weapon.luminous_trail = true
		bot.weapon.projectile_tint = Color(0.36, 0.86, 1.0) if bot == ally else Color(1.0, 0.48, 0.2)
	home_tower.died.connect(home_core.drop_shield)
	rival_tower.died.connect(rival_core.drop_shield)
	for tower in [home_tower, rival_tower]:
		tower.weapon.projectile_parent = $Projectiles
		tower.weapon.luminous_trail = true
		tower.weapon.projectile_tint = tower.team_color
	player.get_node("Weapon").luminous_trail = true
	player.get_node("PowerWeapon").luminous_trail = true
	player.get_node("PowerWeapon").projectile_tint = Color(1.0, 0.76, 0.26)
	for dragon in [player, ally, enemy, raider]:
		dragon.get_node("Facing").bank_enabled = true
	player.get_node("Camera").size *= 1.14
	hud.get_node("Panel").hide()
	_tactical_hud = _create_tactical_hud()
	_tactical_hud.setup(self)
	# El resultado conserva foco y se dibuja por encima del HUD táctico.
	hud.add_child(_tactical_hud)
	hud.move_child(_tactical_hud, 0)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if state != MatchState.PLAYING or _restart_pending:
		return
	elapsed += delta
	var home_objective := home_tower if home_tower.is_alive() else home_core
	var rival_objective := rival_tower if rival_tower.is_alive() else rival_core
	ally.target = _pick_target(ally, enemy, raider, rival_objective)
	enemy.target = _pick_target(enemy, player, ally, home_objective)
	raider.target = _pick_target(raider, ally, player, home_objective)
	home_tower.defend([enemy, raider])
	rival_tower.defend([player, ally])


func _pick_target(bot: Node3D, first: Node3D, second: Node3D, core: Node3D) -> Node3D:
	var nearest := core
	var best_distance := 6.2 * 6.2
	for opponent in [first, second]:
		var distance := bot.global_position.distance_squared_to(opponent.global_position)
		if opponent.can_act() and distance < best_distance:
			best_distance = distance
			nearest = opponent
	return nearest


func _defeat_ready() -> bool:
	return not player.is_alive() or not home_core.is_alive()


func _victory_ready(_delta: float) -> bool:
	return not rival_core.is_alive()


func _match_actors() -> Array[Node3D]:
	return [player, ally, enemy, raider, home_core, rival_core, home_tower, rival_tower]


func _update_hud() -> void:
	hud.update_view("", state)
	if is_instance_valid(_tactical_hud):
		_tactical_hud.queue_redraw()


func _create_tactical_hud() -> Control:
	return TacticalHud.new()
