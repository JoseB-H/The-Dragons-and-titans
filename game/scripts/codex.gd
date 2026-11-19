extends AcceptDialog

const DATA := preload("res://data/codex/reference.json")
var category := OptionButton.new()
var search := LineEdit.new()
var items := RichTextLabel.new()


func _ready() -> void:
	title = "Códice de los jinetes"
	var page := VBoxContainer.new()
	add_child(page)
	for key in DATA.data:
		category.add_item(key)
	page.add_child(category)
	search.placeholder_text = "Buscar en esta sección…"
	search.clear_button_enabled = true
	page.add_child(search)
	items.size_flags_vertical = Control.SIZE_EXPAND_FILL
	items.selection_enabled = true
	page.add_child(items)
	category.item_selected.connect(func(_id): search.clear(); refresh())
	search.text_changed.connect(func(_query): refresh())
	about_to_popup.connect(refresh)
	refresh()


func refresh() -> void:
	var section: Dictionary = DATA.data[category.get_item_text(category.selected)]
	var rows := PackedStringArray()
	var played: int = get_node("/root/DragonRoster").completed_duels()
	var thresholds := {"PvP":1,"Worthy Rider":10,"Battle Worn":50,"Veteran":100,"Legend":1000}
	for entry: String in section.entries:
		if entry.to_lower().contains(search.text.strip_edges().to_lower()):
			var name_key := entry.get_slice(" — ",0)
			if thresholds.has(name_key):
				entry += "   [%d/%d LAN]" % [mini(played,thresholds[name_key]),thresholds[name_key]]
			if name_key == "Proven" and get_node("/root/DragonRoster").training_record().get_value("mission","proven",false):
				entry += "   [Completado]"
			rows.append(entry)
	var results := "\n\n".join(rows) if not rows.is_empty() else "Sin coincidencias."
	items.text = "%s\n\n%s" % [section.intro, results]
	items.scroll_to_line(0)
