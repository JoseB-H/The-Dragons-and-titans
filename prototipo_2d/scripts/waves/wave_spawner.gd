extends Node2D
enum Result { PLAYING, VICTORY, DEFEAT }
@export var minion_scene: PackedScene
@export var wave_sizes := PackedInt32Array([3, 4, 5])
@export_range(0.1, 60) var wave_pause := 3.0
@export var obelisk: Node2D
@export var player: CharacterBody2D
@export var objective: Label
var wave := 0
var remaining := 0
var wait_left := 0.0
var result := Result.PLAYING

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	obelisk.get_node("HealthComponent").died.connect(_finish.bind(Result.DEFEAT))
	wait_left = wave_pause
	_refresh()

func _physics_process(delta: float) -> void:
	if result != Result.PLAYING or get_tree().paused or remaining > 0: return
	wait_left -= delta
	if wait_left > 0: return
	if wave == wave_sizes.size():
		_finish(Result.VICTORY)
		return
	remaining = maxi(0, wave_sizes[wave])
	wave += 1
	var markers := get_children()
	for i in remaining:
		var unit = minion_scene.instantiate()
		unit.player = player
		unit.obelisk = obelisk
		get_parent().add_child(unit)
		unit.global_position = markers[i % markers.size()].global_position + Vector2(0, 20*floori(float(i)/markers.size()))
		unit.get_node("HealthComponent").died.connect(_minion_died, CONNECT_ONE_SHOT)
	wait_left = wave_pause
	_refresh()

func _minion_died() -> void:
	if result != Result.PLAYING: return
	remaining -= 1
	if remaining == 0 and wave == wave_sizes.size():
		_finish(Result.VICTORY)
	else:
		_refresh()

func _refresh() -> void:
	objective.text = "Defiende el obelisco · Oleada %d/%d · Minions restantes %d" % [wave,wave_sizes.size(),remaining]

func _finish(outcome: Result) -> void:
	if result != Result.PLAYING: return
	result = outcome
	objective.text = ("Victoria" if result == Result.VICTORY else "Derrota") + " · R para reiniciar"
	# La pausa de fin de partida pasa a ser dueña del reloj.
	var feedback = get_parent().get_node("ImpactFeedback")
	feedback.pause_left = 0
	get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if result != Result.PLAYING and event.is_action_pressed("restart_match"):
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		get_tree().reload_current_scene()
