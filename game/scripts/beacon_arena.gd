extends "res://scripts/arena.gd"

const Beacon := preload("res://scripts/beacon.gd")

@onready var beacons: Array[Beacon] = [$WestBeacon, $EastBeacon]


func _victory_ready(delta: float) -> bool:
	for beacon in beacons:
		beacon.update_capture(player.global_position, delta)
	return not enemy.is_alive() and _captured_count() == beacons.size()


func _objective_text() -> String:
	return "balizas %d/%d y derrota al Sentinela" % [_captured_count(), beacons.size()]


func _captured_count() -> int:
	var count := 0
	for beacon in beacons:
		count += int(beacon.captured)
	return count
