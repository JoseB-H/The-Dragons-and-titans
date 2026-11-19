class_name DragonData
extends Resource
## Identidad y balance provisional del prototipo, no del juego original.
## Recursos de solo lectura durante la partida: las recargas viven en cada actor.

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var max_health: int
@export var movement_speed: float
@export var basic_damage: int
@export var basic_cooldown: float
@export var basic_projectile_speed: float
@export var basic_projectile_lifetime: float
@export var basic_spawn_distance: float
@export var power_damage: int
@export var power_cooldown: float
@export var power_projectile_speed: float
@export var power_projectile_lifetime: float
@export var power_spawn_distance: float
@export var pulse_damage: int
@export var pulse_radius: float
@export var pulse_cooldown: float
@export var pulse_effect_duration: float
@export var body_color: Color
@export var accent_color: Color
@export var wing_color: Color
