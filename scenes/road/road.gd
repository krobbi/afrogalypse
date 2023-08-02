## Road scene. Contains the core gameplay.
extends Node2D

## The [GUICardManager] to display [GUICard]s with.
@onready var _gui_card_manager: GUICardManager = $GUILayer/GUICardManager

## Run when the road scene is ready. Display the [MainGUICard].
func _ready() -> void:
	_gui_card_manager.change_card("main")


## Run when the [Car] stops. Display the [GameOverGUICard].
func _on_car_stopped() -> void:
	_gui_card_manager.change_card("game_over")
