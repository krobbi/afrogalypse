extends Node2D

@export var sprite: Sprite2D
@export var jump_force: float = 20.0
@export var gravity: float = 100.0
@export var ground_wait: float = 0.1

var ground_timer: float = 0.0
var vertical_velocity: float = 0.0

func _physics_process(delta: float) -> void:
	if vertical_velocity >= 0.0 and sprite.position.y >= 0.0:
		sprite.position.y = 0.0
		sprite.frame = 0
		ground_timer -= delta
		
		if ground_timer <= 0.0:
			vertical_velocity = -jump_force
	else:
		sprite.frame = 1
		ground_timer = ground_wait
		sprite.position.y += vertical_velocity * delta
		vertical_velocity += gravity * delta
