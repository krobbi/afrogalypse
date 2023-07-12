class_name RoadSectionSpawner
extends Marker2D

# Road Section Spawner
# Spawns road sections.

@export var road_section_scene: PackedScene

func spawn_road_section() -> void:
	add_child(road_section_scene.instantiate())
