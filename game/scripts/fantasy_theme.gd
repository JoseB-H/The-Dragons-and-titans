extends RefCounted
## Tema compartido; colores propios y controles nativos de Godot.
static func heading_font() -> Font:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Georgia","Noto Serif","Liberation Serif"])
	return font

static func create() -> Theme:
	var result := Theme.new()
	result.default_font_size = 17
	result.set_color("font_color", "Label", Color("#e9e4d6"))
	for type in ["Button", "OptionButton"]:
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			var box := StyleBoxFlat.new()
			box.bg_color = Color("#17282d") if state == "normal" else Color("#284750")
			if state == "disabled": box.bg_color = Color("#1b2427")
			box.border_color = Color("#a78c54") if state in ["normal", "disabled"] else Color("#e5c47f")
			box.set_border_width_all(1 if state != "focus" else 2)
			box.set_corner_radius_all(4)
			box.content_margin_left = 18
			box.content_margin_right = 18
			box.content_margin_top = 12
			box.content_margin_bottom = 12
			result.set_stylebox(state,type,box)
		result.set_color("font_color",type,Color("#e9dfc7"))
		result.set_color("font_hover_color",type,Color("#fff1cc"))
		result.set_color("font_pressed_color",type,Color("#fff1cc"))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("#101d23")
	panel.border_color = Color("#ac8a4f")
	panel.set_border_width_all(2)
	panel.set_corner_radius_all(6)
	panel.set_content_margin_all(24)
	panel.shadow_color = Color(0,0,0,.65)
	panel.shadow_size = 18
	result.set_stylebox("panel","PanelContainer",panel)
	result.set_stylebox("panel","Window",panel)
	result.set_stylebox("panel","AcceptDialog",panel)
	return result
