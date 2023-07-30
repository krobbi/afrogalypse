## A [GUICard] that is displayed on a game over.
class_name GameOverGUICard
extends GUICard

## Run when the retry [Button] is pressed. change to the [MainGUICard].
func _on_retry_button_pressed() -> void:
	Global.game_over_cleared.emit()
	change_card("main")
