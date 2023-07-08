extends GUICard

func _on_retry_button_pressed() -> void:
	Global.game_over_cleared.emit()
	change_card("main")
