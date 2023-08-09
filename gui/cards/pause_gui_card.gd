## A [GUICard] containing the root of the pause menu.
class_name PauseGUICard
extends GUICard

## Run when the pause GUI card is ready. Pause the game.
func _ready() -> void:
	get_tree().paused = true


## Unpause the game and make a request to pop the pause GUI card.
func resume() -> void:
	get_tree().paused = false
	pop_card()
