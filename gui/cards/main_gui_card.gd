extends GUICard

func _on_start_button_pressed() -> void:
	Global.new_game()
	close_card()
