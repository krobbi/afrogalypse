class_name Sign
extends Sprite2D

func _exit_tree() -> void:
	Global.energy_added.emit()
