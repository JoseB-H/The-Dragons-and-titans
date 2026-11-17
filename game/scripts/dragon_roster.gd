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
