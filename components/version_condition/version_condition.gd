## Frees a [Node] if the game's version does not match a condition.
class_name VersionCondition
extends Node

## The [Node] to free if the game's version does not match the condition.
@export var _node: Node

## Whether the condition is for a web build or a desktop build.
@export var _is_web: bool = false

## Run when the version condition is ready. Free the [Node] if the game's
## version does not match the condition, and free the version condition.
func _ready() -> void:
	if not _condition_matches():
		_node.queue_free()
	
	queue_free() # The version condition can be removed from the scene.


## Return whether the game's version matches the condition.
func _condition_matches() -> bool:
	return Global.is_web() == _is_web
