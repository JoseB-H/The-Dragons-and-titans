extends SceneTree
var output_dir := ""
var frames := 0
var dialog: ConfirmationDialog
var header: PanelContainer
func _initialize() -> void:
	_setup.call_deferred()
func _setup() -> void:
	output_dir = OS.get_cmdline_user_args()[0] if not OS.get_cmdline_user_args().is_empty() else ProjectSettings.globalize_path("res://../builds/visual-review")
	DirAccess.make_dir_recursive_absolute(output_dir)
	root.gui_embed_subwindows = true
	var scene := Node3D.new()
	root.add_child(scene)
	var landscape: Node3D = load("res://scripts/nether_landscape.gd").new()
	landscape.points = [Vector3(-12,1.5,-15),Vector3(0,1.5,0),Vector3(12,1.5,15)]
	scene.add_child(landscape)
	landscape.show_rune(0,1,1)
	landscape.show_rune(2,2,1)
	assert(landscape.lintels.size() == 2)
	assert(landscape.rings.size() == 3)
	assert(landscape.signs.size() == 3)
	print("LANDSCAPE_CONTRACT_OK")
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48,-28,0)
	sun.light_energy = 1.5
	scene.add_child(sun)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("#1c2b34")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("#9bb0ba")
	environment.environment.ambient_light_energy = .6
	scene.add_child(environment)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 43
	camera.position = Vector3(-11,32,38)
	scene.add_child(camera)
	camera.look_at(Vector3(-15,-2,0))
	camera.current = true
	var layer := CanvasLayer.new()
	root.add_child(layer)
	header = PanelContainer.new()
	header.theme = preload("res://scripts/fantasy_theme.gd").create()
	header.position = Vector2(26,24)
	layer.add_child(header)
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation",18)
	header.add_child(header_row)
	var heading := Label.new()
	heading.text = "NETHERGATE  /  Atlas de los reinos"
	heading.add_theme_font_size_override("font_size",24)
	header_row.add_child(heading)
	dialog = ConfirmationDialog.new()
	dialog.theme = header.theme
	dialog.title = "Preparar el vuelo"
	dialog.dialog_text = "NETHERGATE\n\nDomina las runas y escolta al titán hasta la puerta rival.\n\nDragón: Cobre   ·   Arma: Ascua"
	dialog.ok_button_text = "Iniciar vuelo"
	dialog.cancel_button_text = "Volver al atlas"
	root.add_child(dialog)
	var icon := TextureRect.new()
	icon.texture = load("res://assets/third_party/game-icons/dragon-head.svg")
	icon.custom_minimum_size = Vector2(48,48)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.modulate = Color("#dfbd73")
	header_row.add_child(icon)
func _process(_delta: float) -> bool:
	frames += 1
	if frames == 118:
		header.hide()
	if frames == 120:
		root.get_texture().get_image().save_png(output_dir+"/nethergate-preview.png")
		print("CAPTURE_OK")
	if frames == 125:
		header.show()
	if frames == 150:
		dialog.popup_centered(Vector2i(620,290))
	if frames == 210:
		root.get_texture().get_image().save_png(output_dir+"/nethergate-window.png")
		print("DIALOG_CAPTURE_OK")
		quit()
	return false
