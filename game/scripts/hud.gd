extends CanvasLayer
## Presentación de la partida; Arena conserva la lógica y la recarga de escena.

signal restart_requested
signal selection_requested

@onready var label: Label = $Panel/Margin/Label
@onready var restart_button: Button = $ResultPanel/Margin/Content/Actions/RestartButton
@onready var selection_button: Button = $ResultPanel/Margin/Content/Actions/SelectionButton
@onready var result_panel: PanelContainer = $ResultPanel
@onready var result_title: Label = $ResultPanel/Margin/Content/ResultTitle

var _restart_emitted := false


func update_view(status_text: String, result: int) -> void:
	label.text = status_text
	var show_result := result != 0
	var was_visible := result_panel.visible
	result_panel.visible = show_result
	if not show_result:
		_restart_emitted = false
		return
	result_title.text = "VICTORIA" if result == 1 else "DERROTA"
	result_title.modulate = Color(0.62, 1.0, 0.76) if result == 1 else Color(1.0, 0.66, 0.62)
	if not was_visible:
		restart_button.grab_focus()


func _on_restart_button_pressed() -> void:
	# Un final admite una sola solicitud incluso ante eco o clics rápidos.
	if not result_panel.visible or _restart_emitted:
		return
	_restart_emitted = true
	restart_requested.emit()


func _on_selection_button_pressed() -> void:
	if not result_panel.visible or _restart_emitted:
		return
	_restart_emitted = true
	selection_requested.emit()
