## A GUI widget that controls an input mapping.
class_name MappingButton
extends HBoxContainer

## The action to control.
@export var _action: String

## The mapping button's [Button].
@onready var _button: Button = $Button

## The [Timer] to automatically deactivate the mapping button.
@onready var _timer: Timer = $Timer

## Whether the mapping button is actively waiting for input.
var _is_active: bool = false

## Run when the mapping button is ready. Initialize the mapping button's
## [Control]s.
func _ready() -> void:
	$Label.text = "action.%s" % _action
	set_active(false)


## Run when the mapping button receives an [InputEvent]. Attempt to map the
## [InputEvent] if the mapping button is active.
func _input(event: InputEvent) -> void:
	if _is_active and InputManager.map_action_event(_action, event):
		get_viewport().set_input_as_handled() # Consume the input.
		_deactivate_all()


## Set whether the mapping button is active.
func set_active(value: bool) -> void:
	if value:
		_deactivate_all()
		_button.text = "input.prompt"
		_timer.start()
	else:
		_timer.stop()
		_button.text = InputManager.get_mapping_name(_action)
	
	_is_active = value
	_button.set_pressed_no_signal(_is_active)


## Deactivate all mapping buttons.
func _deactivate_all() -> void:
	for action_button in get_tree().get_nodes_in_group("mapping_buttons"):
		action_button.set_active(false)
