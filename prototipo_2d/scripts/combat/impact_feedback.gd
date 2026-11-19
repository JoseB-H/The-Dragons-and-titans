extends Node
@export var camera: Camera2D
@export_range(0,.12,.005) var hit_pause := .045
@export_range(0,15) var shake_strength := 3.12
@export_range(.02,.5) var shake_duration := .16
var shake_left := 0.0
var pause_left := 0.0
var amplitude := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func on_hit(heavy: bool) -> void:
	amplitude = shake_strength if heavy else shake_strength*.4
	shake_left = shake_duration
	if heavy and hit_pause>0 and not get_tree().paused:
		get_tree().paused = true
		pause_left = hit_pause

func _process(delta: float) -> void:
	# El reloj del efecto sigue activo durante la pausa; el vuelo queda detenido.
	if pause_left>0:
		pause_left = maxf(0,pause_left-delta)
		if pause_left==0: get_tree().paused = false
	if shake_left>0:
		shake_left = maxf(0,shake_left-delta)
		camera.offset = Vector2(sin(shake_left*100),cos(shake_left*80))*amplitude*shake_left/shake_duration

func _exit_tree() -> void:
	if pause_left>0: get_tree().paused = false
