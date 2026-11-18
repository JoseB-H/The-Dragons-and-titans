extends Resource
## Balance propio provisional; no mutar recursos del catálogo.
@export var id: StringName
@export var display_name: String
@export var damage_multiplier: float = 1.0
@export var cooldown_multiplier: float = 1.0
@export var tint: Color = Color(1, 0.65, 0.2)
@export var visual_scale: float = 1.0

func damage_for(dragon: Resource) -> int:
	return maxi(1, roundi(dragon.basic_damage * damage_multiplier))

func cooldown_for(dragon: Resource) -> float:
	return maxf(0.01, dragon.basic_cooldown * cooldown_multiplier)
