class_name DistanceClock
extends Node

# Emits a signal every time a distance is reached.

signal distance_reached

@export var distance: float = 90.0
@export var instant: bool = true

var remaining: float = 0.0

func _ready() -> void:
	reset()


func _physics_process(delta: float) -> void:
	remaining -= Global.speed * delta
	
	if remaining <= 0.0:
		remaining += distance
		distance_reached.emit()


func reset() -> void:
	remaining = 0.0 if instant else distance
