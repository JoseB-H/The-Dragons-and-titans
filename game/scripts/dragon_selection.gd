extends Control
## Menú propio del prototipo: presenta el catálogo sin modificar sus recursos.

const FRONTIER_PATH := "res://scenes/frontier.tscn"
const SIEGE_ARENA_PATH := "res://scenes/siege_arena.tscn"
const BEACON_ARENA_PATH := "res://scenes/beacon_arena.tscn"
const ARENA_PATH := "res://scenes/arena.tscn"

@onready var copper_button: Button = $Margin/Content/Cards/CopperButton
@onready var jade_button: Button = $Margin/Content/Cards/JadeButton
@onready var play_button: Button = $Margin/Content/Footer/PlayButton
@onready var details: Label = $Margin/Content/Footer/Details
@onready var _roster: Node = get_node("/root/DragonRoster")

var _navigating := false
var weapon_buttons: Array[Button] = []


func _ready() -> void:
	copper_button.pressed.connect(func(): select_profile(&"cobre"))
	jade_button.pressed.connect(func(): select_profile(&"jade"))
	play_button.pressed.connect(start_match)
	for profile: Resource in _roster.get_profiles():
		var card := _button_for(profile.id)
		if card != null:
			card.text = _profile_text(profile)
	var row := HBoxContainer.new()
	$Margin/Content.add_child(row)
	$Margin/Content.move_child(row, $Margin/Content/Footer.get_index())
	for item: Resource in _roster.get_weapons():
		var button := Button.new()
		button.text = item.display_name
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func(): select_weapon(item.id))
		row.add_child(button)
		weapon_buttons.append(button)
	var atlas := Button.new()
	atlas.text = "Volver al atlas"
	row.add_child(atlas)
	atlas.pressed.connect(_open_arena.bind("res://scenes/world_menu.tscn"))
	var chain: Array[Button] = [copper_button, jade_button]
	chain.append_array(weapon_buttons)
	chain.append(atlas)
	chain.append(play_button)
	var gallery := Button.new()
	gallery.name = "GalleryButton"
	gallery.text = "Ver dragones 3D"
	gallery.custom_minimum_size = Vector2(160, 50)
	$Margin/Content/Footer.add_child(gallery)
	gallery.pressed.connect(open_gallery)
	chain.append(gallery)
	var beacon_button := Button.new()
	beacon_button.name = "BeaconButton"
	beacon_button.text = "Capturar balizas"
	beacon_button.pressed.connect(start_beacon_match)
	$Margin/Content.add_child(beacon_button)
	$Margin/Content.move_child(beacon_button, $Margin/Content/Footer.get_index())
	chain.append(beacon_button)
	var siege_button := Button.new()
	siege_button.name = "SiegeButton"
	siege_button.text = "Asedio de la Caldera · 2 contra 2"
	siege_button.pressed.connect(start_siege_match)
	$Margin/Content.add_child(siege_button)
	$Margin/Content.move_child(siege_button, $Margin/Content/Footer.get_index())
	chain.append(siege_button)
	var frontier_button := Button.new()
	frontier_button.name = "FrontierButton"
	frontier_button.text = "Frontera de Ceniza · 5 contra 5"
	frontier_button.pressed.connect(start_frontier_match)
	$Margin/Content.add_child(frontier_button)
	$Margin/Content.move_child(frontier_button, $Margin/Content/Footer.get_index())
	chain.append(frontier_button)
	var nether := Button.new()
	nether.name = "NethergateButton"
	nether.text = "Nethergate · 5 contra 5"
	nether.pressed.connect(_open_arena.bind("res://scenes/nethergate.tscn"))
	$Margin/Content.add_child(nether)
	$Margin/Content.move_child(nether, $Margin/Content/Footer.get_index())
	$Margin/Content.add_theme_constant_override("separation", 6)
	chain.append(nether)
	for i in range(chain.size()):
		chain[i].focus_next = chain[i].get_path_to(chain[(i + 1) % chain.size()])
		chain[i].focus_previous = chain[i].get_path_to(chain[(i - 1 + chain.size()) % chain.size()])
		chain[i].focus_neighbor_bottom = chain[i].focus_next
		chain[i].focus_neighbor_top = chain[i].focus_previous
	_refresh_selection()
	# Volver al menú enfoca la elección actual; Enter repetido no inicia Arena.
	# _ready ya está dentro del árbol; el foco no debe sobrevivir a una salida rápida.
	_button_for(selected_profile_id()).grab_focus()


func select_profile(id: StringName) -> bool:
	if _navigating or not _roster.select_dragon(id):
		return false
	_refresh_selection()
	return true


func selected_profile_id() -> StringName:
	return _roster.selected_id


func start_match() -> Error:
	return _open_arena(ARENA_PATH)


func start_beacon_match() -> Error:
	return _open_arena(BEACON_ARENA_PATH)


func start_siege_match() -> Error:
	return _open_arena(SIEGE_ARENA_PATH)


func start_frontier_match() -> Error:
	return _open_arena(FRONTIER_PATH)


func _open_arena(scene_path: String) -> Error:
	if _navigating:
		return OK
	_navigating = true
	play_button.disabled = true
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		_navigating = false
		play_button.disabled = false
		details.text = "No se pudo abrir la arena. Inténtalo de nuevo."
	return error


func _button_for(id: StringName) -> Button:
	match id:
		&"cobre":
			return copper_button
		&"jade":
			return jade_button
	return null


func _profile_text(profile: Resource) -> String:
	return "%s\n%s\n\nSalud: %s\nVelocidad: %s\nBásico: %s daño · %s s\nQ: %s daño · %s s\nE: %s daño · radio %s · %s s" % [
		profile.display_name, profile.description, profile.max_health,
		String.num(profile.movement_speed, 2), profile.basic_damage,
		String.num(profile.basic_cooldown, 2), profile.power_damage,
		String.num(profile.power_cooldown, 2), profile.pulse_damage,
		String.num(profile.pulse_radius, 2), String.num(profile.pulse_cooldown, 2)
	]


func _refresh_selection() -> void:
	var profile: Resource = _roster.selected_profile()
	copper_button.set_pressed_no_signal(profile.id == &"cobre")
	jade_button.set_pressed_no_signal(profile.id == &"jade")
	var equipment: Resource = _roster.selected_weapon()
	for i in range(weapon_buttons.size()):
		weapon_buttons[i].set_pressed_no_signal(_roster.get_weapons()[i].id == equipment.id)
	details.text = "Elegido: %s\nBalance provisional · La elección se conserva al reiniciar." % profile.display_name
	details.text = "%s / %s · Básico: %d daño · %.2f s\nQ/E del dragón · Balance provisional" % [profile.display_name, equipment.display_name, equipment.damage_for(profile), equipment.cooldown_for(profile)]
	play_button.text = "Jugar con %s" % profile.display_name

func select_weapon(id: StringName) -> bool:
	if _navigating or not _roster.select_weapon(id):
		return false
	_refresh_selection()
	return true

func open_gallery() -> Error:
	if _navigating:
		return OK
	_navigating = true
	var error := get_tree().change_scene_to_file("res://scenes/model_gallery.tscn")
	if error != OK:
		_navigating = false
	return error
