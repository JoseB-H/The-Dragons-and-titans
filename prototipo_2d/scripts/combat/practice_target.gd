extends StaticBody2D
const DEATH_FX := preload("res://scenes/combat/impact.tscn")
@export_range(0.1, 30) var respawn_time := 3.0
var total := 0
var previous_hp: int

func _ready() -> void:
	previous_hp = $HealthComponent.current_health
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
	var amount := previous_hp - hp
	previous_hp = hp
	if amount <= 0: return
	total += amount
	$Readout.text = str(total)
	preload("res://scripts/ui/damage_number.gd").show_at(get_parent(),global_position,amount,Color.GOLD)
