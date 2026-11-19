extends Control

var chosen: StringName
var repeated := false
var status := Label.new()
var reroll := Button.new()

func _ready() -> void:
	var roster := get_node("/root/DragonRoster")
	chosen = roster.get_profiles().pick_random().id
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var form := VBoxContainer.new()
	form.add_theme_constant_override("separation",16)
	center.add_child(form)
	form.add_child(status)
	form.add_child(reroll)
	reroll.text = "Repetir sorteo · 1 disponible"
	reroll.pressed.connect(func():
		if repeated: return
		repeated = true
		var alternatives: Array = roster.get_profiles().filter(func(p): return p.id != chosen)
		chosen = alternatives.pick_random().id
		reroll.disabled = true
		reroll.text = "Sorteo utilizado"
		_refresh())
	var weapons := OptionButton.new()
	form.add_child(weapons)
	for weapon in roster.get_weapons():
		weapons.add_item("Arma · " + weapon.display_name)
		if weapon.id == roster.selected_weapon_id:
			weapons.select(weapons.item_count-1)
	var play := Button.new()
	play.text = "Entrar en Halvalas"
	form.add_child(play)
	play.pressed.connect(func():
		roster.select_dragon(chosen)
		roster.select_weapon(roster.get_weapons()[weapons.selected].id)
		get_tree().change_scene_to_file("res://scenes/aram.tscn"))
	var back := Button.new()
	back.text = "Volver al atlas"
	form.add_child(back)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/world_menu.tscn"))
	_refresh()

func _refresh() -> void:
	status.text = "HALVALAS  /  ARAM\n\nDragón asignado · " + String(chosen).capitalize()
