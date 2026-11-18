extends Node
## Selección temporal de la sesión; recargar la arena conserva este autoload.

const COPPER := preload("res://data/dragons/cobre.tres")
const JADE := preload("res://data/dragons/jade.tres")

var selected_id: StringName = &"cobre"


func get_profiles() -> Array[Resource]:
	return [COPPER, JADE]


func selected_profile() -> Resource:
	for profile: Resource in get_profiles():
		if profile.id == selected_id:
			return profile
	return COPPER


func select_dragon(id: StringName) -> bool:
	for profile: Resource in get_profiles():
		if profile.id == id:
			selected_id = id
			return true
	return false

const EMBER := preload("res://data/weapons/ascua.tres")
const HAMMER := preload("res://data/weapons/martillo.tres")
var selected_weapon_id: StringName = &"ascua"

func get_weapons() -> Array[Resource]:
	return [EMBER, HAMMER]

func selected_weapon() -> Resource:
	for item: Resource in get_weapons():
		if item.id == selected_weapon_id:
			return item
	return EMBER

func select_weapon(id: StringName) -> bool:
	# Solo el selector permite equipar. El combate utiliza una instantánea.
	if get_tree().current_scene != null and get_tree().current_scene.scene_file_path == "res://scenes/arena.tscn":
		return false
	for item: Resource in get_weapons():
		if item.id == id:
			selected_weapon_id = id
			return true
	return false
