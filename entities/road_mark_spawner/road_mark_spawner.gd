extends Marker2D

# Road Mark Spawner
# Spawns road marks

@export var road_mark_scene: PackedScene

func spawn_road_mark() -> void:
	add_child(road_mark_scene.instantiate())
