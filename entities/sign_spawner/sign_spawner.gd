## An entity that periodically spawns [Sign]s based on a [DistanceClock].
class_name SignSpawner
extends Marker2D

## The [PackedScene] to instantiate [Sign]s from.
@export var _sign_scene: PackedScene

## The [DistanceClock] to spawn [Sign]s with.
@onready var _distance_clock: DistanceClock = $DistanceClock

## Run when the [DistanceClock] reaches its distance. Spawn a [Sign] and reset
## the [DistanceClock].
func _on_distance_clock_distance_reached() -> void:
	var sign_entity: Sign = _sign_scene.instantiate()
	randomize()
	sign_entity.position.x = randf_range(-16.0, 16.0)
	_distance_clock.distance = Global.rng.randf_range(4200.0, 6000.0)
	_distance_clock.reset()
	add_child(sign_entity)
