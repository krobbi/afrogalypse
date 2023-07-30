## A connection from the game's config data to a [Node]'s [Callable].
class_name ConfigConnection
extends RefCounted

## The connection's target [Callable].
var _callable: Callable

## The connection's target [enum Variant.Type].
var _type: Variant.Type

## Cast a [Variant] to a [enum Variant.Type].
static func cast_value(value: Variant, type: Variant.Type) -> Variant:
	match type:
		TYPE_BOOL:
			return cast_bool(value)
		TYPE_INT:
			return cast_int(value)
		TYPE_FLOAT:
			return cast_float(value)
		_:
			return value


## Cast a [Variant] to a [bool].
static func cast_bool(value: Variant) -> bool:
	if value is float:
		return is_finite(value) and (value > 0.0 or value < -0.0)
	else:
		return true if value else false


## Cast a [Variant] to an [int].
static func cast_int(value: Variant) -> int:
	match typeof(value):
		TYPE_BOOL, TYPE_STRING:
			return int(value)
		TYPE_INT:
			return value
		TYPE_FLOAT:
			if is_finite(value):
				return int(value)
	
	return 0


## Cast a [Variant] to a [float].
static func cast_float(value: Variant) -> float:
	match typeof(value):
		TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return float(value)
		TYPE_FLOAT:
			if is_finite(value) and value != -0.0:
				return value
	
	return 0.0


## Initialize the connection's target [Callable] and [enum Variant.Type].
func _init(callable: Callable, type: Variant.Type) -> void:
	_callable = callable
	_type = type


## Get the connection's target [Node].
func get_node() -> Node:
	return _callable.get_object()


## Notify the connection's target with a [Variant].
func notify(value: Variant) -> void:
	_callable.call(ConfigConnection.cast_value(value, _type))
