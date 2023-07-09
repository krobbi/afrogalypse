extends Marker2D

@export var sign_scene: PackedScene

@onready var distance_clock: DistanceClock = $DistanceClock

func spawn_sign() -> void:
	var sign_entity: Sprite2D = sign_scene.instantiate()
	randomize()
	sign_entity.position.x = randf_range(-16.0, 16.0)
	distance_clock.remaining = Global.rng.randf_range(4200.0, 6000.0)
	add_child(sign_entity)
