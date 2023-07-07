class_name Explorer
extends CharacterBody2D

# The position to go towards
var target_position: Vector2 = position

func _physics_process(_delta: float) -> void:
	if position.distance_to(target_position) < 16.0:
		target_position = get_random_pos()
	
	create_tween().tween_property(self, "position", target_position, 3.0)


func get_random_pos() -> Vector2:
	randomize()
	return Vector2(randf_range(-160.0, 16.0), randf_range(-160.0, 160.0))
