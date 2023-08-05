## A [GUICard] containing the main menu.
class_name MainGUICard
extends GUICard

## Run when the start [Button] is pressed. Start a new game or display a
## tutorial if there is no high score.
func _on_start_button_pressed() -> void:
	if Config.get_bool("progress/has_seen_tutorial"):
		Event.new_game_started.emit()
		close_card()
	else:
		change_card("tutorial")


## Run when the quit button is pressed. Quit the game.
func _on_quit_button_pressed() -> void:
	get_tree().quit()
