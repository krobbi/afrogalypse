## A debug tool for advancing by single physics frames. Useful for grabbing
## screenshots.
class_name FrameStepper
extends Node

## Run when the frame stepper receives an [InputEvent]. Handle controls for
## frame stepping.
func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event.is_action_pressed("debug_step_frame", true):
			get_tree().paused = false
			await get_tree().physics_frame
			await get_tree().physics_frame
			get_tree().paused = true
		elif event.is_action_pressed("debug_resume"):
			get_tree().paused = false
