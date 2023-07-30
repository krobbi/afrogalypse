## Emits [signal distance_reached] every time an amount of distance is reached.
class_name DistanceClock
extends Node

## Emitted when an amount of distance is reached.
signal distance_reached

## The amount of distance between emitting [signal distance_reached].
@export var distance: float = 90.0

## Whether to emit [signal distance_reached] immediately.
@export var instant: bool = true

## The remaining distance until [signal distance_reached] is emitted.
var _remaining: float = 0.0

## Run when the distance clock is ready. Reset the distance clock.
func _ready() -> void:
	reset()


## Run on every physics frame. Update the remaining distance from the current
## speed and emit[signal distance_reached] if the distance is reached.
func _physics_process(delta: float) -> void:
	_remaining -= Global.speed * delta
	
	if _remaining <= 0.0:
		_remaining += distance
		distance_reached.emit()


## Reset the remaining distance to its starting value.
func reset() -> void:
	_remaining = 0.0 if instant else distance
