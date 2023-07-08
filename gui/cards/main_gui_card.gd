extends GUICard

func _ready() -> void:
	Global.is_main_card = true


func _on_start_button_pressed() -> void:
	if Global.high_score > 0:
		Global.new_game()
		close_card()
	else:
		change_card("story")
