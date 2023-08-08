## Road scene. Contains the core gameplay.
extends Node2D

## The [GUIStack] to display the main menu with.
@onready var _main_menu: GUIStack = $GUILayer/MainMenuGUIStack

## Run when the road scene is ready. Subscribe the road scene to event [Signal]s
## and display the [MainGUICard].
func _ready() -> void:
	Event.subscribe(Event.game_over, _on_game_over)
	_main_menu.change_card("main")


## Run on game over. Display the [GameOverGUICard].
func _on_game_over() -> void:
	_main_menu.change_card("game_over")
