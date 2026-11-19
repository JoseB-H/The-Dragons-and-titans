extends SceneTree
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func expect(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		printerr(label)

func run() -> void:
	change_scene_to_file("res://scenes/world_menu.tscn")
	await scene_changed
	var atlas = current_scene
	atlas.select_mode(atlas.MODES.find_custom(func(mode): return mode[3]=="proving_grounds"))
	atlas.enter.pressed.emit()
	var setup = atlas.find_children("*","ConfirmationDialog",false,false).back()
	setup.confirmed.emit()
	await scene_changed
	var game = current_scene
	expect(game.phase==game.Phase.FLIGHT,"Inicio PvE")
	expect(not game.cage.take_damage(500,1) and not game.shrine.take_damage(500,1),"Escudos iniciales")
	game._physics_process(1.7)
	game.player.take_damage(1000,2)
	game._physics_process(3.1)
	expect(game.player.is_alive() and game.player.position==game.BASE,"Reaparición")
	game.player.position = game.OBELISK
	game._physics_process(.01)
	expect(game.minions.size()==3,"Defensa")
	for unit in game.minions:
		unit.take_damage(1000,1)
	game._physics_process(.01)
	expect(game.phase==game.Phase.BANK and game.purse==25,"Oro con tope")
	game.player.position=game.BANK
	game._physics_process(.01)
	game.upgrade.pressed.emit()
	expect(game.purse==0 and game.points==0 and game.rival.can_act(),"Depósito y mejora")
	game.rival.take_damage(1000,1)
	game.towers[0].take_damage(1000,1)
	game._physics_process(.01)
	expect(game.shrine.shielded,"Una torre sigue en pie")
	game.towers[1].take_damage(1000,1)
	game._physics_process(.01)
	game.shrine.take_damage(1000,1)
	expect(not game.cage.shielded,"Jaula expuesta")
	game.cage.take_damage(1000,1)
	expect(game.phase==game.Phase.WON,"Victoria")
	var roster = root.get_node("DragonRoster")
	expect(roster.training_record().get_value("mission","proven",false),"Logro persistente")
	expect(roster.buy_training_trail()==OK and roster.buy_training_trail()==ERR_UNAVAILABLE,"Compra única")
	roster.award_training()
	expect(roster.training_record().get_value("mission","crystals",-1)==0,"Evitar recompensa duplicada")
	change_scene_to_file("res://scenes/proving_grounds.tscn")
	await scene_changed
	expect(current_scene.player.weapon.luminous_trail,"Estela equipada")
	current_scene.obelisk.take_damage(1000,2)
	expect(current_scene.phase==current_scene.Phase.LOST,"Derrota")
	print("Proving Grounds: ", failures," fallos")
	quit(1 if failures else 0)
