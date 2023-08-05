## An entity that periodically spawns signs based on a [DistanceClock].
class_name SignSpawner
extends Marker2D

## The [PackedScene] to instantiate signs from.
@export var _sign_scene: PackedScene

## The [DistanceClock] to spawn signs with.
@onready var _distance_clock: DistanceClock = $DistanceClock

## Run when the [DistanceClock] reaches its distance. Reset the [DistanceClock]
## and spawn a sign.
func _on_distance_clock_distance_reached() -> void:
	randomize()
	_distance_clock.distance = randf_range(4200.0, 6000.0)
	_distance_clock.reset()
	var sign_entity: Sprite2D = _sign_scene.instantiate()
	sign_entity.position.x = randf_range(-16.0, 16.0)
	sign_entity.tree_exiting.connect(_on_sign_tree_exiting, CONNECT_ONE_SHOT)
	add_child(sign_entity)


## Run when a sign exits the scene tree. Emit [signal Event.sign_passed].
func _on_sign_tree_exiting() -> void:
	Event.sign_passed.emit()
