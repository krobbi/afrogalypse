## An entity that periodically spawns road sections based on a [DistanceClock].
class_name RoadSectionSpawner
extends Marker2D

## The [PackedScene] to instantiate road sections from.
@export var _road_section_scene: PackedScene

## Run when the [DistanceClock] reaches its distance. Spawn a road section.
func _on_distance_clock_distance_reached() -> void:
	add_child(_road_section_scene.instantiate())
