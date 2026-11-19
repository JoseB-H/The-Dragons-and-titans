extends Control

const MODES := [
	["Frontera de Ceniza", "MOBA · 5 contra 5 con bots", "Avanza con las oleadas de ángeles. Derriba las tres torres rivales para retirar el escudo del núcleo y destruirlo.", "frontier", Vector2(.23,.19)],
	["Nethergate", "Asedio con titanes · 5 contra 5 con bots", "Domina las runas para invocar antes a tu titán. Escóltalo hasta la puerta enemiga y rompe el cristal para liberar a tu titán.", "nethergate", Vector2(.77,.20)],
	["Santuario", "Captura de balizas · Solitario", "Mantente sobre las dos balizas hasta capturarlas. Vence al Sentinela para asegurar el santuario.", "beacon_arena", Vector2(.47,.50)],
	["Arena de vuelo", "Entrenamiento · Solitario", "Practica el vuelo, el disparo y las habilidades de tu dragón en un duelo contra el Sentinela.", "arena", Vector2(.18,.77)],
	["La Caldera", "Asedio · 2 contra 2 con bots", "Combate junto a tu aliado. Derriba la torre que protege el núcleo rival y destruye el núcleo antes de perder el tuyo.", "siege_arena", Vector2(.79,.81)],
	["Las Agujas", "Multijugador LAN · 1 contra 1", "Crea una sala o entra con la IP del anfitrión. Dos jinetes se enfrentan en tiempo real. Gana quien agote primero la salud rival.", "lan_duel", Vector2(.83,.49)],
	["Cinco bastiones","Capture Points · 5 contra 5 con bots","Ocupa cinco puntos para desgastar la jaula rival. Cada bastión conquistado levanta cuatro torretas y activa un portal de tu base.","capture_points",Vector2(.30,.46)],
	["Halvalas","ARAM · 5 contra 5 con bots","Recibe un dragón al azar, elige el arma y combate en un solo carril. El oro del equipo activa la balista.","aram_lobby",Vector2(.53,.78)],
	["El Pacto","MOBA clásico · 5 contra 5 con bots","Derriba torres, santuarios y obeliscos. Deposita oro para llamar al Titán del Caos y abre la jaula rival.","classic_moba",Vector2(.55,.25)],
	["Mire Bog","Aventura · misión original del prototipo","Vence al guardián, recoge al anciano de Morth y vuelve con él a la aldea. La primera victoria guarda una estrella.","mire_bog",Vector2(.14,.58)],
	["Proving Grounds","Tutorial PvE · Un jugador","Elige tu equipo, defiende el obelisco y rompe el escudo de la jaula enemiga.","proving_grounds",Vector2(.54,.94)],
	["Práctica de vuelo","Laboratorio · Movimiento","Vuela entre las balizas y apunta mientras te alejas. F12 guarda una captura.","levels/flight_lab",Vector2(.37,.66)]
]
var index := 0
var map_area := TextureRect.new()
var markers: Array[Button] = []
var title := Label.new()
var format_label := Label.new()
var description := Label.new()
var enter := Button.new()
var panel := VBoxContainer.new()


func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("#10191d")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var frame := MarginContainer.new()
	add_child(frame)
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left","right","top","bottom"]:
		frame.add_theme_constant_override("margin_"+edge, 26)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 14)
	frame.add_child(page)
	var header := HBoxContainer.new()
	page.add_child(header)
	var heading := Label.new()
	heading.text = "Dragons and Titans   /   Atlas de los reinos"
	heading.add_theme_font_size_override("font_size", 29)
	heading.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(heading)
	var lan := Button.new()
	lan.text = "Multijugador LAN"
	header.add_child(lan)
	lan.pressed.connect(func(): select_mode(5))
	var guide := AcceptDialog.new()
	guide.title = "Guía de modos"
	var summaries := PackedStringArray()
	for destination in MODES:
		summaries.append("%s · %s" % [destination[0], destination[2]])
	guide.dialog_text = "\n\n".join(summaries)
	add_child(guide)
	var help := Button.new()
	help.text = "Guía de modos"
	header.add_child(help)
	help.pressed.connect(func(): guide.popup_centered())
	var equipment := Button.new()
	equipment.text = "Dragones y equipo"
	header.add_child(equipment)
	equipment.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/dragon_selection.tscn"))
	var row := HBoxContainer.new()
	row.size_flags_vertical = SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 24)
	page.add_child(row)
	map_area.texture = preload("res://assets/menu/atlas.jpg")
	map_area.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_area.size_flags_horizontal = SIZE_EXPAND_FILL
	row.add_child(map_area)
	for i in MODES.size():
		var pin := Button.new()
		pin.text = MODES[i][0]
		pin.toggle_mode = true
		map_area.add_child(pin)
		pin.pressed.connect(select_mode.bind(i))
		markers.append(pin)
	map_area.resized.connect(_place_markers)
	panel.custom_minimum_size.x = 310
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_theme_constant_override("separation", 16)
	row.add_child(panel)
	title.add_theme_font_size_override("font_size", 31)
	format_label.modulate = Color("#e4c88b")
	for label in [title, format_label, description]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel.add_child(label)
	enter.custom_minimum_size.y = 48
	panel.add_child(enter)
	enter.pressed.connect(_enter_destination)
	var codex := preload("res://scripts/codex.gd").new()
	add_child(codex)
	var read := Button.new()
	read.text = "Códice de los jinetes"
	panel.add_child(read)
	read.pressed.connect(func(): codex.popup_centered_clamped(Vector2i(720,510)))
	select_mode(0)
	markers[0].grab_focus()
	_place_markers.call_deferred()


func _place_markers() -> void:
	for i in markers.size():
		var pin := markers[i]
		pin.size = pin.get_combined_minimum_size() + Vector2(16,8)
		pin.position = (map_area.size * Vector2(MODES[i][4]) - pin.size / 2).clamp(Vector2.ZERO, (map_area.size-pin.size).max(Vector2.ZERO))


func select_mode(i: int) -> void:
	index = i
	for j in markers.size():
		markers[j].set_pressed_no_signal(i == j)
	title.text = MODES[i][0]
	format_label.text = MODES[i][1]
	description.text = MODES[i][2]
	enter.text = "Abrir sala LAN" if i == 5 else "Jugar con %s" % get_node("/root/DragonRoster").selected_profile().display_name

func _enter_destination() -> void:
	if MODES[index][3] != "proving_grounds":
		get_tree().change_scene_to_file("res://scenes/%s.tscn" % MODES[index][3])
		return
	var roster := get_node("/root/DragonRoster")
	var dialog := ConfirmationDialog.new()
	dialog.title = "Preparar la misión"
	dialog.ok_button_text = "Iniciar vuelo"
	var choices := VBoxContainer.new()
	dialog.add_child(choices)
	var pickers: Array[OptionButton] = []
	for options in [roster.get_profiles(), roster.get_weapons()]:
		var picker := OptionButton.new()
		for item in options:
			picker.add_item(item.display_name)
			picker.set_item_metadata(picker.item_count-1, item.id)
			if item.id in [roster.selected_id, roster.selected_weapon_id]:
				picker.select(picker.item_count-1)
		choices.add_child(picker)
		pickers.append(picker)
	var shop := Button.new()
	choices.add_child(shop)
	var refresh_shop := func():
		var record: ConfigFile = roster.training_record()
		var balance := int(record.get_value("mission","crystals",0))
		var owned := bool(record.get_value("mission","trail",false))
		shop.text = "Estela turquesa equipada" if owned else "Estela turquesa · 50 cristales (tienes %d)" % balance
		shop.disabled = owned or balance < 50
	refresh_shop.call()
	shop.pressed.connect(func(): roster.buy_training_trail(); refresh_shop.call())
	var reward := Label.new()
	reward.text = "Primera victoria · 50 cristales"
	choices.add_child(reward)
	add_child(dialog)
	dialog.confirmed.connect(func():
		roster.select_dragon(pickers[0].get_selected_metadata())
		roster.select_weapon(pickers[1].get_selected_metadata())
		get_tree().change_scene_to_file("res://scenes/proving_grounds.tscn"))
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(340,160))
