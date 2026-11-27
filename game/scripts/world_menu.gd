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
var _guide: AcceptDialog
var _sigil := TextureRect.new()
var index := 0
var map_area := TextureRect.new()
var markers: Array[Button] = []
var title := Label.new()
var format_label := Label.new()
var description := Label.new()
var enter := Button.new()
var panel := VBoxContainer.new()


func _ready() -> void:
	theme = preload("res://scripts/fantasy_theme.gd").create()
	map_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_area.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_area.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	map_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(map_area)
	var veil := ColorRect.new()
	veil.color = Color(0.025,0.045,0.055,.42)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veil)
	var frame := MarginContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left","right","top","bottom"]:
		frame.add_theme_constant_override("margin_"+edge,24)
	add_child(frame)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation",18)
	frame.add_child(page)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation",14)
	page.add_child(header)
	var emblem := TextureRect.new()
	emblem.texture = preload("res://assets/third_party/game-icons/dragon-head.svg")
	emblem.custom_minimum_size = Vector2(44,44)
	emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	emblem.modulate = Color("#dfbd73")
	header.add_child(emblem)
	var brand := VBoxContainer.new()
	brand.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(brand)
	var heading := Label.new()
	heading.text = "DRAGONS AND TITANS"
	heading.add_theme_font_override("font",preload("res://scripts/fantasy_theme.gd").heading_font())
	heading.add_theme_font_size_override("font_size",25)
	brand.add_child(heading)
	var subtitle := Label.new()
	subtitle.text = "ATLAS DE LOS REINOS"
	subtitle.modulate = Color("#cbb37c")
	subtitle.add_theme_font_size_override("font_size",12)
	brand.add_child(subtitle)
	var equipment := Button.new()
	equipment.text = "Dragones y equipo"
	equipment.add_theme_font_size_override("font_size",14)
	header.add_child(equipment)
	equipment.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/dragon_selection.tscn"))
	_guide = AcceptDialog.new()
	_guide.theme = theme
	_guide.title = "Guía de los reinos"
	_guide.ok_button_text = "Volver al atlas"
	_guide.min_size = Vector2i(560,360)
	var scroll_guide := ScrollContainer.new()
	scroll_guide.custom_minimum_size = Vector2(520,310)
	scroll_guide.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_guide.add_child(scroll_guide)
	var summaries := VBoxContainer.new()
	summaries.size_flags_horizontal = SIZE_EXPAND_FILL
	summaries.add_theme_constant_override("separation",18)
	scroll_guide.add_child(summaries)
	for destination in MODES:
		var summary := Label.new()
		summary.text = "%s\n%s" % [destination[0],destination[2]]
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		summary.size_flags_horizontal = SIZE_EXPAND_FILL
		summaries.add_child(summary)
	add_child(_guide)
	var help := Button.new()
	help.text = "Guía"
	help.add_theme_font_size_override("font_size",14)
	header.add_child(help)
	help.pressed.connect(func(): _guide.popup_centered_clamped(Vector2i(680,470)))
	var lan := Button.new()
	lan.text = "LAN"
	lan.add_theme_font_size_override("font_size",14)
	header.add_child(lan)
	lan.pressed.connect(func(): select_mode(5))
	var divider := HSeparator.new()
	page.add_child(divider)
	var row := HBoxContainer.new()
	row.size_flags_vertical = SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation",20)
	page.add_child(row)
	var destinations := PanelContainer.new()
	destinations.custom_minimum_size.x = 225
	row.add_child(destinations)
	var list_page := VBoxContainer.new()
	list_page.add_theme_constant_override("separation",14)
	destinations.add_child(list_page)
	var list_title := Label.new()
	list_title.text = "ELIGE TU DESTINO"
	list_title.add_theme_font_size_override("font_size",13)
	list_title.modulate = Color("#dfbd73")
	list_page.add_child(list_title)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	list_page.add_child(scroll)
	var destination_list := VBoxContainer.new()
	destination_list.size_flags_horizontal = SIZE_EXPAND_FILL
	destination_list.add_theme_constant_override("separation",6)
	scroll.add_child(destination_list)
	for i in MODES.size():
		var pin := Button.new()
		pin.text = MODES[i][0]
		pin.toggle_mode = true
		pin.alignment = HORIZONTAL_ALIGNMENT_LEFT
		pin.add_theme_font_size_override("font_size",13)
		pin.custom_minimum_size.y = 36
		for state in ["normal","hover","pressed","disabled","focus"]:
			var style := theme.get_stylebox(state,"Button").duplicate() as StyleBoxFlat
			style.content_margin_left = 10
			style.content_margin_right = 10
			style.content_margin_top = 7
			style.content_margin_bottom = 7
			pin.add_theme_stylebox_override(state,style)
		destination_list.add_child(pin)
		pin.pressed.connect(select_mode.bind(i))
		markers.append(pin)
	var scenic_space := Control.new()
	scenic_space.size_flags_horizontal = SIZE_EXPAND_FILL
	scenic_space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(scenic_space)
	var detail_frame := PanelContainer.new()
	detail_frame.custom_minimum_size.x = 310
	detail_frame.size_flags_vertical = SIZE_EXPAND_FILL
	row.add_child(detail_frame)
	panel.custom_minimum_size.x = 260
	panel.add_theme_constant_override("separation",12)
	detail_frame.add_child(panel)
	var caption := Label.new()
	caption.text = "EL REINO TE ESPERA"
	caption.modulate = Color("#dfbd73")
	caption.add_theme_font_size_override("font_size",12)
	var caption_row := HBoxContainer.new()
	caption_row.add_theme_constant_override("separation",10)
	panel.add_child(caption_row)
	_sigil.custom_minimum_size = Vector2(26,26)
	_sigil.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sigil.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sigil.modulate = Color("#dfbd73")
	caption_row.add_child(_sigil)
	caption_row.add_child(caption)
	title.add_theme_font_size_override("font_size",29)
	title.add_theme_font_override("font",preload("res://scripts/fantasy_theme.gd").heading_font())
	format_label.add_theme_font_size_override("font_size",14)
	format_label.modulate = Color("#d4c197")
	description.add_theme_font_size_override("font_size",16)
	for label in [title,format_label]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		panel.add_child(label)
	var objective_scroll := ScrollContainer.new()
	objective_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	objective_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	objective_scroll.custom_minimum_size.y = 40
	panel.add_child(objective_scroll)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_horizontal = SIZE_EXPAND_FILL
	objective_scroll.add_child(description)
	panel.add_child(HSeparator.new())
	enter.custom_minimum_size.y = 50
	enter.add_theme_font_size_override("font_size",16)
	panel.add_child(enter)
	enter.pressed.connect(_enter_destination)
	var codex := preload("res://scripts/codex.gd").new()
	codex.theme = theme
	add_child(codex)
	var read := Button.new()
	read.text = "Códice de los jinetes"
	read.add_theme_font_size_override("font_size",14)
	panel.add_child(read)
	read.pressed.connect(func(): codex.popup_centered_clamped(Vector2i(720,510)))
	var footer := Label.new()
	footer.text = "EXPLORA  ·  ELIGE TU DRAGÓN  ·  LIBERA AL TITÁN"
	footer.add_theme_font_size_override("font_size",12)
	footer.modulate = Color("#c8bd9f")
	page.add_child(footer)
	select_mode(0)
	markers[0].grab_focus()
	get_viewport().size_changed.connect(_apply_responsive)
	_apply_responsive()


func _apply_responsive() -> void:
	var compact := get_viewport_rect().size.y < 620
	title.add_theme_font_size_override("font_size",25 if compact else 29)
	description.add_theme_font_size_override("font_size",14 if compact else 16)
	format_label.add_theme_font_size_override("font_size",12 if compact else 14)
	panel.add_theme_constant_override("separation",8 if compact else 12)
	var panel_style := theme.get_stylebox("panel","PanelContainer") as StyleBoxFlat
	panel_style.set_content_margin_all(16 if compact else 24)


func _place_markers() -> void:
	pass


func select_mode(i: int) -> void:
	index = i
	_sigil.texture = preload("res://assets/third_party/game-icons/rune-stone.svg") if i in [1,2,6] else preload("res://assets/third_party/game-icons/portal.svg") if i == 5 else preload("res://assets/third_party/game-icons/stone-tower.svg")
	var background_path := "res://assets/menu/nethergate_view.jpg" if i == 1 else "res://assets/menu/atlas.jpg"
	if not ResourceLoader.exists(background_path):
		background_path = "res://assets/menu/nethergate_view.jpg"
	map_area.texture = load(background_path)
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
	dialog.theme = theme
	dialog.title = "Preparar la misión"
	dialog.ok_button_text = "Iniciar vuelo"
	var choices := VBoxContainer.new()
	choices.add_theme_constant_override("separation",12)
	dialog.add_child(choices)
	var pickers: Array[OptionButton] = []
	for options in [roster.get_profiles(), roster.get_weapons()]:
		var field_label := Label.new()
		field_label.text = "Dragón" if pickers.is_empty() else "Arma"
		choices.add_child(field_label)
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
	dialog.popup_centered_clamped(Vector2i(520,350))

