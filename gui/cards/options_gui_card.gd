## A [GUICard] containing the options.
class_name OptionsGUICard
extends GUICard

## Run when the options GUI card is ready. Notify the game that the main menu is
## not active.
func _ready() -> void:
	Global.is_main_card = false
