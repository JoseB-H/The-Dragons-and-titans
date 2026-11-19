extends StaticBody2D
const DEATH_FX := preload("res://scenes/combat/impact.tscn")
@export_range(0.1, 30) var respawn_time := 3.0
var total := 0
var previous_hp: int

func _ready() -> void:
	previous_hp = $HealthComponent.current_health
	$HealthBar.max_value = $HealthComponent.max_health
	$HealthBar.value = previous_hp
	$HealthComponent.health_changed.connect(_update_health)
	$HealthComponent.died.connect(_die)

func _die() -> void:
	hide()
	$Collider.set_deferred("disabled", true)
	# El efecto vive fuera del blanco, así permanece visible al ocultarlo.
	var fx = DEATH_FX.instantiate()
	get_parent().add_child(fx)
	fx.global_position = global_position
	fx.play(32.0)
	await get_tree().create_timer(respawn_time, false, true).timeout
	total = 0
	$Readout.text = "0"
	$HealthComponent.revive()
	$Collider.set_deferred("disabled", false)
	show()

func _update_health(hp: int, maximum: int) -> void:
	$HealthBar.max_value = maximum
	$HealthBar.value = hp
	var amount := previous_hp - hp
	previous_hp = hp
	if amount <= 0: return
	total += amount
	$Readout.text = str(total)
	# El daño flota encima del blanco y usa contorno para destacar sobre el destello.
	var number := Label.new()
	number.text = "−%d" % amount
	number.modulate = Color.GOLD
	number.add_theme_font_size_override("font_size",22)
	number.add_theme_constant_override("outline_size",5)
	number.add_theme_color_override("font_outline_color",Color.BLACK)
	number.position = Vector2(-16,-48)
	number.z_index = 12
	add_child(number)
	var fade := number.create_tween()
	fade.tween_property(number,"position:y",-74,0.5)
	fade.parallel().tween_property(number,"modulate:a",0,0.5)
	fade.tween_callback(number.queue_free)
