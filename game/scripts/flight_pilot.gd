extends CharacterBody3D
const FLIGHT := preload("res://scripts/flight_geometry.gd")

@export_range(0.1, 30.0, 0.1) var speed := 6.0
@export_range(0.2, 8.0, 0.1) var flight_height := 1.5
@export var half_extents := Vector2(20,14)
@onready var camera: Camera3D = $Camera
@onready var facing: Node3D = $Facing

func _ready() -> void:
	position.y = flight_height
	camera.snap_to_pilot()

func _physics_process(delta: float) -> void:
	# El movimiento depende de WASD y de la orientación de la cámara.
	var input := Input.get_vector("move_left","move_right","move_forward","move_back")
	var next := position + FLIGHT.movement(camera,input)*speed*delta
	position = Vector3(clampf(next.x,-half_extents.x,half_extents.x),flight_height,clampf(next.z,-half_extents.y,half_extents.y))

func _process(_delta: float) -> void:
	# Solo gira la figura, la cámara conserva su orientación durante la retirada.
	var direction := FLIGHT.aim(camera,global_position,get_viewport().get_mouse_position())
	if not direction.is_zero_approx():
		facing.look_at(facing.global_position + direction)
