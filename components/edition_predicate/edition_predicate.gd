## Frees a [Node] if the game's edition does not match a set of conditions.
class_name EditionPredicate
extends Node

## A condition to evaluate a [bool] against.
enum BoolCondition {
	EITHER, ## The [bool] may be either [code]true[/code] or [code]false[/code].
	TRUE, ## The [bool] must be [code]true[/code].
	FALSE, ## The [bool] must be [code]false[/code].
}

## The [Node] to free if the game's edition does not match all of the
## conditions.
@export var _node: Node

## The [enum BoolCondition] for whether the game is a web build.
@export var _web_build: BoolCondition = BoolCondition.EITHER

## The [enum BoolCondition] for whether the game is in debug mode.
@export var _debug_mode: BoolCondition = BoolCondition.EITHER

## Run when the edition predicate is ready. Free the [Node] if the game's
## edition does not match the conditions, and free the edition predicate.
func _ready() -> void:
	if not _eval():
		_node.queue_free()
	
	queue_free() # The edition predicate can be removed from the scene.


## Evaluate the edition predicate.
func _eval() -> bool:
	return (
			_eval_bool(OS.get_name() == "Web", _web_build)
			and _eval_bool(OS.is_debug_build(), _debug_mode))


## Evaluate a [bool] against a [enum BoolCondition].
func _eval_bool(value: bool, condition: BoolCondition) -> bool:
	match condition:
		BoolCondition.TRUE:
			return value
		BoolCondition.FALSE:
			return not value
		_:
			return true
