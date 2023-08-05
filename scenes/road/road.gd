## Road scene. Contains the core gameplay.
extends Node2D

## The [GUICardManager] to display [GUICard]s with.
@onready var _gui_card_manager: GUICardManager = $GUILayer/GUICardManager

## Run when the road scene is ready. Connect the road scene to event [Signal]s
## and display the [MainGUICard].
func _ready() -> void:
	Event.on(Event.game_over, _on_game_over)
	_gui_card_manager.change_card("main")


## Run on game over. Display the [GameOverGUICard].
func _on_game_over() -> void:
	_gui_card_manager.change_card("game_over")
