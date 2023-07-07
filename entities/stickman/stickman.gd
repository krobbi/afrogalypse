class_name Stickman
extends CharacterBody2D

@export var _speed: float = 64.0
@export var _acceleration: float = 256.0

func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(Input.get_vector("move_left", "move_right", "move_up", "move_down") * _speed, _acceleration * delta)
	move_and_slide()
