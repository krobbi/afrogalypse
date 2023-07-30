## A [GUICard] containing the main menu.
class_name MainGUICard
extends GUICard

## Run when the main gui card is ready. Notify the game that the main menu is
## active.
func _ready() -> void:
	Global.is_main_card = true


## Run when the start [Button] is pressed. Start a new game or display a
## tutorial if there is no high score.
func _on_start_button_pressed() -> void:
	if Config.get_bool("progress/has_seen_tutorial"):
		Global.new_game()
		close_card()
	else:
		change_card("tutorial")


## Run when the quit button is pressed. Quit the game.
func _on_quit_button_pressed() -> void:
	get_tree().quit()
