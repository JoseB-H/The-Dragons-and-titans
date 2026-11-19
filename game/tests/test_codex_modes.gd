extends SceneTree
var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, msg: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL ",msg)

func ticks(n: int) -> void:
	for i in n: await physics_frame

func run() -> void:
	change_scene_to_file("res://scenes/world_menu.tscn")
	await scene_changed
	var atlas := current_scene
	var codex: AcceptDialog = atlas.find_children("*","AcceptDialog",true,false).back()
	check(codex.DATA.data.Dragones.entries.size()==40 and codex.DATA.data.Armas.entries.size()==35,"Catálogos")
	codex.search.text="Lunaveil"
	codex.refresh()
	check(codex.items.text.contains("Lunaveil") and not codex.items.text.contains("Magmascale"),"Búsqueda")
	atlas.select_mode(6)
	atlas.enter.pressed.emit()
	await scene_changed
	var a := current_scene
	for dragon in a.bots: dragon.set_physics_process(false)
	check(a.owners.count(0)==5 and a.pads.size()==10,"Cinco puntos y cinco portales por base")
	a.player.position=a.POINTS[0]
	await ticks(187)
	check(a.owners[0]==1 and a.guards[0].size()==4,"Captura y cuatro defensas")
	a.player.position=a.base(0)+Vector3.LEFT*2
	a._travel(0)
	check(a.player.position.is_equal_approx(a.POINTS[0]),"Portal aliado")
	a.gold[a.player]=12
	await ticks(2)
	check(a.gold[a.player]==0 and a.xp[a.player]>=12,"Depósito y XP")
	var key:=InputEventKey.new()
	key.physical_keycode=KEY_T
	key.pressed=true
	a._unhandled_input(key)
	a.player.take_damage(1,2)
	check(a.home_time==0,"Daño interrumpe Home")
	a._unhandled_input(key)
	await ticks(160)
	check(a.player.position.distance_to(a.base(0))<5,"Home acaba en base")
	a.teams[1][0].position=a.POINTS[0]
	await ticks(190)
	check(a.owners[0]==1,"Defensas protegen el punto")
	for tower in a.guards[0]: tower.take_damage(1000,2)
	a._respawn(a.teams[1][0])
	a.teams[1][0].position=a.POINTS[0]
	await ticks(380)
	check(a.owners[0]==2 and a.guards[0].size()==4,"Reconquista")
	a.home_core.current_health=1
	await ticks(195)
	check(a.state==2,"Desgaste resuelve la partida")
	change_scene_to_file("res://scenes/aram_lobby.tscn")
	await scene_changed
	var first: StringName=current_scene.chosen
	current_scene.reroll.pressed.emit()
	check(current_scene.chosen!=first and current_scene.reroll.disabled,"Un nuevo sorteo")
	for btn in current_scene.find_children("*","Button",true,false):
		if btn.text=="Entrar en Halvalas":
			btn.pressed.emit()
			break
	await scene_changed
	a=current_scene
	check(a.bots.size()==9 and a.player.uses_mana,"ARAM 5v5")
	a._spawn_wave()
	check(a.constructs.size()==2 and a.constructs.all(func(u): return u.lane==1),"Carril único")
	var unit: Node3D=a.constructs[1]
	unit.take_damage(1000,1)
	check(a.bank[0]==10 and a.potions.size()==1,"Oro automático y poción")
	a.bank[0]=75
	await ticks(2)
	check(a.bank[0]==0 and a.bolts.size()==1,"Balista")
	var bolt: Dictionary=a.bolts[0]
	a.enemy.position=bolt.shot.position+Vector3.RIGHT
	var hp:int=a.enemy.current_health
	await ticks(2)
	check(a.enemy.current_health<hp,"Daño en trayectoria")
	change_scene_to_file("res://scenes/classic_moba.tscn")
	await scene_changed
	a=current_scene
	check(a.structures[0].size()==6 and a.hoards[1].size()==3,"Estructuras y tesoros MOBA")
	a.defenses[1][0].take_damage(1000,1)
	check(not a.structures[1][1].shielded and not a.structures[1][4].shielded and a.rival_core.shielded,"Escudos regionales")
	a.player.position=a.hoards[0][0]
	a.wallets[a.player]=60
	await ticks(3)
	check(a.player.hoard_protection and a.wallets[a.player]==0 and is_instance_valid(a.chaos),"Tesoro e invocación")
	for tower in a.defenses[1]: tower.take_damage(1000,1)
	for obj in a.structures[1]: obj.take_damage(1000,1)
	check(not a.rival_core.shielded,"Jaula vulnerable tras seis objetivos")
	change_scene_to_file("res://scenes/mire_bog.tscn")
	await scene_changed
	a=current_scene
	a.enemy.take_damage(1000,1)
	a.player.position=a.GROVE
	await ticks(3)
	check(a.rescued and a.state==0,"Rescate del anciano")
	a.player.position=a.VILLAGE
	await ticks(330)
	check(a.state==1 and a.star_saved,"Escolta y estrella")
	print("Códice y modos: %d pruebas, %d fallos" % [checks,failures])
	quit(int(failures>0))
