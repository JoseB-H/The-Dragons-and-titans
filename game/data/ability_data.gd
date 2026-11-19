class_name AbilityData
extends Resource
## Datos de diseño para la siguiente iteración. El estado de recarga vive en el actor.
@export var id: StringName
@export var display_name: String
@export_range(0, 60, 0.1, "or_greater") var cooldown_seconds := 1.0
