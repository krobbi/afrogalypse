extends Marker2D

# Road Mark Spawner
# Spawns road marks

@export var road_mark_scene: PackedScene
@export var delay: float = 1.0

var timer: float = 0.0

func _physics_process(delta: float) -> void:
	timer -= delta
	
	if timer <= 0.0:
		timer += delay
		add_child(road_mark_scene.instantiate())
