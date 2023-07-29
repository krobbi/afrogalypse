## Road scene. Contains the core gameplay.
extends Node2D

## Run when the road scene is ready. Display the main menu.
func _ready() -> void:
	Global.gui_card_changed.emit("main")
