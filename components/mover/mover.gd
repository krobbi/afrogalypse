## Moves a [Node2D] downwards to simulate player movement and frees the [Node2D]
## once its global position reaches a limit.
class_name Mover
extends Node

## The global Y coordinate to free the [Node2D] at.
const _FREE_PLANE: float = 300.0

## The [Node2D] to move.
@export var _node: Node2D

## Run on every physics frame. Move the [Node2D] downwards and free it if its
## global position has reached the limit.
func _physics_process(delta: float) -> void:
	_node.position.y += Global.speed * delta
	
	if _node.global_position.y >= _FREE_PLANE:
		_node.queue_free()
