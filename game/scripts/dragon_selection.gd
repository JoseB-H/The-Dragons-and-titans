extends Control
## Menú propio del prototipo: presenta el catálogo sin modificar sus recursos.

const ARENA_PATH := "res://scenes/arena.tscn"

@onready var copper_button: Button = $Margin/Content/Cards/CopperButton
@onready var jade_button: Button = $Margin/Content/Cards/JadeButton
@onready var play_button: Button = $Margin/Content/Footer/PlayButton
@onready var details: Label = $Margin/Content/Footer/Details
@onready var _roster: Node = get_node("/root/DragonRoster")

var _navigating := false


func _ready() -> void:
	copper_button.pressed.connect(func(): select_profile(&"cobre"))
	jade_button.pressed.connect(func(): select_profile(&"jade"))
	play_button.pressed.connect(start_match)
	for profile: Resource in _roster.get_profiles():
		var card := _button_for(profile.id)
		if card != null:
			card.text = _profile_text(profile)
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
	if _navigating:
		return OK
	_navigating = true
	play_button.disabled = true
	var error := get_tree().change_scene_to_file(ARENA_PATH)
	if error != OK:
		_navigating = false
		play_button.disabled = false
		details.text = "No se pudo abrir la arena. Vuelve a pulsar Jugar."
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
	details.text = "Elegido: %s\nBalance provisional · La elección se conserva al reiniciar." % profile.display_name
	play_button.text = "Jugar con %s" % profile.display_name
