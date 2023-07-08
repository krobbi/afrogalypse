class_name Frog
extends Node2D

@export var sprite: Sprite2D
@export var jump_force: float = 40.0
@export var gravity: float = 200.0
@export var ground_wait: float = 0.1
@export var forward_force: float = 250.0
@export var friction: float = 20.0

var ground_timer: float = 0.0
var horizontal_velocity: float = 0.0
var vertical_velocity: float = 0.0
var is_hit: bool = false

func _physics_process(delta: float) -> void:
	if is_hit:
		sprite.flip_v = true
		
		if sprite.position.y < 4.0:
			sprite.position.y += vertical_velocity * delta
			vertical_velocity += gravity * delta
		else:
			sprite.position.y = 4.0
		
		return
	
	if vertical_velocity >= 0.0 and sprite.position.y >= 0.0:
		sprite.position.y = 0.0
		sprite.frame = 0
		ground_timer -= delta
		
		if ground_timer <= 0.0:
			horizontal_velocity = forward_force
			vertical_velocity = -jump_force
	else:
		sprite.frame = 1
		ground_timer = ground_wait
		sprite.position.y += vertical_velocity * delta
		vertical_velocity += gravity * delta
		position.x += horizontal_velocity * delta
		horizontal_velocity = max(horizontal_velocity - friction * delta, 0.0)


# Hit by car.
func _on_hitbox_area_entered(_area: Area2D) -> void:
	if not is_hit:
		is_hit = true
		vertical_velocity = -100.0
		Global.on_frog_hit()
