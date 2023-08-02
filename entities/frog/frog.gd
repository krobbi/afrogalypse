## An entity to be avoided by a [Car].
class_name Frog
extends Area2D

## The frog's virtual gravity.
const _GRAVITY: float = 200.0

## The frog's vertical force when jumping.
const _JUMP_FORCE: float = 40.0

## The amount to reduce horizontal velocity in pixels per second while jumping.
const _AIR_RESISTANCE: float = 100.0

## The minumum time to wait between jumps in seconds.
const _WAIT_MIN: float = 0.3

## The maximum time to wait between jumps in seconds.
const _WAIT_MAX: float = 0.9

## The frog's forward horizontal force when jumping.
var _forward_force: float = 160.0

## Whether the frog has been hit.
var _is_hit: bool = false

## The time until the frog should jump in seconds.
var _jump_timer: float = 0.0

## The frog's horizontal velocity.
var _horizontal_velocity: float = 0.0

## The frog's vertical velocity.
var _vertical_velocity: float = 0.0

## The frog's [Sprite2D]
@onready var _sprite: Sprite2D = $Sprite

## The frog's [CollisionShape2D].
@onready var _collision_shape: CollisionShape2D = $CollisionShape

## Run on every physics frame. Process the frog's movement.
func _physics_process(delta: float) -> void:
	if _is_hit:
		if _sprite.position.y < 4.0:
			_sprite.position.y += _vertical_velocity * delta
			_vertical_velocity += _GRAVITY * delta
		else:
			_sprite.position.y = 4.0
		
		return
	
	if _vertical_velocity >= 0.0 and _sprite.position.y >= 0.0:
		_sprite.position.y = 0.0
		_sprite.frame = 0
		_jump_timer -= delta
		
		if _jump_timer <= 0.0:
			_horizontal_velocity = _forward_force
			_vertical_velocity = -_JUMP_FORCE
	else:
		_sprite.frame = 1
		_sprite.position.y += _vertical_velocity * delta
		_vertical_velocity += _GRAVITY * delta
		position.x += _horizontal_velocity * delta
		
		var horizontal_velocity_sign: float = signf(_horizontal_velocity)
		_horizontal_velocity -= horizontal_velocity_sign * _AIR_RESISTANCE * delta
		
		if signf(_horizontal_velocity) != horizontal_velocity_sign:
			_horizontal_velocity = 0.0
		
		if global_position.x > 384.0 or global_position.x < -64.0:
			queue_free()
		
		if _vertical_velocity >= 0.0 and _sprite.position.y >= 0.0:
			_jump_timer = Global.rng.randf_range(_WAIT_MIN, _WAIT_MAX)


# Make the frog move right to left.
func flip_left() -> void:
	_sprite.flip_h = true
	_sprite.offset.x = -_sprite.offset.x
	_forward_force = -_forward_force


## Hit the frog with a force.
func hit(force: float) -> void:
	_is_hit = true
	_collision_shape.set_deferred("disabled", true)
	_vertical_velocity = -force
	_sprite.flip_v = true
