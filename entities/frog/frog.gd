class_name Frog
extends Area2D

## The frog's virtual gravity.
const _GRAVITY: float = 200.0

@export var sprite: Sprite2D
@export var jump_force: float = 40.0
@export var ground_wait_min: float = 0.3
@export var ground_wait_max: float = 0.9
@export var forward_force: float = 160.0
@export var friction: float = 100.0

var ground_timer: float = 0.0
var horizontal_velocity: float = 0.0
var vertical_velocity: float = 0.0
var is_hit: bool = false

## The frog's [CollisionShape2D].
@onready var _collision_shape: CollisionShape2D = $CollisionShape

func _physics_process(delta: float) -> void:
	if is_hit:
		if sprite.position.y < 4.0:
			sprite.position.y += vertical_velocity * delta
			vertical_velocity += _GRAVITY * delta
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
		sprite.position.y += vertical_velocity * delta
		vertical_velocity += _GRAVITY * delta
		position.x += horizontal_velocity * delta
		
		var horizontal_velocity_sign: float = signf(horizontal_velocity)
		horizontal_velocity = horizontal_velocity - horizontal_velocity_sign * friction * delta
		
		if signf(horizontal_velocity) != horizontal_velocity_sign:
			horizontal_velocity = 0.0
		
		if global_position.x > 384.0 or global_position.x < -64.0:
			queue_free()
		
		if vertical_velocity >= 0.0 and sprite.position.y >= 0.0:
			ground_timer = Global.rng.randf_range(ground_wait_min, ground_wait_max)


# Make the frog move right to left.
func flip_left() -> void:
	sprite.flip_h = true
	sprite.offset.x = -sprite.offset.x
	forward_force = -forward_force


## Hit the frog with a force.
func hit(force: float) -> void:
	is_hit = true
	_collision_shape.set_deferred("disabled", true)
	vertical_velocity = -force
	sprite.flip_v = true
