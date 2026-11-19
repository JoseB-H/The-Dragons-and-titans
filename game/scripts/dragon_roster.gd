extends Node
## Selección temporal de la sesión; recargar la arena conserva este autoload.

const Arena := preload("res://scripts/arena.gd")
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
	if get_tree().current_scene is Arena:
		return false
	for item: Resource in get_weapons():
		if item.id == id:
			selected_weapon_id = id
			return true
	return false


const RECORDS := "user://duelos.cfg"

func completed_duels() -> int:
	var records := ConfigFile.new()
	if records.load(RECORDS) != OK:
		return 0
	return maxi(0, int(records.get_value("duelos","completados",0)))

func record_duel() -> void:
	var records := ConfigFile.new()
	records.set_value("duelos","completados", completed_duels()+1)
	if records.save(RECORDS) != OK:
		push_warning("No se pudo guardar el progreso LAN.")

const TRAINING_RECORD := "user://proving_grounds.cfg"

func training_record() -> ConfigFile:
	var record := ConfigFile.new()
	record.load(TRAINING_RECORD)
	return record

func award_training() -> Error:
	var record := training_record()
	if record.get_value("mission","proven",false): return OK
	record.set_value("mission","proven",true)
	record.set_value("mission","crystals",50)
	return record.save(TRAINING_RECORD)

func buy_training_trail() -> Error:
	var record := training_record()
	var balance := int(record.get_value("mission","crystals",0))
	if balance < 50 or record.get_value("mission","trail",false): return ERR_UNAVAILABLE
	record.set_value("mission","crystals",balance-50)
	record.set_value("mission","trail",true)
	return record.save(TRAINING_RECORD)
