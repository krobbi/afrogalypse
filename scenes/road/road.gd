## Road scene. Contains the core gameplay.
extends Node2D

## Run when the road scene is ready. Display the main menu.
func _ready() -> void:
	Global.gui_card_changed.emit("main")


## Run when the car stops. Display the game over menu.
func _on_car_stopped() -> void:
	Global.gui_card_changed.emit("game_over")
