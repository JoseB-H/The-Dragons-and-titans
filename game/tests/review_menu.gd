extends SceneTree
## Revisión aislada de UI: no simula ni valida el combate.
class Entry extends Resource:
	var id := "cobre"
	var display_name := "Cobre"
class ReviewRoster extends Node:
	var selected_id := "cobre"
	var selected_weapon_id := "ascua"
	func selected_profile() -> Resource:
		return Entry.new()
	func get_profiles() -> Array:
		return [Entry.new()]
	func get_weapons() -> Array:
		var item := Entry.new()
		item.id = "ascua"
		item.display_name = "Ascua"
		return [item]
	func completed_duels() -> int:
		return 0
	func training_record() -> ConfigFile:
		return ConfigFile.new()
	func buy_training_trail() -> void:
		pass
	func select_dragon(_id: String) -> void:
		pass
	func select_weapon(_id: String) -> void:
		pass
var output_dir := ""
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	output_dir = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output_dir)
	root.gui_embed_subwindows = true
	if not root.has_node("DragonRoster"):
		var roster := ReviewRoster.new()
		roster.name = "DragonRoster"
		root.add_child(roster)
	var menu: Control = load("res://scripts/world_menu.gd").new()
	root.add_child(menu)
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.select_mode(1)
	for resolution in [Vector2i(1280,720),Vector2i(960,540)]:
		root.size = resolution
		await _settle()
		assert(menu.markers.size() == 12)
		for i in 12:
			menu.select_mode(i)
			assert(menu.title.text == menu.MODES[i][0])
			assert(menu.markers[i].button_pressed)
		menu.select_mode(1)
		menu.markers[1].grab_focus()
		await _settle()
		assert(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(menu.enter.get_global_rect()))
		var suffix := "%dx%d" % [resolution.x,resolution.y]
		root.get_texture().get_image().save_png(output_dir+"/menu-"+suffix+".png")
		menu._guide.popup_centered_clamped(Vector2i(680,470))
		await _settle()
		assert(menu._guide.size.x <= resolution.x and menu._guide.size.y <= resolution.y)
		root.get_texture().get_image().save_png(output_dir+"/guide-"+suffix+".png")
		menu._guide.hide()
		menu.select_mode(10)
		menu._enter_destination()
		await _settle()
		var mission: ConfirmationDialog = menu.get_child(-1)
		assert(mission.visible)
		assert(mission.size.x <= resolution.x and mission.size.y <= resolution.y)
		root.get_texture().get_image().save_png(output_dir+"/mission-"+suffix+".png")
		mission.queue_free()
		await _settle()
	print("UI_REVIEW_OK: 12 destinos, entrada visible, guia y preparacion en dos resoluciones")
	quit()
func _settle() -> void:
	for i in 8:
		await process_frame
	await RenderingServer.frame_post_draw
