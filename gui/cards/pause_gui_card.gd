## A [GUICard] containing the root of the pause menu.
class_name PauseGUICard
extends GUICard

## Run when the pause GUI card is ready. Pause the game.
func _ready() -> void:
	get_tree().paused = true


## Run when the pause GUI card receives an [InputEvent]. Handle controls for
## resuming.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		resume()


## Unpause the game and make a request to pop the pause GUI card.
func resume() -> void:
	get_tree().paused = false
	pop_card()


## Run when the end run [Button] is pressed. Resume the game and emit
## [signal Event.game_ended].
func _on_end_run_button_pressed() -> void:
	resume()
	Event.game_ended.emit()
