extends "res://scripts/arena.gd"

const STARS := "user://estrellas.cfg"
const VILLAGE := Vector3(-8,1.5,8)
const GROVE := Vector3(7,1.5,-7)
var rescued := false
var elder := Node3D.new()
var star_saved := false

func _ready() -> void:
	super._ready()
	player.position = VILLAGE
	enemy.position = GROVE
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color("#435640")
	$Ground.material_override = floor_mat
	$ArenaPresentation.hide()
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color("#45352e")
	var leaves := StandardMaterial3D.new()
	leaves.albedo_color = Color("#365740")
	var tree := CylinderMesh.new()
	tree.top_radius = .28
	tree.bottom_radius = .51
	tree.height = 2.1
	var crown := SphereMesh.new()
	crown.radial_segments = 8
	crown.rings = 4
	for i in 24:
		var angle := TAU*i/24
		var at := Vector3(cos(angle)*12,0,sin(angle)*12)
		_piece(self,tree,bark,at+Vector3.UP,Vector3.ONE)
		_piece(self,crown,leaves,at+Vector3.UP*2.5,Vector3(3,2.8,3))
	add_child(elder)
	elder.position = GROVE
	var robe := CylinderMesh.new()
	robe.top_radius = .24
	robe.bottom_radius = .43
	robe.height = 1.05
	var cloth := StandardMaterial3D.new()
	cloth.albedo_color = Color("#b58559")
	_piece(elder,robe,cloth,Vector3.DOWN*.65,Vector3.ONE)
	_piece(elder,crown,cloth,Vector3.ZERO,Vector3.ONE*.57)
	_mark(elder,"Anciano de Morth",Vector3.UP)
	_mark(self,"Aldea · regreso",VILLAGE+Vector3.UP)
	var saved := ConfigFile.new()
	star_saved = saved.load(STARS)==OK and saved.get_value("MireBog","rescate",false)
	match_finished.connect(_save_star)

func _piece(parent: Node3D,mesh: Mesh,mat: Material,pos: Vector3,dims: Vector3) -> void:
	var item := MeshInstance3D.new()
	item.mesh = mesh
	item.material_override = mat
	item.position = pos
	item.scale = dims
	parent.add_child(item)

func _mark(parent: Node3D,caption: String,pos: Vector3) -> void:
	var tag := Label3D.new()
	tag.text = caption
	tag.position = pos
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.pixel_size = .011
	parent.add_child(tag)

func _victory_ready(delta: float) -> bool:
	if not rescued and not enemy.is_alive() and player.position.distance_to(elder.position)<2.5:
		rescued = true
	if rescued:
		elder.position = elder.position.move_toward(player.position,delta*5.5)
	return rescued and elder.position.distance_to(VILLAGE)<2.2 and player.position.distance_to(VILLAGE)<2.2

func _objective_text() -> String:
	var task := "Derrota al guardián" if enemy.is_alive() else "Acércate al anciano"
	if rescued: task="Escolta al anciano hasta la aldea"
	return "Mire Bog · %s · Estrellas %d/1" % [task,int(star_saved)]

func _save_star(result: int) -> void:
	if result != MatchState.VICTORY: return
	var record := ConfigFile.new()
	record.load(STARS)
	record.set_value("MireBog","rescate",true)
	star_saved = record.save(STARS)==OK
	hud.get_node("ResultPanel/Margin/Content/Hint").text = "Anciano a salvo · 1 estrella guardada" if star_saved else "Anciano a salvo · Falló el guardado"
