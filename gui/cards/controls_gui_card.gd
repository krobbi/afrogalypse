## A [GUICard] containing the game's [MappingButton]s.
class_name ControlsGUICard
extends GUICard

## Run when the controls GUI card is ready. Subscribe the controls GUI card to
## event signals.
func _ready() -> void:
	Event.subscribe(Event.input_mappings_changed, $BlipPlayer.play)


## Run when the reset controls [Button] is pressed. Reset the input mappings.
func _on_reset_controls_button_pressed() -> void:
	InputManager.reset_mappings()
