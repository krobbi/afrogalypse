class_name Stickman
extends CharacterBody2D

@export var _speed: float = 64.0
@export var _acceleration: float = 256.0
@export var _seen_player: AudioStreamPlayer

var is_locked: bool = false

func _ready() -> void:
	Events.stickman_seen.connect(_on_seen)
	Events.stickman_lost.connect(_on_lost)


func _physics_process(delta: float) -> void:
	if is_locked:
		return
	
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.move_toward(input * _speed, _acceleration * delta)
	move_and_slide()


func _on_seen() -> void:
	is_locked = true
	velocity = Vector2.ZERO
	_seen_player.play()


func _on_lost() -> void:
	is_locked = false
