## An entity that adds energy when it leaves the screen.
class_name Sign
extends Sprite2D

## Run when the sign exits the scene tree. Add energy.
func _exit_tree() -> void:
	Global.energy_added.emit()
