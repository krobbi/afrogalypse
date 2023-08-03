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
		_:
			return value


## Cast a [Variant] to a [bool].
static func cast_bool(value: Variant) -> bool:
	return true if value else false


## Cast a [Variant] to an [int].
static func cast_int(value: Variant) -> int:
	match typeof(value):
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			return int(value)
		_:
			return 0


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
