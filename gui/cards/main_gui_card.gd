extends GUICard

func _ready() -> void:
	Global.is_main_card = true


func _on_start_button_pressed() -> void:
	if Global.high_score > 0:
		Global.new_game()
		close_card()
	else:
		change_card("story")


## Run when the quit button is pressed. Quit the game.
func _on_quit_button_pressed() -> void:
	Global.request_quit()
