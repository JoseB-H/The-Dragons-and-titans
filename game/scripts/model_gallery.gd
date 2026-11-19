extends Node3D
## Visor de los mismos GLB que usa la partida. Nunca altera la selección de combate.
const ASSETS := preload("res://scripts/dragon_presentation.gd").MODELS
var model: Node3D
var animation: AnimationPlayer
var camera: Camera3D
var info: Label
var angle := -0.55
var distance := 7.0
var chosen: StringName = &"cobre"
var clip: StringName = &"Flight"
var dragging := false
var navigating := false

func _ready() -> void:
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color(0.025,0.038,0.055)
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color(0.55,0.68,0.84)
	settings.ambient_light_energy = 0.65
	environment.environment = settings
	add_child(environment)
	for spec in [[Vector3(-0.8,-0.6,0), Color(1,0.88,0.71),1.4], [Vector3(-0.3,2.3,0),Color(0.37,0.65,1),0.8]]:
		var light := DirectionalLight3D.new()
		light.rotation = spec[0]
		light.light_color = spec[1]
		light.light_energy = spec[2]
		add_child(light)
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 42
	add_child(camera)
	var layer := CanvasLayer.new()
	add_child(layer)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",24)
	margin.add_theme_constant_override("margin_top",18)
	margin.add_theme_constant_override("margin_right",24)
	margin.add_theme_constant_override("margin_bottom",18)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(margin)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(column)
	var title := Label.new()
	title.text = "DRAGONES  /  GALERÍA 3D"
	title.add_theme_font_size_override("font_size",25)
	column.add_child(title)
	info = Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(info)
	var subjects := HBoxContainer.new()
	column.add_child(subjects)
	for id: StringName in [&"cobre", &"jade", &"sentinela"]:
		_button(subjects, str(id).capitalize(), func(): show_model(id))
	var space := Control.new()
	space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(space)
	var actions := HBoxContainer.new()
	column.add_child(actions)
	for pair in [[&"Flight","Vuelo"],[&"Attack","Ataque"],[&"Hit","Impacto"],[&"Death","Muerte"]]:
		_button(actions, pair[1], func(): play_clip(pair[0]))
	_button(actions, "Volver", leave)
	var help := Label.new()
	help.text = "Arrastra el fondo: girar · Rueda: acercar / alejar · Esc: volver"
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(help)
	show_model(&"cobre")

func _button(row: Control, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(108,42)
	button.pressed.connect(action)
	row.add_child(button)

func show_model(id: StringName) -> void:
	if not ASSETS.has(id):
		return
	if is_instance_valid(model):
		remove_child(model)
		model.queue_free()
	chosen = id
	model = ASSETS[id].instantiate()
	add_child(model)
	animation = model.find_children("*", "AnimationPlayer", true, false)[0]
	# Duplicar cada Animation evita modificar recursos de partida o de otra vista.
	var source := animation.get_animation_library(&"")
	var library := AnimationLibrary.new()
	for name_text in source.get_animation_list():
		var item := source.get_animation(name_text).duplicate() as Animation
		item.loop_mode = Animation.LOOP_LINEAR if name_text == &"Flight" else Animation.LOOP_NONE
		library.add_animation(name_text,item)
	animation.remove_animation_library(&"")
	animation.add_animation_library(&"",library)
	play_clip(&"Flight")

func play_clip(value: StringName) -> void:
	clip = value
	animation.stop()
	animation.play(clip)
	info.text = "%s · %s\n%s" % [str(chosen).capitalize(), {&"Flight":"Vuelo", &"Attack":"Ataque", &"Hit":"Impacto", &"Death":"Muerte"}[clip], {&"cobre":"Coraza de bronce y alas carmesí.", &"jade":"Cuerpo esbelto, alas de hoz y aletas de aurora.", &"sentinela":"Guardián de armadura glacial y ojos de hielo."}[chosen]]

func _process(_delta: float) -> void:
	camera.position = Vector3(sin(angle)*distance, distance*0.42, -cos(angle)*distance)
	camera.look_at(Vector3(0,0.05,0.15))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			distance = clampf(distance + (-0.45 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.45),4.5,11)
	elif event is InputEventMouseMotion and dragging:
		angle += event.relative.x * 0.009
	elif event.is_action_pressed("ui_cancel"):
		leave()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false

func leave() -> void:
	if navigating:
		return
	navigating = true
	if get_tree().change_scene_to_file("res://scenes/dragon_selection.tscn") != OK:
		navigating = false
