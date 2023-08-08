## A [GUICard] that is displayed on a game over.
class_name GameOverGUICard
extends GUICard

## Run when the retry [Button] is pressed. Emit [Event.game_over_cleared] and
## change to the [MainGUICard].
func _on_retry_button_pressed() -> void:
	Event.game_over_cleared.emit()
	change_card("main")
