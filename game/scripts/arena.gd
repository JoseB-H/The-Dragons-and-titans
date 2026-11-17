extends Node3D
## Composición de T03 y restauración mínima. Los estados de partida son T05.

@onready var player: Node3D = $Dragon
@onready var enemy: Node3D = $Enemy
@onready var label: Label = $Controls/Panel/Margin/Label


func _ready() -> void:
	player.get_node("Weapon").projectile_parent = $Projectiles
	enemy.get_node("Weapon").projectile_parent = $Projectiles
	enemy.target = player
	_update_hud()


func _process(_delta: float) -> void:
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restore_arena") and not event.is_echo():
		get_viewport().set_input_as_handled()
		restore_arena()


func restore_arena() -> Error:
	return get_tree().reload_current_scene()


func _update_hud() -> void:
	var status := ""
	if not player.is_alive():
		status = " · Jugador caído"
	elif not enemy.is_alive():
		status = " · Enemigo abatido"
	label.text = "T03 · Combate offline · Valores provisionales\nWASD: mover · Ratón: orientar · Clic izq.: disparar · R: restaurar\nJugador: %d / %d · Enemigo: %d / %d%s\nRecarga de disparo: %.1f s · Q/E aún no implementadas" % [player.current_health, player.max_health, enemy.current_health, enemy.max_health, status, player.get_node("Weapon").cooldown_remaining]
