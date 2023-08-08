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
## [Control]s and subscribe the mapping button to event [Signal]s.
func _ready() -> void:
	$Label.text = "action.%s" % _action
	_deactivate()
	Event.subscribe(Event.input_mappings_changed, _deactivate)


## Run when the mapping button receives an [InputEvent]. Attempt to map the
## [InputEvent] if the mapping button is active.
func _input(event: InputEvent) -> void:
	if _is_active and InputManager.map_action_event(_action, event):
		get_viewport().set_input_as_handled() # Consume the input.


## Activate the mapping button.
func _activate() -> void:
	_is_active = true
	_button.set_pressed_no_signal(true)
	_button.text = "input.prompt"
	_timer.start()


## Deactivate the mapping button.
func _deactivate() -> void:
	_is_active = false
	_timer.stop()
	_button.set_pressed_no_signal(false)
	_button.text = InputManager.get_mapping_name(_action)


## Run when the mapping button's [Button] is toggled. Activate or deactivate the
## mapping button.
func _on_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		_activate()
	else:
		_deactivate()
