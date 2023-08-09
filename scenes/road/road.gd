## Road scene. Contains the core gameplay.
extends Node2D

## The [GUIStack] to display the main menu with.
@onready var _main_menu: GUIStack = $GUILayer/MainMenuGUIStack

## Whether the game is currently active.
var _is_in_game: bool = false

## Run when the road scene is ready. Subscribe the road scene to event [Signal]s
## and display the [MainGUICard].
func _ready() -> void:
	Event.subscribe(Event.game_over, _on_game_over)
	Event.subscribe(Event.game_paused, _on_game_paused)
	_main_menu.change_card("main")


## Run on game over. Display the [GameOverGUICard].
func _on_game_over() -> void:
	_is_in_game = false
	_main_menu.change_card("game_over")


## Run when the game is paused. Display the [PauseGUICard].
func _on_game_paused() -> void:
	_main_menu.change_card("pause")


## Run when the main menu [GUIStack]'s root [GUICard] is popped. Emit
## [signal Event.new_game_started].
func _on_main_menu_root_popped() -> void:
	if not _is_in_game:
		_is_in_game = true
		Event.new_game_started.emit()
